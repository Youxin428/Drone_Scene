% TDOA估计（相关性最大时的t，就是时间差）
function [corr_val, out, mean_acor] = TD_est(sig1, sig2)
 
% [acor, lag] = xcorr(sig1, sig2);  原始方法
[acor, lag] = xcorr(sig1, sig2, 'coeff'); % 使用 'coeff' 进行归一化 (或者可以使用 'normalized')

mean_acor = mean(abs(acor));
[maximum, I] = max(abs(acor));
lagDiff = lag(I);

corr_val = maximum;
out = lagDiff;

% 画图并标注最大值点
% figure()
% plot(lag, acor);
% hold on;
% plot(out, corr_val, 'ro', 'MarkerSize', 5, 'MarkerFaceColor','r');
% title('信号互相关结果', 'FontSize', 10.5, 'FontName', '宋体');
% xlabel('时间');
% ylabel('互相关幅度');
% set(gca, 'FontSize', 10.5, 'FontName', '宋体');




%% --- 优化 2 & 3: 绘制互相关绝对值曲线并标注峰值 ---
% figure();
% plot(lag, abs(acor)); 
% hold on;
% plot(out, corr_val, 'ro', 'MarkerSize', 5, 'MarkerFaceColor','r');
% title('信号互相关结果', 'FontSize', 10.5, 'FontName', '宋体');
% xlabel('时延 (采样点)'); 
% ylabel('归一化互相关幅度');
% set(gca, 'FontSize', 10.5, 'FontName', '宋体');
% hold off;


end