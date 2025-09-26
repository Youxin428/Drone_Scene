function [downlink_signal, used_Fc_sequence, waterfall_message, signal_parameters, waterfall_segment_long,...
                                            rf] = generateDownlinkSignal(Fs, sig_power, nfft, data_long,target_freq_start,target_freq_end,BW_hz)

% --- 定义跳频频率池生成 ---
fc_num = 100; % 候选中心频率点数量
% target_freq_start = 5725e6; % 5725 MHz
% target_freq_end = 5850e6;   % 5850 MHz
rf = (target_freq_end + target_freq_start) / 2; 
% --- 定义构成重复单元的信号和保护间隔长度 (采样点数) ---
% sig_duration_s = rand() * (0.013 - 0.010) + 0.010;     % 有效信号时长 [0.010, 0.013] 秒
% interval_duration_s = rand() * (0.009 - 0.005) + 0.005; % 保护间隔时长 [0.002, 0.004] 秒
% repeat_block_duration_s = rand() * (0.200 - 0.100) + 0.100; % 频率重复块时长 [0.100, 0.200] 秒
%此处考虑一个定频无人机信号
sig_duration_s = 0.001;
interval_duration_s = 0;
repeat_block_duration_s = 0.001;

part_sig_len = round(sig_duration_s * Fs);            
part_interval_len = round(interval_duration_s* Fs);  
part_data_len = part_sig_len + part_interval_len;
sig_num = floor(data_long/part_data_len); 
repeat_factor = floor(repeat_block_duration_s * Fs / part_data_len);

Fc_pool = get_fc_point(target_freq_start, target_freq_end, BW_hz, fc_num);
Fc_pool = repelem(Fc_pool, repeat_factor);

sig = zeros(1, data_long);
signal_parameters = zeros(sig_num, 4);
chosen_B =  BW_hz; 
chosen_Fd = 10000*round(chosen_B / 1.306 / 10000); % 计算该带宽对应的符号速率 Fd
used_Fc_sequence = zeros(1, sig_num);     % 用与存储实际使用的中心频率序列

t = (0:data_long-1) / Fs;
%% 跳频信号生成主循环
for ii = 1:sig_num
    used_Fc_sequence(ii) = Fc_pool( mod(ii-1,length(Fc_pool))+1 );
    % chosen_Fc =used_Fc_sequence(ii);
    chosen_Fc = 5820e6;
    % --- 基带信号生成 (chosen_Fd) 
    base_sig = get_bpsk(part_sig_len, chosen_Fd, Fs);
    % --- 功率调整 ---
    base_sig = set_sig_power(base_sig, sig_power);
    % --- 段信号封装 ---
    part_sig = zeros(1, part_data_len);
    part_sig(1:part_sig_len) = base_sig;

    % --- 记录信号参数到 signal_parameters 矩阵 ---
    signal_parameters(ii, 1) = chosen_Fc; % 记录中心频率 (Hz)
    signal_parameters(ii, 2) = chosen_B;  % 记录实际带宽 (Hz)
    signal_parameters(ii, 3) = (ii - 1) * part_data_len / Fs;             %  起始时间 = (当前段索引 - 1) * 每段总长度 / 采样率
    signal_parameters(ii, 4) = signal_parameters(ii, 3) + part_sig_len / Fs;        %  结束时间 = 起始时间 + 信号段长度 / 采样率

    % --- 上变频处理---
    carrier_segment = exp(1i * 2 * pi * (chosen_Fc - rf)* t(((ii - 1) * part_data_len + 1) : (ii * part_data_len)));
    part_fc_sig = part_sig .* carrier_segment;    % 将基带信号 part_sig 乘以载波信号段，将频谱从基带搬移到 chosen_Fc-rf。
    sig(((ii - 1) * part_data_len + 1) : (ii * part_data_len)) =part_fc_sig;

end

%% 输出最终信号
downlink_signal = sig; % 将合成完成的总跳频信号赋给输出变量
 
% 瀑布图参数转换
part_long = 20000; % 瀑布图分段长度(采样点数)
waterfall_message  = tf_change(signal_parameters, part_long, nfft, Fs);
waterfall_segment_long = part_long;


% % 修正 Spectrogram 调用参数：窗口长度应为 part_long，FFT 点数应为 nfft
% % 修正重叠设置：通常设置为窗口长度的 50% 以获得更平滑的显示
% noverlap = round(part_long * 0.5); % 计算 Spectrogram 窗口的重叠点数
% [S, F, T] = spectrogram(sig, part_long, noverlap, nfft, Fs, 'power', 'centered');
% % noverlap = 0;    
% % [S, F, T] = spectrogram(sig, nfft, noverlap, nfft, Fs, 'power', 'centered'); 
% figure(); 
% imagesc(T,F+rf,10*log10(abs(S))); 
% axis xy;
% colorbar;
% xlabel('时间 (s)'); 
% ylabel('频率 (Hz)'); 
% title('信号时频图 (Spectrogram)');

end 

