%% �첽��Ƶ�ź����ɺ���
% ���������
%   SNR - �����(dB)
%   noise_power - ��������(dBm)
%   nfft - FFT����
%   data_long - ���źų���(��������)
%   number - ����̨վ���
% ���������
%   FH_data - ���ɵ���Ƶ�ź�
%   Fc_rand - ���ѡ�����Ƶ����
%   finally_message - ת������ٲ�ͼ������ע��Ϣ
%   sig_message - ԭʼ�źŲ�����Ϣ
%   part_long - �ٲ�ͼ�ֶγ���

function [FH_data, Fc_rand, finally_message, sig_message, part_long] = FH_generation_asynchronous(Fs, Fd, SNR, ...
    noise_power, nfft, data_long, number)

t = (0:data_long-1)/Fs; % ����ʱ������(��λ����)

% ��ƵƵ�ʳ�����
% ���̶�����Ƶ�ź�
%     Fc = 10e3:20e3:20e6;
fc_num = 200; % ��ѡƵ�ʵ����� 500
Fc = get_fc_point(5750e6,5850e6,fc_num); % ��0-20MHz��Χ�����ɾ��ȷֲ��ĺ�ѡƵ�ʵ�

%�źŲ�����ʼ��
sig = zeros(1,data_long); % ��ʼ��ȫ���ź�����
part_sig_vector = [200000, 250000, 300000, 350000, 400000, 450000, 500000, 600000]; % ��ѡ�źŶγ���(��������)
num1 = randi([1,8]); % ���ѡ���źŶγ�������
part_interval_vector = [20000, 30000, 40000, 50000, 60000]; % ��ѡ�����������
num2 = randi([1,5]); % ���ѡ�񱣻��������

%ȷ����Ƶ�β���
part_sig_len = part_sig_vector(num1);       % ��Ч�źŶγ���(����200000���Ӧ4ms@50MHz����)
part_interval = part_interval_vector(num2); % �����������
part_data_len = part_sig_len+part_interval; % �����ܳ���(�ź�+���)
sig_num = floor(data_long/part_data_len);   % ��������ɵ�������Ƶ����

% ��ƵƵ����������
Fc_rand = get_rand_fc(Fc,sig_num); % �Ӻ�ѡƵ�������ѡ��sig_num����Ϊ��Ƶ����

% ���ʼ���
sig_power = noise_power * 10^(SNR/10); % ����SNR������Ҫ���źŹ���
% ԭ��SNR(dB) = 10*log10(Ps/Pn) => Ps = Pn*10^(SNR/10)

%% �źŶ���Ϣ�����ʼ��
sig_message = zeros(sig_num,4); % �ж��壺[��Ƶ, ����, ��ʼʱ��, ����ʱ��]

%% ��Ƶ�ź�������ѭ��
for ii = 1:sig_num
    % �����ź�����
    base_sig = get_bpsk(part_sig_len,Fd,Fs);
    % ���ʵ���
    base_sig = set_sig_power(base_sig,sig_power); 
    % ���źŷ�װ
    part_sig = zeros(1,part_data_len);   % ��ʼ�����ź�(���������)
    part_sig(1:part_sig_len) = base_sig; % ǰ�������Ч�ź�
    % ��¼�źŲ���
    sig_message(ii,1) = Fc_rand(ii); % ��Ƶ(Hz)
    sig_message(ii,2) = 1.306*Fd;    % �źŴ���(Hz) % �����ҹ���ϵ����=0.306
    sig_message(ii,3) = (ii-1)*part_data_len/Fs;           % ��ʼʱ��(s)
    sig_message(ii,4) = sig_message(ii,3)+part_sig_len/Fs; % ����ʱ��(s)
    % �ϱ�Ƶ����
    carrier = exp(1i*2*pi*Fc_rand(ii)*t((ii-1)*part_data_len+1:ii*part_data_len));  % ������Ƶ�źţ�exp(1i*2��fct)
    part_fc_sig = part_sig.*carrier; % Ƶ�װ�������Ƶ
    
    % �źźϳ�
    sig((ii-1)*part_data_len+1:ii*part_data_len) = sig((ii-1)*part_data_len+1:ii*part_data_len)+part_fc_sig;
end
%% ��������ź�
FH_data = sig; % �����ɵ���Ƶ�ź�

%%
% ��ͼ��֤   ԭʼ����
% part_long = 2000;
% water = get_waterfall(sig,part_long,nfft,Fs);
% figure()
% imagesc(water)
% fig_title = ['��վ��Ƶ�ź�'];
% title(fig_title);


%%  ��ͼ��֤  �����Ż����
part_long = 2000; % �������������ٲ�ͼʱ������FFT�����Ĵ��ڳ��� (��������)
noverlap = 0;     % �������ڴ���֮�䲻�ص�����ģ��ԭ get_waterfall ����Ϊ
[S, F, T] = spectrogram(sig, part_long, noverlap, nfft, Fs, 'power', 'centered');
target_min_freq = 0; % Ŀ����СƵ�� (0 Hz)
target_max_freq = Fs/2 * (20/25); % Ŀ�����Ƶ�� (Fs/2 �� 20/25 �� = 0.4 * Fs)
freq_indices_to_keep = find(F >= target_min_freq & F <= target_max_freq);

S_cropped = S(freq_indices_to_keep, :); 
F_cropped = F(freq_indices_to_keep);
power_spectrum_magnitude = abs(S_cropped); 
max_value = max(power_spectrum_magnitude(:)); 

% �Է��Ⱦ�����й�һ������Ȼ����� 10
% ������������������ʾ�� water ������������ʵ����
water = (power_spectrum_magnitude ./ max_value) * 10;

figure() % ����һ���µ�ͼ�δ���
% ʹ�� imagesc ������ʾ�ٲ�ͼ���ݡ�
% imagesc(X, Y, C) �У�X ��Ӧ�У����ᣩ�����꣬Y ��Ӧ�У����ᣩ�����ꡣ
% water ������ж�Ӧʱ�� (T)���ж�Ӧ�ü����Ƶ�� (F_cropped)��
imagesc(T, F_cropped, water); % ʹ�� spectrogram �����ʱ������ T �Ͳü����Ƶ������ F_cropped ��Ϊ������
axis xy;  % ��ת Y �᷽��ʹ��Ƶ�ʴ�С������������ (��׼Ƶ��ͼ��ʾ��ʽ)
colorbar; % �����ɫ������ʾ��ɫ��Ӧ��ǿ��ֵ
xlabel('ʱ�� (s)'); 
ylabel('Ƶ�� (Hz)'); 
fig_title = '��վ��Ƶ�ź�'; 
title(fig_title); 

%% �ٲ�ͼ����ת��
part_long = 2000; % �ٲ�ͼ�ֶγ���(��������)
finally_message = tf_change(sig_message,part_long,nfft,Fs);  % ��ʽΪ [��ʼƵ������, ��ֹƵ������, ��ʼʱ������, ��ֹʱ������]
% ���������ת��Ϊ�ٲ�ͼ������
% [��ʼƵ��bin, ����Ƶ��bin, ��ʼʱ��֡, ����ʱ��֡]

% finally_message(:,1:2) = finally_message(:,1:2)-nfft/2;

% draw_out(finally_message,'-r')
% ������finally_message�洢�е���������Ϊ
% ��һ��Ϊ�źŵ���߽�����ֵ
% �ڶ���Ϊ�źŵ��ұ߽�����ֵ
% ������Ϊ�źŵ��ϱ߽�����ֵ
% ������Ϊ�źŵ��±߽�����ֵ

end