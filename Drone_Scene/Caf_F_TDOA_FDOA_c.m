function [tdoa0, fdoa0, strength, caf] = Caf_F_TDOA_FDOA_c(fs,sig1,sig2)

t0=1/fs:1/fs:length(sig1)/fs;
frequentCU=-20e6:4e5:20e6;
fft_low=fft(sig1);
len=length(fft_low);
for k=1:length(frequentCU)
    sig2_f=sig2.*exp(2*pi*1i*frequentCU(k)*t0);
    fft_high=fft(sig2_f);
    
%     conj_tempt=conj(fft_low).*fft_high;
%     cube=[zeros(1,len),conj_tempt,zeros(1,len)];
%     caf(k,:)=ifft(cube); 
    
    caf(k,:)=ifft(conj(fft_low).*fft_high);
end

[fd,td]=find(caf==max(max(caf)));
strength = abs(max(max(caf)));
caf_plot = caf(fd,:);
hail_L = length(caf_plot)/2;
caf_plot2(1:hail_L)=caf_plot(hail_L+1:end);
caf_plot2(hail_L+1:length(caf_plot))=caf_plot(1:hail_L);
caf_abs=abs(caf_plot2);
td=find(caf_abs==max(caf_abs))-length(caf_abs)/2;
tdoa=td/fs;
% tdoa=td/(3*fs);
fdoa=frequentCU(fd);

% figure();
% mesh(abs(caf));
% figure();
% plot(abs(caf(fd,:)));
% figure();
% plot(10*log10(abs(caf_plot2)));

% 没有细估计的话直接赋值，若采用细估计，则注释掉
% tdoa0 = tdoa;
% fdoa0 = fdoa;

%% 细估计
frequentXI=fdoa-10:0.2:fdoa+10;
for k=1:length(frequentXI)
    sig2_f=sig2.*exp(2*pi*1i*frequentXI(k)*t0);
    fft_high=fft(sig2_f);
    
%     conj_tempt=conj(fft_low).*fft_high;
%     cube=[zeros(1,len),conj_tempt,zeros(1,len)];
%     caf0(k,:)=ifft(cube); 
    
    caf0(k,:)=ifft(conj(fft_low).*fft_high);
end

[fd0,td0]=find(caf0==max(max(caf0)));
strength = abs(max(max(caf0)));
caf_plot0 = caf0(fd0,:);
hail_L = length(caf_plot0)/2;
caf_plot20(1:hail_L)=caf_plot0(hail_L+1:end);
caf_plot20(hail_L+1:length(caf_plot0))=caf_plot0(1:hail_L);

caf_abs0=abs(caf_plot20);

td0=find(caf_abs0==max(caf_abs0))-length(caf_abs0)/2;

tdoa0=td0/fs;
% tdoa0=td0/(3*fs);
fdoa0=frequentXI(fd0);
% 
% % fff=frequentCU;
% 
% figure()
% plot(10*log10(abs(caf_plot20)))
% % % ttt=time/fs;
% % % figure();
% % % plot(abs(caf0(fd0,:)));
% % mesh(ttt,fff,caf);
% % mesh(abs(caf));
% % xlabel('鏃堕棿鏍℃閲?(s)');
% % ylabel('棰戠巼鏍℃閲?(Hz)');
% % zlabel('瀵规暟鏈熸湜鏈?澶у寲鍑芥暟鍊?');
% % title('涓嶅悓鏃堕棿鏍℃閲忓拰棰戠巼鏍℃閲忓搴旂殑鏈熸湜鏈?澶у寲鍑芥暟鍊?');

end

