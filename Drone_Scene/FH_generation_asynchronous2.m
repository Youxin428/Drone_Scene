%% 异步跳频信号生成函数 - 修改版
% 功能：生成具有随机中心频率和可选带宽的跳频信号，确保信号落在指定总频率范围内。
% 输入参数：
%   Fs - 采样频率(Hz)。
%   Fd - 符号速率输入，带宽由 bandwidth_options 随机选择决定。
%   SNR - 信噪比(dB)。
%   noise_power - 噪声功率(dBm)。
%   nfft - FFT点数。
%   data_long - 总信号长度(采样点数)。
%   number - 发射台站编号 (此参数在函数内部未使用，但保留在输入列表中)。
%
% 输出参数：
%   FH_data - 生成的跳频信号向量。
%   used_Fc_sequence - 生成的跳频信号中，每个跳频段实际使用的中心频率序列 (Hz)。
%   finally_message - 转换后的瀑布图索引标注信息，反映信号在瀑布图上的时频位置。
%   sig_message - 原始信号参数信息矩阵，列定义为 [中心频率(Hz), 带宽(Hz), 起始时间(s), 结束时间(s)]。
%   part_long - 瀑布图分段长度（采样点数）。

function [FH_data, used_Fc_sequence, finally_message, sig_message, part_long] = FH_generation_asynchronous2(Fs, Fd, SNR, ...
    noise_power, nfft, data_long, number)

t = (0:data_long-1)/Fs;
% --- 跳频频率池生成 ---% 候选中心频率点数量 (可以根据需要调整)
fc_num = 100; 
% 定义目标总频率范围
target_freq_start = 5750e6; % 5750 MHz
target_freq_end = 5850e6;   % 5850 MHz
rf = (target_freq_end+target_freq_start)/2;
total_bandwidth = target_freq_end - target_freq_start; 
% 定义可选的跳频段带宽(0.42MHz - 2.2MHz)
bandwidth_options = 1e6;  

Fc_pool = get_fc_point(target_freq_start, target_freq_end,bandwidth_options,fc_num); % 在中心频率的有效范围内生成候选点
% 定义跳频周期为 0.01 秒
part_sig_vector = round(0.5e-2 * Fs);              % 例如选取 0.5e-2, 0.52e-2, 1.8e-2, 0.3e-2, 2.8e-2 秒对应的采样点数（有效信号）
part_interval_vector = round(0.5e-2 * Fs);      % 保护间隔长度 (采样点数)
part_data_len = part_sig_vector + part_interval_vector;
sig_num = floor(data_long/part_data_len);
sig = zeros(1, data_long);

used_Fc_sequence = zeros(1, sig_num); % 用与存储实际使用的中心频率序列

% 根据 tf_change 函数的期望输入和本函数的用途，其列定义为 [中心频率(Hz), 带宽(Hz), 起始时间(s), 结束时间(s)]
sig_message = zeros(sig_num, 4);

% 原理：SNR(dB) = 10*log10(Ps/Pn) => Ps = Pn * 10^(SNR/10)
sig_power = 10^(noise_power/10) * 10^(SNR/10); % 噪声功率从 dBm 转换为 mW (乘以 10^(dBm/10))，再根据 SNR 计算信号功率 (线性值)。
% sig_power = 10^((noise_power + SNR)/10); % 总信号功率 (线性值)
% --- 随机选择该跳频段的带宽和对应的符号速率 ---
chosen_B =  bandwidth_options; 
chosen_Fd = 10000*round(chosen_B / 1.306 / 10000); % 计算该带宽对应的符号速率 Fd
index = 0;
%% 跳频信号生成主循环
% 循环 sig_num 次，生成每一个独立的跳频段信号。
for ii = 1:sig_num
    used_Fc_sequence(ii) = Fc_pool( mod(ii-1,length(Fc_pool))+1 );
    chosen_Fc =used_Fc_sequence(ii);
    % --- 基带信号生成 (使用该跳频段的 chosen_Fd) ---
    % 调用 get_bpsk 函数，根据该跳频段的信号段长度、计算出的符号速率和采样率，生成基带 BPSK 信号。
    base_sig = get_bpsk(part_sig_vector, chosen_Fd, Fs);

    % --- 功率调整 ---
    % 调用 set_sig_power 函数，将生成的基带信号调整到所需的信号功率 sig_power。
    base_sig = set_sig_power(base_sig, sig_power);
    % --- 段信号封装 ---
    % 初始化一个包含保护间隔的全零段信号向量。
    part_sig = zeros(1, part_data_len);
    % 将生成的有效基带信号 base_sig 放置在段信号的前部。
    part_sig(1:part_sig_vector) = base_sig;

    % --- 记录信号参数到 sig_message 矩阵 ---
    % 记录该跳频段使用的实际中心频率和带宽。
    sig_message(ii, 1) = chosen_Fc; % 记录中心频率 (Hz)
    sig_message(ii, 2) = chosen_B;  % 记录实际带宽 (Hz)??????
    % 记录该跳频段在总信号时间序列 t 中的起始时间和结束时间 (以秒为单位)。
    sig_message(ii, 3) = (ii - 1) * part_data_len / Fs;           % 起始时间 = (当前段索引 - 1) * 每段总长度 / 采样率
    sig_message(ii, 4) = sig_message(ii, 3) + part_sig_vector / Fs; % 结束时间 = 起始时间 + 信号段长度 / 采样率

    % --- 上变频处理 (使用该跳频段的 chosen_Fc) ---
    % 生成与当前跳频段对应的总信号长度 (part_data_len) 相同的一段载波信号 exp(j*2*pi*Fc*t)。
    % 载波的频率是该跳频段的中心频率 chosen_Fc。时间是从总时间序列 t 中截取的对应段。
    carrier_segment = exp(1i * 2 * pi * (chosen_Fc -rf)* t(((ii - 1) * part_data_len + 1) : (ii * part_data_len)));
    % 将包含保护间隔的基带信号 part_sig 乘以载波信号段，将频谱从基带搬移到 chosen_Fc。
    part_fc_sig = part_sig .* carrier_segment;

    sig(((ii - 1) * part_data_len + 1) : (ii * part_data_len)) =part_fc_sig;

