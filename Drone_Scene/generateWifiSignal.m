% function [wifi_signal, t] = generateWifiSignal(Fs, Fc, target_freq_start, target_freq_end, duration_t)
% function [wifi_signal, t] = generateWifiSignal(Fs, Fc, target_freq_start, target_freq_end, duration_t, tx_power_W)
function [wifi_signal, t] = generateWifiSignal(Fs, Fc, target_freq_start, target_freq_end, duration_t, tx_power_W, B_wifi)
% 将数值带宽转换为 wlanNonHTConfig 支持的字符串格式
switch B_wifi
    case 20e6
        bandwidth_string = 'CBW20';
    case 40e6
        bandwidth_string = 'CBW40';
    case 80e6
        bandwidth_string = 'CBW80';
    case 160e6
        bandwidth_string = 'CBW160';
    otherwise
    % 如果输入了不支持的带宽，则报错
    error('generateWifiSignal:UnsupportedBandwidth', '不支持的 WiFi 带宽: %g Hz。支持的值有 20e6, 40e6, 80e6, 160e6。', B_wifi);
end

% 计算总信号长度 (采样点数)
data_long = round(Fs * duration_t); % 使用 round 以确保是整数
t = (0:data_long-1) / Fs;

rf = (target_freq_start + target_freq_end) / 2;
wifi_signal = complex(zeros(1, data_long));

% --- 配置 WLAN Non-HT 参数 ---
cfg = wlanNonHTConfig( ...
    'Modulation', 'OFDM', ...                       % OFDM 调制
    'ChannelBandwidth', bandwidth_string, ... 
    'SignalChannelBandwidth', false, ...     % 不信号化频道带宽
    'BandwidthOperation', 'Absent', ...      % 不信号化带宽操作
    'MCS', 0, ...                                             % MCS 0 (6 Mbps)
    'PSDULength', 1500);                             % PSDU 长度


%% --- 循环生成并填充信号 ---
sig_len = 0; % 初始化已填充的样本数
while sig_len < data_long
    psdu = randi([0 1], 8 * cfg.PSDULength, 1, 'int8');
    [range, ~] = scramblerRange(cfg);
    scramInit = randi(range);
    wifi_base_signal = wlanNonHTData(psdu, cfg, scramInit);

    % 获取基带信号的原始采样率 (由 cfg 决定)
    fs = wlanSampleRate(cfg);
    
    % 将基带信号重采样到指定的系统采样率 Fs    % resample 函数自动处理抗混叠滤波
    wifi_base_signal_resampled = resample(wifi_base_signal, Fs, fs);

    % 计算重采样后的数据包长度和剩余需要填充的空间
    current_packet_len = length(wifi_base_signal_resampled);
    remaining_space = data_long - sig_len;

    % 复制数据包片段到主信号向量
    samples_to_copy = min(current_packet_len, remaining_space);

    if samples_to_copy > 0
        wifi_signal(sig_len + 1 : sig_len + samples_to_copy) = wifi_base_signal_resampled(1 : samples_to_copy);
        sig_len = sig_len + samples_to_copy;
    else
        % 如果剩余空间不足以容纳任何样本，则退出循环
        break;
    end
end
%%
% --- 上变频处理 ---
carrier = exp(1j * 2 * pi * (Fc - rf) * t);
wifi_signal = wifi_signal .* carrier;
% --- 调整信号功率---
% tx_power_W = 10^((tx_power_dBm - 30) / 10);
current_power = mean(abs(wifi_signal).^2);

% 计算所需的增益因子，以使信号功率达到 tx_power_W
% 使用 eps (机器浮点精度) 防止除以零
if current_power < eps % 如果当前信号功率非常接近零
    gain_factor = sqrt(tx_power_W / eps);
else
     gain_factor = sqrt(tx_power_W / current_power);
end

wifi_signal = wifi_signal * gain_factor;

%% --- 绘制时频图 ---
window_len = 1024; 
overlap_amount = round(window_len * 0.5); 
nfft_points = 2048; 
% [S, F, T, P] =  spectrogram(wifi_signal, window_len, overlap_amount, nfft_points, Fs, 'yaxis');
[S, F, T, P] =  spectrogram(wifi_signal, window_len, overlap_amount, nfft_points, Fs, 'power', 'centered'); % <--- 修改为这一行

figure; 
imagesc(T, F+rf, 10*log10(P));
axis xy; 
xlabel('时间 (秒)'); 
ylabel('频率 (Hz)');
title('WLAN Non-HT 信号时频图'); 
colorbar; 
xlim([0, duration_t]); 


end