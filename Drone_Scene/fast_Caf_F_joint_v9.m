function [tdoa0,fdoa0,ratio_cad_XI] = fast_Caf_F_joint_v9(fs,sig_low,sig_high,band,rdoa_max)
% fs为采样率，sig_low_new,sig_high_new为传入信号
% sig_low、sig_high为两路信号IQ数据
% band为信号带宽
% rdoa_max为最大距离差
%% 点数限制

vc=299792458;


if length(sig_low)~=length(sig_high)
    disp("两路信号长度不一致，出错！");
    return;
end
%     N=0.02*fs;
%     nfft=2^(floor(log2(N)));
%     sig_low=sig_low(1:nfft);
%     sig_high=sig_high(1:nfft);
nfft=2^(floor(log2(length(sig_low))));
if(length(sig_low)>=nfft)
    sig_low=sig_low(1:nfft);
    sig_high=sig_high(1:nfft);
else
    sig_low=[sig_low,zeros(1,nfft-length(sig_low))];
    sig_high=[sig_high,zeros(1,nfft-length(sig_high))];
end

%     N_max=65536*4;
%     N_max=2^20;
%     if length(sig_low)>N_max
%         sig_low=sig_low(1:N_max);
%         sig_high=sig_high(1:N_max);
%     else
%         sig_low=sig_low(1:2^(floor(log2(length(sig_low)))));
%         sig_high=sig_high(1:2^(floor(log2(length(sig_low)))));
%     end

%     nfft=length(sig_low);
factor=floor(band/fs*nfft);
factor_half = floor(factor/2);
fft_low=fft(sig_low);
fft_high=fft(sig_high);

%% 采样率限制:如果采样率大于等于2倍带宽，进行降采样
if fs>=2*band
    fft_low_new=[fft_low(1:factor_half),zeros(1,2^(ceil(log2(factor)))-factor_half*2),fft_low(end-factor_half+1:end)];
    fft_high_new=[fft_high(1:factor_half),zeros(1,2^(ceil(log2(factor)))-factor_half*2),fft_high(end-factor_half+1:end)];
    sig_low_new=ifft(fft_low_new);
    sig_high_new=ifft(fft_high_new);
else
    fft_low_new=fft_low;
    fft_high_new=fft_high;
    sig_low_new=sig_low;
    sig_high_new=sig_high;
end
fs_new=length(sig_low_new)/length(sig_low)*fs;
t0_new=1/fs_new:1/fs_new:length(sig_low_new)/fs_new; %低速信号时间轴

%% 插值倍数限制
nfft_final_max=65536*64*2; %细估计互模糊函数点数的最大值，必须设置为2^n
%     nfft_final_max=2^20;
N_joint=4;  %插值倍数，必须为2^n
fs_final_min=100e6; %细估计上采样后的采样率的最小值
if fs_new*N_joint<fs_final_min
    N_joint=2^(ceil(log2(fs_final_min/fs_new)));
end
if(length(sig_low_new)*N_joint>nfft_final_max)
    N_joint=nfft_final_max/length(sig_low_new);
end
nfft_final=length(fft_low_new)*N_joint;
% 粗估计

frequentCU=-1000:50:1000;
fd=0; % fd初值设为频率搜索范围的中间值，即对应频率0
maximum = -1;
% tempt_0=conj(fft_low_new).*fft_high_new; % k=0
% caf0 = ifft(tempt_0);
% caf = reshape(caf0,1,[]);
% [maximum,~]= max(abs(caf));
%     k=312;
for k=1:length(frequentCU)
    sig2_f=sig_high_new.*exp(2*pi*1i*frequentCU(k)*t0_new);
    fft_high_new=fft(sig2_f);
    tempt=conj(fft_low_new).*fft_high_new;
    caf=ifft(tempt);
    caf_valid = [caf(1:ceil(rdoa_max*fs_new/vc)),caf((((end-ceil(rdoa_max*fs_new/vc))+1)):end)];
    %         nfft = length(caf);

    %         cad(k,1:nfft/2) = abs(caf(nfft/2+1:nfft));
    %         cad(k,nfft/2+1:nfft) = abs(caf(1:nfft/2));
    % %          cad(k,:)=abs(caf);
    % %         caa = plot(abs(caf))
    [maximum_1,loc1]= max(abs(caf_valid));
    if maximum_1>maximum
        maximum=maximum_1;
        fd = k;
        td = loc1;
    end
