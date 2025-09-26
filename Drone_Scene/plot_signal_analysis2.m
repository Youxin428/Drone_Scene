function plot_signal_analysis2(signalVector, Fs, plot_part_long, nfft, rf, plotTitleSuffix)
% plot_signal_analysis - 最终精简版：绘制信号局部分析图和时频图
% 绘制信号向量局部 (前 nfft 采样点) 的时域波形、幅度谱、平方信号幅度谱
% 以及整个信号的时频图（Spectrogram）。
% 输入参数：
%   signalVector: 输入的信号向量。
%   Fs: 信号的采样频率 (Hz)。
%   plot_part_long: 用于计算频谱图时的窗口长度（采样点数）。
%   nfft: 用于局部频谱分析的FFT点数，也是局部时域波形长度。
%   rf: 频率偏移量，添加到频谱图的频率轴上 (Hz)。
%   plotTitleSuffix: 图标题的后缀。

    L = length(signalVector); % 信号总长度

    % 检查信号是否为空，为空则不绘图并退出
    if L == 0
        warning('Input signalVector is empty. No plots generated for "%s".', plotTitleSuffix);
        return;
    end

    % % --- 绘制信号局部分析图 (3个子图) ---
    % % 确定用于局部分析的信号段长度 (不超过信号总长)
    % segment_length = min(L, nfft);
    % 
    % % 创建新的图窗用于局部分析图
    % figure('Name', ['信号局部分析图 - ', plotTitleSuffix]);
    % 
    % % 计算用于局部频谱分析的频率向量
    % f_ = (Fs/nfft : Fs/nfft : Fs) - Fs/2;
    % 
    % % 子图 1: 局部时域波形 (实部)
    % subplot(3,1,1);
    % time_vec_segment = (0 : segment_length - 1) / Fs; % 局部时间向量
    % plot(time_vec_segment, real(signalVector(1:segment_length)));
    % title(['局部时域波形 (实部) - ', plotTitleSuffix]);
    % xlabel('时间 (秒)');
    % ylabel('幅度');
    % % grid on; % 移除网格线
    % 
    % % 子图 2: 局部幅度谱
    % subplot(3,1,2);
    % if segment_length > 0 % 只有有有效信号段时才计算和绘制频谱
    %     plot(f_, 10*log10(fftshift(abs(fft(signalVector(1:segment_length), nfft)).^2)));
    %     title(['局部幅度谱 - ', plotTitleSuffix]);
    %     xlabel('频率 (Hz)');
    %     ylabel('功率/频率 (dB/Hz)');
    %     % grid on; % 移除网格线
    % else
    %     plot(f_, zeros(size(f_))); % 绘制零线占位
    %     title('局部幅度谱 (信号太短) - ', plotTitleSuffix);
    %     xlabel('频率 (Hz)');
    %     ylabel('功率/频率 (dB/Hz)');
    % end
    % 
    % % 子图 3: 局部平方信号幅度谱
    % subplot(3,1,3);
    %  if segment_length > 0
    %     plot(f_, 10*log10(fftshift(abs(fft(signalVector(1:segment_length).^2, nfft)).^2)));
    %     title(['局部平方信号幅度谱 - ', plotTitleSuffix]);
    %     xlabel('频率 (Hz)');
    %     ylabel('功率/频率 (dB/Hz)');
    %     % grid on; % 移除网格线
    %  else
    %     plot(f_, zeros(size(f_))); % 绘制零线占位
    %     title('局部平方信号幅度谱 (信号太短) - ', plotTitleSuffix);
    %     xlabel('频率 (Hz)');
    %     ylabel('功率/频率 (dB/Hz)');
    %  end

    % --- 绘制整个信号的时频图（Spectrogram） ---
    % 检查信号长度是否足够进行 Spectrogram 分析 (至少等于窗口长度)
    if L >= plot_part_long
        figure('Name', ['时频图 - ', plotTitleSuffix]);

        % 计算 Spectrogram 数据 (无重叠)
        noverlap = 0;
        [S, F, T] = spectrogram(signalVector, plot_part_long, noverlap, nfft, Fs, 'power', 'centered');

        % 绘制时频图，频率轴加上偏移量 rf
        imagesc(T, F + rf, 10*log10(abs(S)));

        % 设置坐标轴方向、颜色条、标签和标题
        axis xy; % 标准时频图方向
        colorbar;
        xlabel('时间 (秒)');
        ylabel('频率 (Hz)');
        title(['时频图 - ', plotTitleSuffix]);

        % 设置颜色映射
        colormap('parula');
    end
end