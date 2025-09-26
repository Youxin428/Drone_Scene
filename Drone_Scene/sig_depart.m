% �������壺��һ�������ź�����ȡ������һ���ض����ź�����Σ����壩��
% [out] = sig_depart(sig, Fs, ori_message, len)
% �������:
% sig: ����ĸ����ź���������ͨ���ǽ���վ���յ��ġ���������źŵ��Ӻ����������ź� (���� finally_data_rec1 �� finally_data_rec2)��
% Fs: �źŵĲ���Ƶ�� (Hz)��
% ori_message: ����Ҫ��ȡ���ź�����β�������������ͨ������ ori_message_mul�����а����˸�����ε���ʼ/�����������Ƶ����Ϣ��
% len: ����������źŶγ��ȣ��Բ�����Ϊ��λ����ͨ���������ź�����ε���󳤶Ȼ�������׼���ȡ�
% �������:
% out: ��ȡ�������˲������ܰ��ԭ��Ƶ������ź������������


function [out] = sig_depart(sig, Fs, ori_message, len)
%% --- ʱ���ȡ ---
% ������� ori_message ����ȡ���ź�����ε���ʼ�ͽ���ʱ��㣨�Բ�����Ϊ��λ����
t_start = ori_message(3); % ��ȡ���źŶ��������ź����� sig �е���ʼ������������
t_end = ori_message(4);   % ��ȡ���źŶ��������ź����� sig �еĽ���������������

% if len > t_end - t_start
%     sig_temp = sig(t_start : t_start + len - 1);
% elseif len ~= 0
%     sig_temp = sig(t_start : t_start + len - 1);
% else
%     sig_temp = sig(t_start : t_end - 1);
% end

% sig_temp = sig(t_start : t_end - 1);

if len < t_end - t_start
    sig_temp = sig(t_start : t_start + len - 1);
else
    sig_temp = sig(t_start : t_end - 1);
end

%% Ƶ���˲�
Fc = (ori_message(1) + ori_message(2)) / 2; % �����ź�����ε�����Ƶ�� (Hz)��
B = ori_message(2) - ori_message(1);        % �����ź�����εĴ��� (Hz)��
% �任������
% ����һ�����ȡ�����źŶ� sig_temp ������ͬ��ʱ����������ʾ���ʱ�䣬���ں�����Ƶ�ʰ��ơ�
t_slot = (1/Fs:1/Fs:length(sig_temp)/Fs); % ʱ���������� 1/Fs ��ʼ������ 1/Fs�����źŶεĳ���ʱ��
% ����ȡ�����źŶ� sig_temp (ͨ������Ƶ����Ƶ�ź�) ����һ������Ƶ�ĸ�ָ�� (exp(-j*2*pi*Fc*t))��
% ����������źŵ�����Ƶ�� Fc ���Ƶ� 0 Hz���õ��źŵĻ�����ʾ sig_base��
sig_base = sig_temp .* exp(1i*2*pi*Fc*t_slot*-1);




% ѡ���˲�������ͨ�˲�
% [filter, filter_name] = getFilter(Fs, B);
% sig_base_filtered = conv(sig_base,filter);
% sig_handle = sig_base_filtered(ceil(length(filter)/2):end-floor(length(filter)/2));
sig_handle = FFT_lowpass(Fs,B,sig_base);

% ���ԭ��Ƶ
out = sig_handle .* exp(1i*2*pi*Fc*t_slot);
% out = sig_handle;

% % ��ʱ����ͼ
% t_figure = (0 : 1/length(out) : (length(out)-1)/length(out));
% figure()
% plot(t_figure, real(out));
% % ��Ƶ��ͼ
% f_figure = (0:Fs/length(out):Fs*(length(out)-1)/length(out)) - Fs/2;
% figure()
% plot(f_figure, fftshift(abs(fft(out))));

end