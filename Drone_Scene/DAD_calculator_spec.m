function [aoa,mtr]=DAD_calculator_spec(rcvPos,sig_rcv,fs,init_angle,lamda,end_angle)
aoa=0;
angle_vec=init_angle:lamda:init_angle+end_angle;
num=length(angle_vec);
mtr=zeros(1,num);
vc=299792458;
max_eig=0;
barycenter=mean(rcvPos);
nfft=length(sig_rcv(4,:));
f=-fs/2:fs/nfft:fs/2-1;

Rcv_num = length(rcvPos(:,1));
V = zeros(Rcv_num,nfft);

for aoa_index=1:length(angle_vec)
    aoa_direction_vec=-[cos(angle_vec(aoa_index)/180*pi),sin(angle_vec(aoa_index)/180*pi)];%计算方向向量
    for m=1:Rcv_num %取接收机个数
        rcv2baryctr_vec(m,:)=rcvPos(m,:)-barycenter;%计算距离：接收机位置－重心位置
        time_delay(m)=dot(aoa_direction_vec,rcv2baryctr_vec(m,:))/vc; %时延
        V(m,:)=sig_rcv(m,:).*exp(2j*pi*f*time_delay(m));
    end

    eigenmtr=V*V';%代价函数sDs中的矩阵D,其最大特征值对应矢量为信号s
    maxEig=abs(eigs(double(eigenmtr),1,'lm')); %返回一个绝对值最大的特征值，并取模
    mtr(aoa_index)=maxEig;
    if maxEig>max_eig
        max_eig=maxEig;
        aoa=angle_vec(aoa_index);
    end
end
% plot(angle_vec,log(mtr));
% xlabel('angle/°')
% ylabel('eig')
end
