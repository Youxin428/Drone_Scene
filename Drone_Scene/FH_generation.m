function [FH_data, Fc_rand, finally_message, sig_message, part_long] = FH_generation(Fs, Fd, SNR, noise_power, nfft, data_long)

t = (0:data_long-1)/Fs;
f = (0:Fs/nfft:(nfft-1)*Fs/nfft)-Fs/2;

% ���̶�����Ƶ�ź�
%     Fc = 10e3:20e3:20e6;
fc_num = 200;%500
Fc = get_fc_point(0,20e6,fc_num);
sig = zeros(1,data_long);
part_sig_len = 200000; % 20000 �źų���0.0004s   0.04s
part_interval = 50000; % 5000 �źż�ʱ��ı������0.0001s  0.01s
part_data_len = part_sig_len+part_interval;
sig_num = data_long/part_data_len;
Fc_rand = get_rand_fc(Fc,sig_num);
sig_power = noise_power * 10^(SNR/10); % Ϊ��������ȣ��źŹ���Ӧ�õ�ֵ
sig_message = zeros(sig_num,4);

for ii = 1:sig_num
    base_sig = get_bpsk(part_sig_len,Fd,Fs);
    base_sig = set_sig_power(base_sig,sig_power);
    part_sig = zeros(1,part_data_len);
    part_sig(1:part_sig_len) = base_sig;
    
    sig_message(ii,1) = Fc_rand(ii);
    sig_message(ii,2) = 1.306*Fd;
    sig_message(ii,3) = (ii-1)*part_data_len/Fs;
    sig_message(ii,4) = sig_message(ii,3)+part_sig_len/Fs;
    
    part_fc_sig = part_sig.*exp(1i*2*pi*Fc_rand(ii)*t((ii-1)*part_data_len+1:ii*part_data_len));
    sig((ii-1)*part_data_len+1:ii*part_data_len) = sig((ii-1)*part_data_len+1:ii*part_data_len)+part_fc_sig; %������̨վ�������ź�
end

FH_data = sig;

% ��ͼ��֤
part_long = 2000;
% water = get_waterfall(sig,part_long,nfft,Fs);
% figure()
% imagesc(water)
% fig_title = ['��վ��Ƶ�ź�'];
% title(fig_title);

finally_message = tf_change(sig_message,part_long,nfft,Fs); % ����ʵ����ת��Ϊ����
% finally_message(:,1:2) = finally_message(:,1:2)-nfft/2;

% draw_out(finally_message,'-r')
% ������finally_message�洢�е���������Ϊ
% ��һ��Ϊ�źŵ���߽�����ֵ
% �ڶ���Ϊ�źŵ��ұ߽�����ֵ
% ������Ϊ�źŵ��ϱ߽�����ֵ
% ������Ϊ�źŵ��±߽�����ֵ

end