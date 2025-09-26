% writeSignalParameters.m

function writeSignalParameters(save_path, para_file_name, signal_order_i, transmitter_id, parameters)
% WRITESIGNALPARAMETERS 将单个信号跳变段的估计参数以格式化文本写入文件。
%   writeSignalParameters(save_path, para_file_name, signal_order_i, transmitter_id, parameters)
%   为特定的信号跳变段创建一个文本文件，并将估计的参数以人类可读的格式写入其中。
%
%   输入参数：
%   save_path: 存储文件的目录路径 (字符串)。例如 'D:\data\results\'。
%   para_file_name: 参数文件的基本名称 (不含 .txt 扩展名) (字符串)。例如 'parameter_order_1_transmit_3'。
%   signal_order_i: 信号在融合并排序列表中的顺序编号 (整数)。用于文件头中的 'Signal Order'。
%   transmitter_id: 该信号所属的发射台站的编号 (整数)。用于文件头中的 'From Tx'。
%   parameters: 包含估计参数的行向量 [tdoa, corr_peak, strength1, strength2, fc1, fc2, period1, period2]。应有8个元素。

% 构建参数文件的完整路径和文件名
% 使用 fullfile 函数可以确保路径分隔符在不同操作系统中正确。
% 文件的完整名称是由 save_path, para_file_name 和 .txt 扩展名组成的。
full_file_path = fullfile(save_path, [para_file_name, '.txt']);

% 打开文件进行写入 (使用 'wt' 模式表示写入文本文件)
file_id = fopen(full_file_path, 'wt');

% 检查文件是否成功打开
if file_id == -1
    % 如果文件打开失败 (例如，路径不存在或没有写入权限)，打印警告信息。
    warning('无法打开文件 %s 进行写入。请检查路径是否存在或权限是否允许。', full_file_path);
else
    % 文件成功打开，开始写入格式化数据

    % 写入文件头，包含信号的顺序编号和发射台站信息，增强文件的可读性。
    header_line = sprintf('Parameters for Signal Order %d (From Tx %d)', signal_order_i, transmitter_id);
    fprintf(file_id, '%s\n', header_line); % 写入文件头，后面加一个换行符 \n
    % 写入一个分隔线，与文件头的长度相同，用于视觉分隔。
    fprintf(file_id, '%s\n', repmat('-', 1, length(header_line))); % repmat('-', 1, N) 创建一个包含 N 个 '-' 的字符串

    % 检查输入参数向量长度，确保正确读取
    expected_num_params = 8; % 根据 finally_para 的定义，期望的参数数量是 8 个
    if length(parameters) ~= expected_num_params
         % 如果输入的参数向量长度不正确，打印警告，并尝试写入已知的前 expected_num_params 个参数。
         warning('输入参数向量长度不正确 (%d)。期望长度为 %d。文件 %s 中部分参数可能不完整。', length(parameters), expected_num_params, full_file_path);
         num_params_to_write = min(length(parameters), expected_num_params); % 实际可写入的参数数量
    else
         num_params_to_write = expected_num_params; % 长度正确，写入所有参数
    end

    % 逐行写入每个参数的含义、值和单位
    % 使用 fprintf 向文件 file_id 写入格式化字符串。
    % %g 格式化数值，自动选择合适的显示方式（定点或科学计数法）。
    % \n 换行符。
    % 通过条件判断确保只写入实际存在的参数。
    if num_params_to_write >= 1; fprintf(file_id, 'TDOA: %g samples\n', parameters(1)); end % 时差 (采样点)
    if num_params_to_write >= 2; fprintf(file_id, 'Correlation Peak: %g normalized\n', parameters(2)); end % 互相关峰值 (归一化幅度)
    % 注意：这里假定 strength1/strength2 是线性值。如果它们是 dB 值，请将 'linear' 替换为 'dB'。
    if num_params_to_write >= 3; fprintf(file_id, 'Strength Rx1: %g linear\n', parameters(3)); end % 接收站1 信号强度
    if num_params_to_write >= 4; fprintf(file_id, 'Strength Rx2: %g linear\n', parameters(4)); end % 接收站2 信号强度
    if num_params_to_write >= 5; fprintf(file_id, 'Center Frequency Rx1: %g Hz\n', parameters(5)); end % 接收站1 中心频率估计 (Hz)
    if num_params_to_write >= 6; fprintf(file_id, 'Center Frequency Rx2: %g Hz\n', parameters(6)); end % 接收站2 中心频率估计 (Hz)
    if num_params_to_write >= 7; fprintf(file_id, 'Duration Rx1: %g samples\n', parameters(7)); end % 接收站1 持续时间估计 (采样点)
    if num_params_to_write >= 8; fprintf(file_id, 'Duration Rx2: %g samples\n', parameters(8)); end % 接收站2 持续时间估计 (采样点)

    % 写入一个额外的空行，增强文件末尾的可读性。
    fprintf(file_id, '\n');

    % 关闭文件，释放资源并确保数据写入磁盘。
    fclose(file_id);
end

% 函数执行完毕。
end