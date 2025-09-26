% 信号强度估计
function out = strength_est(sig)

energy_total = abs(sum(sig));
len = length(sig);
out = energy_total / len;

end