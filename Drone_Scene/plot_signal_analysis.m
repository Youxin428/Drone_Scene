% plot_signal_analysis.m

% plot_signal_analysis.m - 绘制信号幅度包络和频谱图（时频图），分别绘制在不同的图窗中，包含健壮性检查。

function plot_signal_analysis(signalVector, Fs, plot_part_long, nfft, rf,plotTitleSuffix)
% PLOT_SIGNAL_ANALYSIS 绘制信号向量的幅度包络图和频谱图（时频图），分别绘制在不同的图窗中。
%   此函数为信号提供两种重要的可视化视图，并包含对输入参数的基本检查。
%
%   输入参数：
%   signalVector: 输入的信号向量 (可以是实数或复数)。
%   Fs: 信号的采样频率 (Hz)。必须是正数。
%   plot_part_long: 用于计算频谱图时的窗口长度（采样点数）。必须是正整数。
%   nfft: 用于计算频谱图时的FFT点数。必须是正整数。
%   plotTitleSuffix: 图标题的后缀，用于区分是哪个信号状态。通常是一个字符串。

    % 获取输入信号向量的长度
    L = length(signalVector);

    % --- 输入参数基本检查 ---
    if L == 0
        warning('Input signalVector is empty. No plots generated for "%s".', plotTitleSuffix);
        return; % 如果信号为空，直接退出函数，不进行任何绘制
    end
    if Fs <= 0 || ~isscalar(Fs) || ~isnumeric(Fs)
        warning('Invalid sampling frequency Fs = %f. Fs must be a positive scalar. No plots generated for "%s".', Fs, plotTitleSuffix);
        return; % Fs 无效则退出
    end
    if plot_part_long <= 0 || ~isscalar(plot_part_long) || ~isnumeric(plot_part_long) || mod(plot_part_long, 1) ~= 0
         warning('Invalid window length plot_part_long = %f. Must be a positive integer scalar. No spectrogram plot generated for "%s".', plot_part_long, plotTitleSuffix);
         % 如果窗口长度无效，不阻止绘制幅度图，但后续的频谱图会跳过
         plot_part_long_valid = false;
    else
         plot_part_long_valid = true;
    end
     if nfft <= 0 || ~isscalar(nfft) || ~isnumeric(nfft) || mod(nfft, 1) ~= 0
         warning('Invalid nfft = %f. Must be a positive integer scalar. No spectrogram plot generated for "%s".', nfft, plotTitleSuffix);
         % 如果 nfft 无效，不阻止绘制幅度图，但后续的频谱图会跳过
         nfft_valid = false;
     else
         nfft_valid = true;
     end
     if ~ischar(plotTitleSuffix) && ~isstring(plotTitleSuffix)
         warning('Invalid plotTitleSuffix type. Expected string or character array. Using default title prefix for "%s".', plotTitleSuffix);
         plotTitleSuffix = char(plotTitleSuffix); % 尝试转换为字符数组
         if ~ischar(plotTitleSuffix) && ~isstring(plotTitleSuffix) % 如果转换失败
              plotTitleSuffix = ''; % 使用空字符串
         end
     end

    % --- 绘制幅度波形（独立图窗） ---

    % --- 创建一个新的图窗用于幅度图 ---
    % 使用 figure('Name', ...) 可以为图窗设置标题，方便区分
    figure('Name', ['信号幅度图 - ', plotTitleSuffix]);

    % 创建完整信号的时间向量（从时间 0 开始）
    time_vec = (0:L-1)/Fs;

    % 计算信号的幅度（包络）。abs 函数可以处理实数和复数输入。
    magnitude_to_plot = abs(signalVector);

    % 绘制幅度随时间的变化波形
    plot(time_vec, magnitude_to_plot);

    % 设置 x 轴标签为时间 (秒)，包含单位
    xlabel('时间 (秒)');
    % 设置 y 轴标签为幅度 (Amplitude / Envelope)
    ylabel('幅度');
    % 设置图的标题
    title(['信号幅度 (包络) - ', plotTitleSuffix]);
    % 添加网格线
    grid on;


    % --- 计算并绘制频谱图（独立图窗，条件绘制） ---

    % 检查信号长度是否足够进行频谱图分析，并且频谱图相关参数是否有效
    % 信号长度必须至少等于窗口长度
    if plot_part_long_valid && nfft_valid && (L >= plot_part_long)
        % --- 创建一个新的图窗用于频谱图 ---
        figure('Name', ['时频图 - ', plotTitleSuffix]); % 为频谱图创建独立图窗，并设置图窗名称

        % 使用 spectrogram 函数计算信号的频谱图数据。
        % spectrogram(signal_vector, window, noverlap, nfft, Fs, 'power', 'centered')
        % signal_vector: 输入信号
        % plot_part_long: 窗口长度 (这里使用矩形窗，长度为 plot_part_long)
        % 0: 窗口之间无重叠 (模拟原 get_waterfall 的分块处理)
        % nfft: FFT 点数
        % Fs: 采样率
        % 'power': 计算功率谱密度 (PSD) 或功率谱。
        % 'centered': 频率轴 F 是中心化的 (-Fs/2 到 Fs/2)。
        noverlap = 0;
        % 使用双精度以避免潜在的数值问题，特别是对于大型信号
        [S, F, T] = spectrogram(double(signalVector), plot_part_long, noverlap, nfft, double(Fs), 'power', 'centered');

        % 将计算出的频谱图数据 S 显示为图像。
        % 使用 imagesc(X, Y, C) 函数，其中 X 是列坐标，Y 是行坐标，C 是要显示的矩阵数据。
        % spectrogram 输出的 S 矩阵的列对应时间 (T)，行对应频率 (F)。
        % 取其幅度 abs(S) 并转换为 dB 刻度 10*log10(...)。
        imagesc(T, F+rf, 10*log10(abs(S)));

        % 设置坐标轴方向。axis xy 使 y 轴从下往上增加（低频在下，高频在上）。
        axis xy;
        % 添加颜色条，用于显示颜色与信号强度（dB）的对应关系。
        colorbar;

        % 设置 x 轴标签为时间 (秒)
        xlabel('时间 (秒)');
        % 设置 y 轴标签为频率 (Hz)，包含单位
        ylabel('频率 (Hz)');
        % 设置图的标题
        title(['时频图 - ', plotTitleSuffix]);

        % --- 应用标准颜色映射 ---
        % 使用时频图或其他科学可视化中常见的、对比更明显的标准颜色映射。
        % 'parula' 是 MATLAB 默认的、感知均匀性较好的颜色映射，通用性好。
        % 'viridis' 是另一种广泛推荐的感知均匀颜色映射，颜色过渡平滑且对比度好。
        % 'hot' 颜色映射 (从黑 -> 红 -> 黄 -> 白) 能很好地突出高强度区域（信号）。
        % 'jet' 颜色映射 (从蓝 -> 绿 -> 黄 -> 红) 是经典颜色映射。

        % **您可以根据需要选择以下其中一个颜色映射：**
         colormap('parula'); % 默认使用 parula

%         colormap('viridis'); % 或者使用 viridis
%         colormap('hot');     % 或者使用 hot
%         colormap('jet');     % 或者使用 jet

        % --- 颜色映射设置结束 ---


    else
        % 如果信号太短或频谱图参数无效，跳过频谱图绘制，打印警告已在上面给出
        % 不创建第二个图窗。
    end

    % 函数执行完毕。绘制完成后图窗会显示。
end