% 函数定义：从一个复合信号中提取并处理一个特定的信号跳变段（脉冲）。
% [out] = sig_depart(sig, Fs, ori_message, len)
% 输入参数:
% sig: 输入的复合信号向量。这通常是接收站接收到的、包含多个信号叠加和噪声的总信号 (例如 finally_data_rec1 或 finally_data_rec2)。
% Fs: 信号的采样频率 (Hz)。
% ori_message: 包含要提取的信号跳变段参数的行向量。通常来自 ori_message_mul，其列包含了该跳变段的起始/结束采样点和频率信息。
% len: 期望的输出信号段长度（以采样点为单位）。通常是所有信号跳变段的最大长度或其他标准长度。
% 输出参数:
% out: 提取并处理（滤波并可能搬回原载频）后的信号跳变段向量。


function [out] = sig_depart(sig, Fs, ori_message, len)
%% --- 时域截取 ---
% 从输入的 ori_message 中提取该信号跳变段的起始和结束时间点（以采样点为单位）。
t_start = ori_message(3); % 获取该信号段在输入信号向量 sig 中的起始采样点索引。
t_end = ori_message(4);   % 获取该信号段在输入信号向量 sig 中的结束采样点索引。

% if len > t_end - t_start
%     sig_temp = sig(t_start : t_start + len - 1);
% elseif len ~= 0
%     sig_temp = sig(t_start : t_start + len - 1);
% else
%     sig_temp = sig(t_start : t_end - 1);
% end

% sig_temp = sig(t_start : t_end - 1);

if len < t_end - t_start
    sig_temp = sig(t_start : t_start + len - 1);
else
    sig_temp = sig(t_start : t_end - 1);
end

%% 频域滤波
Fc = (ori_message(1) + ori_message(2)) / 2; % 计算信号跳变段的中心频率 (Hz)。
B = ori_message(2) - ori_message(1);        % 计算信号跳变段的带宽 (Hz)。
% 变换到基带
% 创建一个与截取出的信号段 sig_temp 长度相同的时间向量，表示相对时间，用于后续的频率搬移。
t_slot = (1/Fs:1/Fs:length(sig_temp)/Fs); % 时间向量，从 1/Fs 开始，步长 1/Fs，到信号段的持续时间
% 将截取出的信号段 sig_temp (通常是射频或中频信号) 乘以一个负载频的复指数 (exp(-j*2*pi*Fc*t))。
% 这个操作将信号的中心频率 Fc 搬移到 0 Hz，得到信号的基带表示 sig_base。
sig_base = sig_temp .* exp(1i*2*pi*Fc*t_slot*-1);




% 选择滤波器，低通滤波
% [filter, filter_name] = getFilter(Fs, B);
% sig_base_filtered = conv(sig_base,filter);
% sig_handle = sig_base_filtered(ceil(length(filter)/2):end-floor(length(filter)/2));
sig_handle = FFT_lowpass(Fs,B,sig_base);

% 搬回原载频
out = sig_handle .* exp(1i*2*pi*Fc*t_slot);
% out = sig_handle;

% % 画时域波形图
% t_figure = (0 : 1/length(out) : (length(out)-1)/length(out));
% figure()
% plot(t_figure, real(out));
% % 画频谱图
% f_figure = (0:Fs/length(out):Fs*(length(out)-1)/length(out)) - Fs/2;
% figure()
% plot(f_figure, fftshift(abs(fft(out))));

end