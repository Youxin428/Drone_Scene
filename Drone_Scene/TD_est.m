% TDOA���ƣ���������ʱ��t������ʱ��
function [corr_val, out, mean_acor] = TD_est(sig1, sig2)
 
% [acor, lag] = xcorr(sig1, sig2);  ԭʼ����
[acor, lag] = xcorr(sig1, sig2, 'coeff'); % ʹ�� 'coeff' ���й�һ�� (���߿���ʹ�� 'normalized')

mean_acor = mean(abs(acor));
[maximum, I] = max(abs(acor));
lagDiff = lag(I);

corr_val = maximum;
out = lagDiff;

% ��ͼ����ע���ֵ��
% figure()
% plot(lag, acor);
% hold on;
% plot(out, corr_val, 'ro', 'MarkerSize', 5, 'MarkerFaceColor','r');
% title('�źŻ���ؽ��', 'FontSize', 10.5, 'FontName', '����');
% xlabel('ʱ��');
% ylabel('����ط���');
% set(gca, 'FontSize', 10.5, 'FontName', '����');




%% --- �Ż� 2 & 3: ���ƻ���ؾ���ֵ���߲���ע��ֵ ---
% figure();
% plot(lag, abs(acor)); 
% hold on;
% plot(out, corr_val, 'ro', 'MarkerSize', 5, 'MarkerFaceColor','r');
% title('�źŻ���ؽ��', 'FontSize', 10.5, 'FontName', '����');
% xlabel('ʱ�� (������)'); 
% ylabel('��һ������ط���');
% set(gca, 'FontSize', 10.5, 'FontName', '����');
% hold off;


end