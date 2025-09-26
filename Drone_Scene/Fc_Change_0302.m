function sig_handle = Fc_Change_0302(sig, Fs, Fc)
    % 频移函数，将复信号 sig 按 Fc 进行变频
    % sig: 复数信号（列向量或行向量）
    % Fs: 采样率
    % Fc: 频率偏移量（正值下变频，负值上变频）
    % 返回: 变频后的复数信号 sig_handle
    
    len = length(sig);
    dt = 1 / Fs;
    t = (0:len-1)* dt; % 生成时间索引，确保是列向量
    
    % 计算变频因子
    phase_shift = exp(-1j * 2 * pi * Fc * t);
    
    % 进行变频
    sig_handle = sig .* phase_shift;
end