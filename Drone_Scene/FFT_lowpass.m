function [data_3] = FFT_lowpass(fs,DK,sig)
%�����źŲ���Ƶ�ʡ�������������źţ��������DK��fs��ϵ��Ƶ���˲�
%�����data_3�������źŵȳ�


siglen = length(sig);
nfft = 2^(ceil(log2(siglen))) ;
fre_div = fs / nfft;
fre_end = (DK/2);  %�˲���
fre_point_end = round(fre_end/fre_div);
data_1 = [sig zeros(1,nfft-siglen)];

FFT_sig_handle = fft(data_1,nfft);
FFT_sig_handle =[FFT_sig_handle(1:fre_point_end) zeros(1,nfft - 2*fre_point_end) FFT_sig_handle(end-fre_point_end+1:end)];

data_2 = ifft(FFT_sig_handle,nfft);
data_3 = data_2(1:siglen);

end

