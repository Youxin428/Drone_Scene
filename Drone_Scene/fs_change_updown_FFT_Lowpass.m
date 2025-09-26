function data_out = fs_change_updown_FFT_Lowpass(fs,fs_after,sig_fs,fd,dem_debug)
%输入量
%fs: 初始采样率
%fs_after: 适配后采样速率
%sig_fs： 初始信号
%fd：码元速率

%步骤：插0提速→滤波*2→线性差值→整数倍抽取

%输出量
%fs_after 最终采样率
%data_out 最终适配以后的信号，需要再次滤波

times_fs_fd0 = fs/fd;                          % 适配前采样速率与码元速率的倍数关系
times_fs_fd = fs_after/fd;                    % 适配后采样速率与码元速率的整数倍关系，在此已经固定为110倍

up_times = floor(fs_after/fs);              % 采样速率内插提速的倍数
if rem(up_times,1) == 0
    if up_times > 1
        for k=1:length(sig_fs)
            data2(up_times*k-(up_times-1):up_times*k-1)=zeros(1,up_times-1);
            data2(up_times*k)=sig_fs(k);
        end
        
        DK = 3*fd; %%给一些冗余 fsk类：要根据带宽设置DK，其他信号可以是3*fd
        [data2] = FFT_lowpass(fs_after,DK,data2);
        nfft = 2^ceil(log2(length(data2)));
        f = (0:fs_after/nfft:(nfft-1)*fs_after/nfft)-fs_after/2;
        if dem_debug == 1
            figure()
            plot(f,20*log(fftshift(abs(fft(data2,nfft)))))
        end
        time_end=length(data2)/(fs*up_times);
        time1 = 1/(fs*up_times):1/(fs*up_times):time_end;      %线性插值前时间
        time2 = 1/fs_after:1/fs_after:floor(time_end*fs_after)/fs_after;          %线性插值后时间
        data_out(1) = data2(1);
        for k=1:length(time2)-2
            sample_min=floor(time2(k+1)*fs*up_times);
            data2_min=data2(sample_min);
            data2_max=data2(sample_min+1);
            data_out(k+1)=((data2_max-data2_min)*fs*up_times)*(time2(k+1)-time1(sample_min))+data2_min;
        end
        nfft = 2^ceil(log2(length(data_out)));
        f = (0:fs_after/nfft:(nfft-1)*fs_after/nfft)-fs_after/2;
        if dem_debug == 1
            figure()
            plot(f,20*log(fftshift(abs(fft(data_out,nfft)))))
        end
     
    elseif up_times == 1
        
        time_end=length(sig_fs)/fs;
        time1 = 1/fs:1/fs:time_end;      %线性插值前时间
        time2 = 1/fs_after:1/fs_after:floor(time_end*fs_after)/fs_after;          %线性插值后时间
        data_out(1) = sig_fs(1);
        for k=1:length(time2)-2
            sample_min=floor(time2(k+1)*fs);
            sig_fs_min=sig_fs(sample_min);
            sig_fs_max=sig_fs(sample_min+1);
            data_out(k+1)=((sig_fs_max-sig_fs_min)*fs)*(time2(k+1)-time1(sample_min))+sig_fs_min;
        end
        nfft = 2^ceil(log2(length(data_out)));
        f = (0:fs_after/nfft:(nfft-1)*fs_after/nfft)-fs_after/2;


        if dem_debug == 1
            figure()
            plot(f,20*log(fftshift(abs(fft(data_out,nfft)))))
        end
    else
        %fprintf('所需要适配到的采样速率比原始采样速率低，输入错误！');
        %data_out = [];
        if times_fs_fd0 < 24 %如果一个码元对应少于20个采样点，则进行整数倍插值
            up_times0=floor(24/times_fs_fd0);%原始信号插值倍数
            for k=1:length(sig_fs)
                data2(up_times0*k-(up_times0-1):up_times0*k-1)=zeros(1,up_times0-1);
                data2(up_times0*k)=sig_fs(k);
            end
            
            DK = 0.5*fs_after;
            [data2] = FFT_lowpass(fs_after,DK,data2);
            sig_fs=data2;
            fs=fs*up_times0;
        end
        
        fs_middle=ceil(fs/fs_after)*fs_after;%最终采样率的整数倍
        
        time_end=length(sig_fs)/(fs);
        time1 = 1/(fs):1/(fs):time_end;      %线性插值前时间
        time2 = 1/fs_middle:1/fs_middle:floor(time_end*fs_middle)/fs_middle;          %线性插值后时间
        data_middle(1) = sig_fs(1);
        for k=1:length(time2)-2
            sample_min=floor(time2(k+1)*(fs));%floor
            sig_fs_min=sig_fs(sample_min);
            sig_fs_max=sig_fs(sample_min+1);
            data_middle(k+1)=((sig_fs_max-sig_fs_min)*(fs))*(time2(k+1)-time1(sample_min))+sig_fs_min;%以Ts分之一为跨度x，sig_fs_max-sig_fs_min为跨度y，求其斜率后乘以时间time2(k+1)-time1(sample_min)作为增量
        end
        
        down_times=round(fs_middle/fs_after); %采样速率抽取倍数
        data_out=downsample(data_middle,down_times);
        
    end
    %     data_end(ceil(time_end*fs_after)) = data2(end);
else
    fprintf('所需要适配到的采样速率不是码元速率的整数倍，输入错误！');
    data_out = [];
end

