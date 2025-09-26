clc
clear
close all
%% --- 射频和仿真参数定义 ---
Fs = 100e6;
duration_t = 1;
data_long = Fs*duration_t;
t = (0:data_long-1)/Fs;
Fc = 5.8e9;
target_freq_start  = 5725e6;
target_freq_end   =  5850e6;
rf = (target_freq_end + target_freq_start) / 2;

wifi_signal =  complex(zeros(1,data_long)) ;


%% 

% wlanNonHTData 生成了一个完整的、符合标准的基带 Wi-Fi 信号包。这个信号已经包含了标准的成型处理。
% 如果需要模拟射频信号或考虑功率/噪声，可在生成 y 之后进行额外的步骤（上变频、信号缩放、添加噪声等）。
cfg = wlanNonHTConfig( ...
    'Modulation', 'OFDM', ...                       % 更改为 OFDM 调制
    'ChannelBandwidth', 'CBW20', ...         % 20 MHz 频道带宽
    'SignalChannelBandwidth', false, ...     % 不信号化频道带宽
    'BandwidthOperation', 'Absent', ...      % 不信号化带宽操作
    'MCS', 0, ...                                             % <-- 修改为 MCS 0，它对应于 OFDM 的 6 Mbps
    'PSDULength', 1500, ...                         % 设置 PSDU 长度为 1500 字节
    'NumTransmitAntennas', 1);

    % 'Modulation_Values', {'OFDM', 'DSSS'}, ...  % 支持 OFDM 和 DSSS 调制
    % 'ChannelBandwidth_Values', {'CBW20', 'CBW40', 'CBW80', 'CBW160'}, ...  % 支持的频道带宽值
    % 'DataRate_Values', {'1Mbps', '2Mbps', '5.5Mbps', '11Mbps'} ...  % 数据速率选择

% psdu = randi([0 1],8*cfg.PSDULength,1,'int8');
% [range,numBits] = scramblerRange(cfg);
% scramInit = randi(range);
% y = wlanNonHTData(psdu,cfg,scramInit);
% fs = wlanSampleRate(cfg);  %生成wifi信号用的采样率。可以用resample函数重采样到指定的采样率

sig_len = 0; % 初始化已填充的样本数
while sig_len < data_long
    % ... (生成 psdu, scramInit, 调用 wlanNonHTData 获取 wifi_base_signal) ...
    psdu = randi([0 1], 8 * cfg.PSDULength, 1, 'int8');
    [range, ~] = scramblerRange(cfg);
    scramInit = randi(range);
    wifi_base_signal = wlanNonHTData(psdu, cfg, scramInit);
    fs = wlanSampleRate(cfg);    % 获取基带信号的采样率 (由 cfg 决定)
    wifi_base_signal_resampled = resample(wifi_base_signal, Fs, fs); %重采样

    current_packet_len = length(wifi_base_signal_resampled); % 重采样后的数据包长度
    remaining_space = data_long - sig_len; % 剩余需要填充的空间
    samples_to_copy = min(current_packet_len, remaining_space);
    if samples_to_copy > 0
        wifi_signal(sig_len + 1 : sig_len + samples_to_copy) = wifi_base_signal_resampled(1 : samples_to_copy);
        sig_len = sig_len + samples_to_copy;
    else
        break;
    end
end

carrier = exp(1j * 2 * pi * (Fc-rf) * t);
% rf_signal = wifi_signal .* carrier;
wifi_signal = wifi_signal .* carrier;


%% --- 绘制时频图 ---
window_len = 1024; 
overlap_amount = round(window_len * 0.5); 
nfft_points = 2048; 
[S, F, T, P] =  spectrogram(wifi_signal, window_len, overlap_amount, nfft_points, Fs, 'yaxis');

% 绘制功率谱密度的对数形式 (dB)
figure; % 创建一个新的图形窗口
imagesc(T, F+rf, 10*log10(P));

% 调整图形显示
axis xy; % 确保 Y 轴（频率）方向向上增加
xlabel('时间 (秒)'); % 设置横轴标签
ylabel('频率 (Hz)'); % 设置纵轴标签
title('WLAN Non-HT 信号时频图'); % 设置图标题

colorbar; % 添加颜色条，显示颜色对应的功率值 (dB)

% 可选：设置轴范围，以聚焦在信号的主要带宽上
% 根据您的设置，CBW20 信号中心频率是 Fc = 5.8e9 Hz，带宽 20 MHz
% 设置 Y 轴范围为 Fc +/- 15 MHz 或 Fc +/- 20 MHz，可以清晰地看到信号
% ylim([(Fc - 15e6), (Fc + 15e6)]);
xlim([0, duration_t]); % 确保显示整个仿真时长

