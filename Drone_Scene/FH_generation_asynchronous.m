%% 异步跳频信号生成函数
% 输入参数：
%   SNR - 信噪比(dB)
%   noise_power - 噪声功率(dBm)
%   nfft - FFT点数
%   data_long - 总信号长度(采样点数)
%   number - 发射台站编号
% 输出参数：
%   FH_data - 生成的跳频信号
%   Fc_rand - 随机选择的载频序列
%   finally_message - 转换后的瀑布图索引标注信息
%   sig_message - 原始信号参数信息
%   part_long - 瀑布图分段长度

function [FH_data, Fc_rand, finally_message, sig_message, part_long] = FH_generation_asynchronous(Fs, Fd, SNR, ...
    noise_power, nfft, data_long, number)

t = (0:data_long-1)/Fs; % 生成时间序列(单位：秒)

% 跳频频率池生成
% 填充固定的跳频信号
%     Fc = 10e3:20e3:20e6;
fc_num = 200; % 候选频率点数量 500
Fc = get_fc_point(5750e6,5850e6,fc_num); % 在0-20MHz范围内生成均匀分布的候选频率点

%信号参数初始化
sig = zeros(1,data_long); % 初始化全零信号向量
part_sig_vector = [200000, 250000, 300000, 350000, 400000, 450000, 500000, 600000]; % 可选信号段长度(采样点数)
num1 = randi([1,8]); % 随机选择信号段长度索引
part_interval_vector = [20000, 30000, 40000, 50000, 60000]; % 可选保护间隔长度
num2 = randi([1,5]); % 随机选择保护间隔索引

%确定跳频段参数
part_sig_len = part_sig_vector(num1);       % 有效信号段长度(例如200000点对应4ms@50MHz采样)
part_interval = part_interval_vector(num2); % 保护间隔长度
part_data_len = part_sig_len+part_interval; % 单段总长度(信号+间隔)
sig_num = floor(data_long/part_data_len);   % 计算可容纳的完整跳频段数

% 跳频频率序列生成
Fc_rand = get_rand_fc(Fc,sig_num); % 从候选频率中随机选择sig_num个作为载频序列

% 功率计算
sig_power = noise_power * 10^(SNR/10); % 根据SNR计算需要的信号功率
% 原理：SNR(dB) = 10*log10(Ps/Pn) => Ps = Pn*10^(SNR/10)

%% 信号段信息矩阵初始化
sig_message = zeros(sig_num,4); % 列定义：[载频, 带宽, 起始时间, 结束时间]

%% 跳频信号生成主循环
for ii = 1:sig_num
    % 基带信号生成
    base_sig = get_bpsk(part_sig_len,Fd,Fs);
    % 功率调整
    base_sig = set_sig_power(base_sig,sig_power); 
    % 段信号封装
    part_sig = zeros(1,part_data_len);   % 初始化段信号(含保护间隔)
    part_sig(1:part_sig_len) = base_sig; % 前部填充有效信号
    % 记录信号参数
    sig_message(ii,1) = Fc_rand(ii); % 载频(Hz)
    sig_message(ii,2) = 1.306*Fd;    % 信号带宽(Hz) % 升余弦滚降系数α=0.306
    sig_message(ii,3) = (ii-1)*part_data_len/Fs;           % 起始时间(s)
    sig_message(ii,4) = sig_message(ii,3)+part_sig_len/Fs; % 结束时间(s)
    % 上变频处理
    carrier = exp(1i*2*pi*Fc_rand(ii)*t((ii-1)*part_data_len+1:ii*part_data_len));  % 生成载频信号：exp(1i*2πfct)
    part_fc_sig = part_sig.*carrier; % 频谱搬移至载频
    
    % 信号合成
    sig((ii-1)*part_data_len+1:ii*part_data_len) = sig((ii-1)*part_data_len+1:ii*part_data_len)+part_fc_sig;
end
%% 输出最终信号
FH_data = sig; % 组合完成的跳频信号

%%
% 画图验证   原始代码
% part_long = 2000;
% water = get_waterfall(sig,part_long,nfft,Fs);
% figure()
% imagesc(water)
% fig_title = ['单站跳频信号'];
% title(fig_title);


%%  画图验证  更新优化后的
part_long = 2000; % 定义用于生成瀑布图时，进行FFT分析的窗口长度 (采样点数)
noverlap = 0;     % 设置相邻窗口之间不重叠，以模仿原 get_waterfall 的行为
[S, F, T] = spectrogram(sig, part_long, noverlap, nfft, Fs, 'power', 'centered');
target_min_freq = 0; % 目标最小频率 (0 Hz)
target_max_freq = Fs/2 * (20/25); % 目标最大频率 (Fs/2 的 20/25 倍 = 0.4 * Fs)
freq_indices_to_keep = find(F >= target_min_freq & F <= target_max_freq);

S_cropped = S(freq_indices_to_keep, :); 
F_cropped = F(freq_indices_to_keep);
power_spectrum_magnitude = abs(S_cropped); 
max_value = max(power_spectrum_magnitude(:)); 

% 对幅度矩阵进行归一化处理，然后乘以 10
% 这结果就是最终用于显示的 water 矩阵，它现在是实数。
water = (power_spectrum_magnitude ./ max_value) * 10;

figure() % 创建一个新的图形窗口
% 使用 imagesc 函数显示瀑布图数据。
% imagesc(X, Y, C) 中，X 对应列（横轴）的坐标，Y 对应行（纵轴）的坐标。
% water 矩阵的列对应时间 (T)，行对应裁剪后的频率 (F_cropped)。
imagesc(T, F_cropped, water); % 使用 spectrogram 输出的时间向量 T 和裁剪后的频率向量 F_cropped 作为坐标轴
axis xy;  % 翻转 Y 轴方向，使得频率从小到大向上排列 (标准频谱图显示方式)
colorbar; % 添加颜色条，显示颜色对应的强度值
xlabel('时间 (s)'); 
ylabel('频率 (Hz)'); 
fig_title = '单站跳频信号'; 
title(fig_title); 

%% 瀑布图参数转换
part_long = 2000; % 瀑布图分段长度(采样点数)
finally_message = tf_change(sig_message,part_long,nfft,Fs);  % 格式为 [起始频率索引, 终止频率索引, 起始时间索引, 终止时间索引]
% 将物理参数转换为瀑布图索引：
% [起始频率bin, 结束频率bin, 起始时间帧, 结束时间帧]

% finally_message(:,1:2) = finally_message(:,1:2)-nfft/2;

% draw_out(finally_message,'-r')
% 这里面finally_message存储列的物理意义为
% 第一列为信号的左边界索引值
% 第二列为信号的右边界索引值
% 第三列为信号的上边界索引值
% 第四列为信号的下边界索引值

end