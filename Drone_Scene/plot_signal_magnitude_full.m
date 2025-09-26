% plot_signal_magnitude_full.m - 绘制完整信号向量的幅度（包络）

function plot_signal_magnitude_full(fullSignalVector, Fs, plotTitleSuffix)
% PLOT_SIGNAL_MAGNITUDE_FULL 绘制整个输入信号向量的幅度（包络）随时间变化的曲线。
%   plot_signal_magnitude_full(fullSignalVector, Fs, plotTitleSuffix)
%   此函数计算输入信号向量 fullSignalVector 的幅度 (abs)，并绘制整个信号的幅度随时间的变化曲线。
%   用于显示信号的整体幅度包络。
%
%   输入参数：
%   fullSignalVector: 输入的完整信号向量 (可以是实数或复数)。
%   Fs: 信号的采样频率 (Hz)。
%   plotTitleSuffix: 图标题的后缀，用于区分（如 '加噪声前完整信号幅度'）。

    % 获取输入信号向量的长度（采样点数）
    signalLength = length(fullSignalVector);

    % 如果信号长度为零，则无法绘制，打印警告并返回
    if signalLength == 0
        warning('Input fullSignalVector is empty. No plot generated.');
        return;
    end

    % 创建完整信号的时间向量（从时间 0 开始）
    % 时间向量的长度与信号向量相同
    time_vec = (0:signalLength-1)/Fs;

    % --- 计算并绘制幅度波形 ---
    % 计算信号的幅度（包络）。对于复数 z = x + iy，幅度是 |z| = sqrt(x^2 + y^2)。
    % abs 函数可以处理实数和复数输入。
    magnitude_to_plot = abs(fullSignalVector);

    % 创建一个新的图窗来显示完整信号的幅度波形图
    figure();

    % 绘制幅度随时间的变化波形。幅度是实数，所以只有一条曲线。
    plot(time_vec, magnitude_to_plot);

    % === 修改横坐标标签为中文，标注单位 ===
    xlabel('时间 (秒)');
    % === 修改纵坐标标签为中文，标注单位 ===
    ylabel('幅度'); % 幅度通常没有固定的单位，取决于信号的原始单位（如伏特）

    % === 修改图的标题为中文 ===
    % 标题会包含描述信息（如 '加噪声前完整信号幅度'）
    title(['信号幅度 (包络) - ', plotTitleSuffix]);

    % 添加网格线
    grid on;

    % 函数执行完毕。绘制完成后图窗会显示。
end