end % 跳频信号生成主循环结束
    % nfft = 65536*16*2;
    % f_ = (Fs/nfft:Fs/nfft:Fs)-Fs/2;
    % figure
    % subplot 311
    % plot(real(sig(1:nfft)));
    % subplot 312
    % plot(f_,10*log10(fftshift(abs(fft(sig(1:nfft),nfft).^2))));
    % subplot 313
    % plot(f_,10*log10(fftshift(abs(fft(sig(1:nfft).^2,nfft).^2))));
%% 输出最终信号
FH_data = sig; % 将合成完成的总跳频信号赋给输出变量
 
%% 瀑布图参数转换
part_long = 20000; % 瀑布图分段长度(采样点数)
finally_message = tf_change(sig_message, part_long, nfft, Fs);

noverlap = 0;    
[S, F, T] = spectrogram(sig, nfft, noverlap, nfft, Fs, 'power', 'centered'); 
figure(); 
imagesc(T,F+rf,10*log10(abs(S))); 
colorbar;
xlabel('时间 (s)'); 
ylabel('频率 (Hz)'); 
title('信号时频图 (Spectrogram)');


%%
% 画图验证   原始代码
% part_long = 20000;
% water = get_waterfall(sig,part_long,nfft,Fs);
% figure()
% imagesc(water)
% fig_title = ['单站跳频信号'];
% title(fig_title);
% 
% target_min_freq_plot = 5740e6; % 绘制时显示的最小频率，略低于目标范围
% target_max_freq_plot = 5860e6; % 绘制时显示的最大频率，略高于目标范围
% freq_indices_to_keep = find(F >= target_min_freq_plot & F <= target_max_freq_plot);
% if isempty(freq_indices_to_keep)
%     warning('在指定的绘制频率范围 [%g Hz, %g Hz] 内没有找到FFT频率点。请检查频率范围设置和FFT点数。', target_min_freq_plot, target_max_freq_plot);
%      S_cropped = S;
%      F_cropped = F;
% else
%     S_cropped = S(freq_indices_to_keep, :); % 裁剪频谱数据到指定频率范围
%     F_cropped = F(freq_indices_to_keep);   % 裁剪频率向量
% end
% 
% 
% power_spectrum_magnitude = abs(S_cropped); % 取频谱图数据的幅度（通常是复数）
% water_db = 10*log10(power_spectrum_magnitude);
% figure(); % 创建一个新的图形窗口
% imagesc(T, F_cropped, water_db); % 使用 spectrogram 输出的时间向量 T 和裁剪后的频率向量 F_cropped 作为坐标轴
% axis xy;  % 翻转 Y 轴方向，使得频率从小到大向上排列 (标准频谱图显示方式)
% colorbar; % 添加颜色条，显示颜色对应的信号强度值（dB）
% noverlap = 0;    
% [S, F, T] = spectrogram(sig, nfft, noverlap, nfft, Fs, 'power', 'centered');
% figure(); 
% imagesc(10*log10(abs(S))); 
% % 添加颜色条，显示颜色对应的信号强度值（单位：dB）
% colorbar;
% % 设置横轴标签，包括单位
% xlabel('时间 (s)'); % 横轴表示信号经过的时间，单位 秒
% % 设置纵轴标签，包括单位
% ylabel('频率 (Hz)'); % 纵轴表示信号在该时刻的频率成分，单位 赫兹
% % 设置图的标题
% title('信号时频图 (Spectrogram)');
% 
% 

end 