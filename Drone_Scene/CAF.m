function out = CAF(sig1, sig2, Fs, nfft)

% tao=(1/fs:1/fs:length(sig1)/fs);%ʱ�ӵķ�Χ
% for a=1:nfft
%     stao=sig2.*exp(1j*2*pi*kexi(a)*time);%Ƶƫ����ź�
%     x(a,:)=xcorr(sig1,stao);%��ԭʼ�źŸ�Ƶƫ����ź������
% end
% 
% figure;
% surf(tao,1:nfft,abs(x));xlabel('ʱ��');ylabel('Ƶƫ');shading interp;%ģ��ͼ
% figure;
% v=[0.707*max(max(abs(x))),0.707*max(max(abs(x)))];
% contour(tao,kexi,abs(x),v,'ShowText','on');grid on;%ģ����ͼ



xor_len=length(sig2)+length(sig1)-1;
FFT_len=4096;

% xor_value=zeros(xor_len,FFT_len);
%%%��������ά��ģ��
for i=1:xor_len
    temp=sig1.*conj(sig2(i:i+length(sig1)-1));
    xor_value(i,:)=fftshift(abs(fft(temp,FFT_len))); 
end

[a b]=max(xor_value,[],2);
[c d]=max(a);

b(d)
delta_f = Fs*b(d)/FFT_len-Fs/2    %%Ƶ��
delta_t=-d/Fs                   %%ʱ��

figure
TT=-0.01:1/Fs:0.01;
TT=-0.02:1/Fs:0.00;
FF=(0:Fs/FFT_len:Fs-1)-Fs/2;
[X,Y]=meshgrid(FF,TT);
mesh(X,Y,xor_value)
xlabel('f');
ylabel('t');
title('CAF')

out = 0;

end
