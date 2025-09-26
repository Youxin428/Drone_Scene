function data_out = fs_change_updown_FFT_Lowpass(fs,fs_after,sig_fs,fd,dem_debug)
%������
%fs: ��ʼ������
%fs_after: ������������
%sig_fs�� ��ʼ�ź�
%fd����Ԫ����

%���裺��0���١��˲�*2�����Բ�ֵ����������ȡ

%�����
%fs_after ���ղ�����
%data_out ���������Ժ���źţ���Ҫ�ٴ��˲�

times_fs_fd0 = fs/fd;                          % ����ǰ������������Ԫ���ʵı�����ϵ
times_fs_fd = fs_after/fd;                    % ����������������Ԫ���ʵ���������ϵ���ڴ��Ѿ��̶�Ϊ110��

up_times = floor(fs_after/fs);              % ���������ڲ����ٵı���
if rem(up_times,1) == 0
    if up_times > 1
        for k=1:length(sig_fs)
            data2(up_times*k-(up_times-1):up_times*k-1)=zeros(1,up_times-1);
            data2(up_times*k)=sig_fs(k);
        end
        
        DK = 3*fd; %%��һЩ���� fsk�ࣺҪ���ݴ�������DK�������źſ�����3*fd
        [data2] = FFT_lowpass(fs_after,DK,data2);
        nfft = 2^ceil(log2(length(data2)));
        f = (0:fs_after/nfft:(nfft-1)*fs_after/nfft)-fs_after/2;
        if dem_debug == 1
            figure()
            plot(f,20*log(fftshift(abs(fft(data2,nfft)))))
        end
        time_end=length(data2)/(fs*up_times);
        time1 = 1/(fs*up_times):1/(fs*up_times):time_end;      %���Բ�ֵǰʱ��
        time2 = 1/fs_after:1/fs_after:floor(time_end*fs_after)/fs_after;          %���Բ�ֵ��ʱ��
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
        time1 = 1/fs:1/fs:time_end;      %���Բ�ֵǰʱ��
        time2 = 1/fs_after:1/fs_after:floor(time_end*fs_after)/fs_after;          %���Բ�ֵ��ʱ��
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
        %fprintf('����Ҫ���䵽�Ĳ������ʱ�ԭʼ�������ʵͣ��������');
        %data_out = [];
        if times_fs_fd0 < 24 %���һ����Ԫ��Ӧ����20�������㣬�������������ֵ
            up_times0=floor(24/times_fs_fd0);%ԭʼ�źŲ�ֵ����
            for k=1:length(sig_fs)
                data2(up_times0*k-(up_times0-1):up_times0*k-1)=zeros(1,up_times0-1);
                data2(up_times0*k)=sig_fs(k);
            end
            
            DK = 0.5*fs_after;
            [data2] = FFT_lowpass(fs_after,DK,data2);
            sig_fs=data2;
            fs=fs*up_times0;
        end
        
        fs_middle=ceil(fs/fs_after)*fs_after;%���ղ����ʵ�������
        
        time_end=length(sig_fs)/(fs);
        time1 = 1/(fs):1/(fs):time_end;      %���Բ�ֵǰʱ��
        time2 = 1/fs_middle:1/fs_middle:floor(time_end*fs_middle)/fs_middle;          %���Բ�ֵ��ʱ��
        data_middle(1) = sig_fs(1);
        for k=1:length(time2)-2
            sample_min=floor(time2(k+1)*(fs));%floor
            sig_fs_min=sig_fs(sample_min);
            sig_fs_max=sig_fs(sample_min+1);
            data_middle(k+1)=((sig_fs_max-sig_fs_min)*(fs))*(time2(k+1)-time1(sample_min))+sig_fs_min;%��Ts��֮һΪ���x��sig_fs_max-sig_fs_minΪ���y������б�ʺ����ʱ��time2(k+1)-time1(sample_min)��Ϊ����
        end
        
        down_times=round(fs_middle/fs_after); %�������ʳ�ȡ����
        data_out=downsample(data_middle,down_times);
        
    end
    %     data_end(ceil(time_end*fs_after)) = data2(end);
else
    fprintf('����Ҫ���䵽�Ĳ������ʲ�����Ԫ���ʵ����������������');
    data_out = [];
end

