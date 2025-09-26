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
    aoa_direction_vec=-[cos(angle_vec(aoa_index)/180*pi),sin(angle_vec(aoa_index)/180*pi)];%���㷽������
    for m=1:Rcv_num %ȡ���ջ�����
        rcv2baryctr_vec(m,:)=rcvPos(m,:)-barycenter;%������룺���ջ�λ�ã�����λ�æ�
        time_delay(m)=dot(aoa_direction_vec,rcv2baryctr_vec(m,:))/vc; %ʱ��
        V(m,:)=sig_rcv(m,:).*exp(2j*pi*f*time_delay(m));
    end

    eigenmtr=V*V';%���ۺ���sDs�еľ���D,���������ֵ��Ӧʸ��Ϊ�ź�s
    maxEig=abs(eigs(double(eigenmtr),1,'lm')); %����һ������ֵ��������ֵ����ȡģ
    mtr(aoa_index)=maxEig;
    if maxEig>max_eig
        max_eig=maxEig;
        aoa=angle_vec(aoa_index);
    end
end
% plot(angle_vec,log(mtr));
% xlabel('angle/��')
% ylabel('eig')
end