end

%     t0=t0_new-length(sig_high_new)/(2*fs);
%     figure();
%     mesh(t0,frequentCU,cad);
%     title("粗估计频域二阶互模糊函数值");
%     xlabel('时间校正量(s)');ylabel('频率校正量(Hz)');zlabel('频域二阶互模糊函数值');

fdoa=frequentCU(fd);

%% 细估计
frequentXI=fdoa-25:25:fdoa+25;
tempt=zeros(1,nfft_final);
%     tempt(1:factor_half)=conj(fft_low_new(1:factor_half)).*fft_high_new(1:factor_half);
%     tempt(end-factor_half+1:end)=conj(fft_low_new(end-factor_half+1:end)).*fft_high_new(end-factor_half+1:end);
%     caf0=ifft(tempt,nfft_final);
%     caf = reshape(caf0,1,[]);
%     [maximum,td0]= max(abs(caf));
%
%     fd0=ceil(length(frequentXI)/2); % fd0初值设为频率搜索范围的中间值，即对应频率0
maximum = -1;
fd0 = 0;

for k=1:length(frequentXI)
    sig2_f=sig_high_new.*exp(2*pi*1i*frequentXI(k)*t0_new);
    fft_high_new=fft(sig2_f);
    tempt(1:factor_half)=conj(fft_low_new(1:factor_half)).*fft_high_new(1:factor_half);
    tempt(end-factor_half+1:end)=conj(fft_low_new(end-factor_half+1:end)).*fft_high_new(end-factor_half+1:end);
    caf_final=ifft(tempt,nfft_final);
    caf_final_abs = abs(caf_final);
    caf_final_valid = [caf_final(1:ceil(rdoa_max*fs_new*N_joint/vc)),caf_final((((end-ceil(rdoa_max*fs_new*N_joint/vc))+1)):end)];
    caf_final_valid_abs = abs(caf_final_valid);

    %         cad_XI(k,1:nfft_final/2) = abs(caf_final(nfft_final/2+1:nfft_final));
    %         cad_XI(k,nfft_final/2+1:nfft_final) = abs(caf_final(1:nfft_final/2));

    [maximum_1,loc2]= max(abs(caf_final_valid));
    if maximum_1>maximum
        maximum=maximum_1;
        fd0 = k;
        td0 = loc2;
    end
    caf_final_valid_abs = abs(caf_final_valid);
end

if td0 > length(caf_final_valid)/2
    td0=td0-length(caf_final_valid);
end

[aa_cad,bb_cad]=size(caf_final_valid_abs);
cad_XI_0 = reshape(caf_final_valid_abs,aa_cad*bb_cad,1);
cad_XI_1 = sort(cad_XI_0,'ascend');
max_cad_XI = max(cad_XI_1);
mean_cad_XI = mean(cad_XI_1(floor(0.2*aa_cad*bb_cad):end-floor(0.5*aa_cad*bb_cad)));
ratio_cad_XI = max_cad_XI/mean_cad_XI;

td0 = td0 - 1; % 此处需要减1，C++程序可忽略（因为C++索引从0开始，Matlab索引从1开始）
%
%     t0=(1/(fs_new*N_joint):1/(fs_new*N_joint):nfft_final/(fs_new*N_joint)) -nfft_final/(2*fs_new*N_joint);
%     figure();
%     mesh(t0,frequentXI,cad_XI);
%     title("细估计频域二阶互模糊函数值");
%     xlabel('时间校正量(s)');ylabel('频率校正量(Hz)');zlabel('频域二阶互模糊函数值');

tdoa0=td0/(fs_new*N_joint);
fdoa0=frequentXI(fd0);

end