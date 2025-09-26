% 信号功率调整函数
% 功能：将输入信号的功率调整到指定的目标功率值
% 输入参数：
%   sig         : 输入信号（复数或实数）
%   target_power: 目标功率值（线性功率值，非dB单位）
% 输出参数：
%   out         : 功率调整后的信号

function out = set_sig_power(sig,target_power)

sig_len = length(sig);
sig_power_std_power = sum(abs(sig).^2)/sig_len; % 计算信号平均功率：P = (Σ|x[n]|²)/N
sig = sig*(sqrt(1/sig_power_std_power));
out = sig*sqrt(target_power);

end