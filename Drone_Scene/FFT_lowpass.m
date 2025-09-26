function [data_3] = FFT_lowpass(fs,DK,sig)
%输入信号采样频率、输入带宽、输入信号，程序根据DK和fs关系在频域滤波
%输出的data_3与输入信号等长


siglen = length(sig);
nfft = 2^(ceil(log2(siglen))) ;
fre_div = fs / nfft;
fre_end = (DK/2);  %滤波器
fre_point_end = round(fre_end/fre_div);
data_1 = [sig zeros(1,nfft-siglen)];

FFT_sig_handle = fft(data_1,nfft);
FFT_sig_handle =[FFT_sig_handle(1:fre_point_end) zeros(1,nfft - 2*fre_point_end) FFT_sig_handle(end-fre_point_end+1:end)];

data_2 = ifft(FFT_sig_handle,nfft);
data_3 = data_2(1:siglen);

end

