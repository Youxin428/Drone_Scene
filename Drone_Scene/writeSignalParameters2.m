% writeSignalParameters.m - 精简并转换单位版
function writeSignalParameters2(save_path, para_file_name, signal_order_i, transmitter_id, parameters, Fs)
% WRITESIGNALPARAMETERS 将估计参数以格式化文本写入文件，并转换单位。
%
%   输入参数：
%   save_path: 存储文件的目录路径。
%   para_file_name: 参数文件的基本名称 (不含 .txt)。
%   signal_order_i: 信号顺序编号。
%   transmitter_id: 发射台站编号。
%   parameters: 包含估计参数的向量 [tdoa(samples), corr_peak, strength1(linear), strength2(linear), fc1(Hz), fc2(Hz), period1(samples), period2(samples)]。
%   Fs: 信号的采样频率 (Hz)，用于将采样点数转换为秒。

% 确保输入参数个数正确，特别是新增的 Fs
if nargin < 6
    error('writeSignalParameters 需要 6 个输入参数 (save_path, para_file_name, signal_order_i, transmitter_id, parameters, Fs)。');
end

% 构建参数文件的完整路径和文件名
full_file_path = fullfile(save_path, [para_file_name, '.txt']);

% 打开文件进行写入 ('wt' 模式表示写入文本文件)
file_id = fopen(full_file_path, 'wt');

% 检查文件是否成功打开
if file_id == -1
    % 如果打开失败，打印警告信息并退出函数
    warning('无法打开文件 %s 进行写入。请检查路径是否存在或权限是否允许。', full_file_path);
    return; % 文件打开失败则直接退出
end

% --- 文件成功打开，开始写入数据 ---

% 写入文件头，包含信号的顺序编号和发射台站信息
fprintf(file_id, 'Parameters for Signal Order %d (From Tx %d)\n', signal_order_i, transmitter_id);
fprintf(file_id, '------------------------------------------------\n'); % 写入一个分隔线

% 确保输入的 parameters 向量至少包含期望的参数数量 (这里是 8 个)
expected_num_params = 8;
if length(parameters) < expected_num_params
     warning('输入参数向量长度不足 (%d)。期望至少为 %d。文件 %s 可能不完整。', length(parameters), expected_num_params, full_file_path);
     % 即使长度不足，也尝试写入已有的参数，避免崩溃
end


% --- 参数单位转换 ---
% 检查 Fs 是否有效，避免除以零
if Fs <= 0
     warning('采样频率 Fs 必须为正数，无法进行时间单位转换。TDOA 和 Duration 将以采样点为单位记录在文件中。');
     % 如果 Fs 无效，我们不进行转换，并在下面写入时注明单位为采样点
     tdoa_s = parameters(1); % 不转换，保留采样点数
     period1_s = parameters(7); % 不转换，保留采样点数
     period2_s = parameters(8); % 不转换，保留采样点数
     tdoa_unit = 'samples (Fs invalid)';
     period_unit = 'samples (Fs invalid)';
else
     % 将采样点数转换为秒
     tdoa_s = parameters(1) / Fs;
     period1_s = parameters(7) / Fs;
     period2_s = parameters(8) / Fs;
     tdoa_unit = 'seconds';
     period_unit = 'seconds';
end


% --- 写入参数值及其单位 ---
% 确保参数索引不会超出实际的 parameters 向量长度
num_actual_params = length(parameters);

if num_actual_params >= 1; fprintf(file_id, 'TDOA: %g %s\n', tdoa_s, tdoa_unit); end % 时差 (转换为秒 或 采样点)
if num_actual_params >= 2; fprintf(file_id, 'Correlation Peak: %g normalized\n', parameters(2)); end % 互相关峰值 (归一化)
% 注意：Strength 单位仍为线性，请根据实际含义调整文件中的描述或进行转换
if num_actual_params >= 3; fprintf(file_id, 'Strength Rx1: %g linear\n', parameters(3)); end % 接收站1 信号强度 (线性)
if num_actual_params >= 4; fprintf(file_id, 'Strength Rx2: %g linear\n', parameters(4)); end % 接收站2 信号强度 (线性)
if num_actual_params >= 5; fprintf(file_id, 'Center Frequency Rx1: %g Hz\n', parameters(5)); end % 接收站1 中心频率估计 (Hz)
if num_actual_params >= 6; fprintf(file_id, 'Center Frequency Rx2: %g Hz\n', parameters(6)); end % 接收站2 中心频率估计 (Hz)
if num_actual_params >= 7; fprintf(file_id, 'Duration Rx1: %g %s\n', period1_s, period_unit); end % 接收站1 持续时间估计 (转换为秒 或 采样点)
if num_actual_params >= 8; fprintf(file_id, 'Duration Rx2: %g %s\n', period2_s, period_unit); end % 接收站2 持续时间估计 (转换为秒 或 采样点)


% --- 关闭文件 ---
fclose(file_id);

% 函数执行完毕。

end % 函数结束