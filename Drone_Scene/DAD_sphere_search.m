function [aoa,r]=DAD_sphere_search(rcvPos,sig_rcv,fs,init_angle,lamda,range,r_start,r_range,r_end)
vc=299792458;
angle_vec = init_angle-range:lamda:init_angle+range; % 角度范围
r_vec = r_start:r_range:r_end;  

a_num = length(angle_vec);
r_num = length(r_vec);
mtr = zeros(a_num, r_num); % 初始化代价函数数组

max_eig = 0; 
barycenter=rcvPos(1,:);%参考点
N0=length(sig_rcv(1,:));
f=-fs/2:fs/N0:fs/2-1;

Rcv_num = length(rcvPos(:, 1)); % 接收机数量
V = zeros(Rcv_num,N0);

for aoa_index = 1:a_num
    aoa_direction_vec = [cos(angle_vec(aoa_index) / 180 * pi), sin(angle_vec(aoa_index) / 180 * pi)];
    for r_index = 1:r_num
        pos_temp = barycenter + aoa_direction_vec*r_vec(r_index);
        time_delay = zeros(1,Rcv_num);

        for m=1:Rcv_num
            distance(m)=norm(pos_temp-rcvPos(m,:));%计算距离
            time_delay(m)=distance(m)/vc ;
            V(m,:)=sig_rcv(m,:).*exp(2j*pi*f*time_delay(m));
        end
        eigenmtr=V*V';%代价函数sDs中的矩阵D,其最大特征值对应矢量为信号s
        maxEig=abs(eigs(double(eigenmtr),1,'lm'));
        mtr(aoa_index, r_index)=maxEig;
        
        % 更新结果
        if mtr(aoa_index, r_index) > max_eig
            max_eig = mtr(aoa_index, r_index);
            aoa = angle_vec(aoa_index);
            r = r_vec(r_index);
        end

    end
end

[angle_grid, r_grid] = meshgrid(angle_vec, r_vec); % 创建网格

% 绘制三维曲面图
figure;
surf(angle_grid, r_grid, log(mtr')); % 注意 mtr 需转置使维度匹配
xlabel('Angle (°)');
ylabel('Distance (m)');
zlabel('MTR Value');
title('DAD MTR');
colorbar; % 添加颜色条
shading interp; % 平滑曲面


end





