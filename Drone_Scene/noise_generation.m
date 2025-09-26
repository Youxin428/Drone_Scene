% �������壺����ָ�����Ⱥ͹��ʵĸ�˹������
% function [noise, noise_power_compute] = noise_generation(data_long, noise_power)
% data_long����Ҫ���ɵ����������ĳ��ȣ�����������
% noise_power���������ɵ�������ƽ�����ʣ�����ֵ������ dBm��
% noise�����ɵ�����������ͨ���Ǹ�����
% noise_power_compute����������������ɵ�������ƽ�����ʣ�������֤��
function [noise, noise_power_compute] = noise_generation(data_long, noise_power)
% ��������
noise = randn(1,data_long)+1i*randn(1,data_long);
noise = noise-mean(noise);
noise = noise/std(noise);
noise_std_power = sum(abs(noise).^2)/data_long;
noise = (sqrt(1/noise_std_power))*noise;
noise = noise*sqrt(noise_power);
noise_power_compute = sum(abs(noise).^2)/length(noise);

end