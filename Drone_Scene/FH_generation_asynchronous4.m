function [FH_data, used_Fc_sequence, finally_message, sig_message, part_long,rf] = FH_generation_asynchronous4(Fs, Fd, sig_power, nfft, data_long, i)

t = (0:data_long-1)/Fs;
% --- 跳频频率池生成 ---% 候选中心频率点数量 (可以根据需要调整)
fc_num = 100; 

target_freq_start = 5725e6; % 5725 MHz
target_freq_end = 5850e6;   % 5850 MHz
rf = (target_freq_end+target_freq_start)/2;
total_bandwidth = target_freq_end - target_freq_start; 
% 定义可选的跳频段带宽(0.42MHz - 2.2MHz)
bandwidth_options = 10e6;  

Fc_pool = get_fc_point(target_freq_start, target_freq_end,bandwidth_options,fc_num); % 在中心频率的有效范围内生成候选点
% 定义跳频周期为 0.01 秒
part_sig_vector = round(0.007 * Fs);              % 例如选取 0.5e-2, 0.52e-2, 1.8e-2, 0.3e-2, 2.8e-2 秒对应的采样点数（有效信号）
part_interval_vector = round(0.003 * Fs);      % 保护间隔长度 (采样点数)
part_data_len = part_sig_vector + part_interval_vector;
sig_num = floor(data_long/part_data_len); 
sig = zeros(1, data_long);


sig_message = zeros(sig_num, 4);

chosen_B =  bandwidth_options; 
chosen_Fd = 10000*round(chosen_B / 1.306 / 10000); % 计算该带宽对应的符号速率 Fd
used_Fc_sequence = zeros(1, sig_num);     % 用与存储实际使用的中心频率序列

%% 跳频信号生成主循环
for ii = 1:sig_num
    used_Fc_sequence(ii) = Fc_pool( mod(ii-1,length(Fc_pool))+1 );
    chosen_Fc =used_Fc_sequence(ii);
    % --- 基带信号生成 (chosen_Fd) 
    base_sig = get_bpsk(part_sig_vector, chosen_Fd, Fs);
    % --- 功率调整 ---
    base_sig = set_sig_power(base_sig, sig_power);
    % --- 段信号封装 ---
    part_sig = zeros(1, part_data_len);
    part_sig(1:part_sig_vector) = base_sig;

    % --- 记录信号参数到 sig_message 矩阵 ---
    sig_message(ii, 1) = chosen_Fc; % 记录中心频率 (Hz)
    sig_message(ii, 2) = chosen_B;  % 记录实际带宽 (Hz)
    sig_message(ii, 3) = (ii - 1) * part_data_len / Fs;                         % 起始时间 = (当前段索引 - 1) * 每段总长度 / 采样率
    sig_message(ii, 4) = sig_message(ii, 3) + part_sig_vector / Fs;  % 结束时间 = 起始时间 + 信号段长度 / 采样率

    % --- 上变频处理---
    carrier_segment = exp(1i * 2 * pi * (chosen_Fc -rf)* t(((ii - 1) * part_data_len + 1) : (ii * part_data_len)));
    part_fc_sig = part_sig .* carrier_segment;    % 将基带信号 part_sig 乘以载波信号段，将频谱从基带搬移到 chosen_Fc-rf。
    sig(((ii - 1) * part_data_len + 1) : (ii * part_data_len)) =part_fc_sig;

end

%% 输出最终信号
FH_data = sig; % 将合成完成的总跳频信号赋给输出变量
 
%    瀑布图参数转换
part_long = 20000; % 瀑布图分段长度(采样点数)
finally_message = tf_change(sig_message, part_long, nfft, Fs);

noverlap = 0;    
[S, F, T] = spectrogram(sig, nfft, noverlap, nfft, Fs, 'power', 'centered'); 
figure(); 
imagesc(T,F+rf,10*log10(abs(S))); 
axis xy;
colorbar;
xlabel('时间 (s)'); 
ylabel('频率 (Hz)'); 
title('信号时频图 (Spectrogram)');

end 