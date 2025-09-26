% 函数定义：计算无线电波传播路径损耗 (以 dB 为单位)
% function L = decline_mode(decline_para,f_c,d)
%
% 输入参数:
% decline_para: 包含传播模型参数的向量。具体参数取决于 area 的值。
%   decline_para(1): area 类型 (参见下面的 area 描述)
%   decline_para(2): 基站天线有效高度 hb (m)
%   decline_para(3): 接收台天线有效高度 hm (m)
%   decline_para(4), decline_para(5) 等: 其他特定 area 需要的参数
% f_c: 载波频率 (MHz)
% d: 基站与接收台之间的水平距离 (km)
%
% 输出参数:
% L: 计算出的路径损耗 (dB)

% 使用衰减模型计算损耗(dB)，距离单位需转为km，频率单位转为MHz

function L = decline_mode(decline_para,f_c,d)
%L(dB): path loss
%%Variable
%decline_para:
%area: 1: free space; 2:Large city; 3:small-sized city; 4:suburb; 5:open area/country;
%      6:hills(10-500m); 7:slope; 8: Amphibious(水陆混合); 9: mountain area.
%hb(m): 基站天线有效高度
%hm(m): 接收台天线有效高度
%per_building:  建筑物覆盖的百分比
%deta_h: 丘陵地形的起伏高度（m）
%thetam: 斜坡的平均倾角
%dsR: 水面距离
%mode: 1: 水面位于移动台一方时 2: 水面位于基台一方时
%f_c(MHz): 载波频率
%d(km): 基站与接收台之间的水平距离

area = decline_para(1);
hb = decline_para(2);
hm = decline_para(3);

switch area
    case {2,3}
        per_building = decline_para(4);
    case {6}
        deta_h = decline_para(4);
    case {7}
        thetam = decline_para(4);
    case {8}
        dsR = decline_para(4);
        mode = decline_para(5);
end

if (f_c<=1500)
    if area == 1 %free space
        L_freespace = 32.45 +20*log10(f_c) + 20*log10(d);
        L = L_freespace;
    elseif area == 2 %large city
        if f_c<=300
            ahm = 8.29 * (log10(1.54 * hm))^2 - 1.1;
        elseif f_c >= 300
            ahm = 3.2 * (log10(11.75 * hm))^2 - 4.97;
        end
        B = 30 - 25*log10(per_building);
        L_city = 69.55+26.16*(log10(f_c))-13.82*(log10(hb))-ahm+(44.9-6.55*(log10(hb)))*(log10(d))-B;
        L = L_city;
    elseif area == 3 %small-sized city
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        B = 30 - 25*log10(per_building);
        L_scity = 69.55+26.16*(log10(f_c))-13.82*(log10(hb))-ahm +(44.9-6.55*(log10(hb)))*(log10(d))-B;
        L = L_scity;
    elseif area == 4 %suburb
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        L1 =69.55+26.16*(log10(f_c))-13.82*(log10(hb))-ahm+(44.9-6.55*(log10(hb)))*(log10(d));
        if ((d >= 1)&&(d <= 10))
            Kmr = 2 * (log10(f_c / (d+38)))^2 - 5.4*d + 16.21;
        elseif ((d > 10)&&(d < 20))
            Kmr = 2 * (log10(f_c / (68-2*d)))^2 - 5.4*(d-10) + 10.8;
        elseif d >= 20
            Kmr = 2 * (log10(f_c / 28))^2 - 5.4;
        end
        L_suburb = L1 - Kmr;
        L = L_suburb;
    elseif area == 5 %open area/country
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        L1 =69.55+26.16*(log10(f_c))-13.82*(log10(hb))-ahm+(44.9-6.55*(log10(hb)))*(log10(d));
        Q0 = 4.78*(log10(f_c))^2-18.33*log10(f_c)+40.94;
        Qr = 4.78*(log10(f_c))^2-18.33*log10(f_c)+36;
        L_open = L1 - Q0 - Qr;
        L = L_open;
    elseif area == 6 %hill
        %deta_h = max(h_hill)*(0.9 - 0.1);
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        L1 =69.55+26.16*(log10(f_c))-13.82*(log10(hb))-ahm+(44.9-6.55*(log10(hb)))*(log10(d));
        if deta_h < 10
            Kh = 0;
            Khf = 0;
        elseif (deta_h >= 10)&&(deta_h <= 500)
            Kh = -5.364*(log10(deta_h))^2+4.23*log10(deta_h)+2.43;
            Khf = -1.92*(log10(deta_h))^2+15.6*log10(deta_h)-11.69;
        end
        L_hill = L1 - Kh - Khf;
        L = L_hill;
    elseif area == 7%slope
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        L1 =69.55+26.16*(log10(f_c))-13.82*(log10(hb))-ahm+(44.9-6.55*(log10(hb)))*(log10(d));
        if thetam < 0
            if d < 10
            Ksp = -5e-3*thetam^2+0.15*thetam;
            elseif (d >= 10)&&(d <= 30)
            Ksp = -(d*4.405e-4+5.95e-4)*thetam^2+(d*2.45e-2-9.5e-2)*thetam;
            elseif d > 30
            Ksp = -0.01381*thetam^2+0.64*thetam;
            end
        elseif thetam > 0
            if d < 10
            Ksp = -0.0035*thetam^2+0.235*thetam;
            elseif (d >= 10)&&(d <= 30)
            Ksp = -(7.5e-5*d+2.75e-3)*thetam^2+(0.01125*d+0.1225)*thetam;
            elseif (d > 30)&&(d < 60)
            Ksp = -1.67e-4*d*thetam^2+(0.01133*d+0.12)*thetam;
            elseif d > 60
            Ksp = -0.01*thetam^2+0.8*thetam;
            end
        end
        L_sp = L1 - Ksp;
        L = L_sp;
    elseif area == 8%Amphibious
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        L1 =69.55+26.16*(log10(f_c))-13.82*(log10(hb))-ahm+(44.9-6.55*(log10(hb)))*(log10(d));
        deta_d = dsR/d;
        if mode == 1%水面位于移动台一方时
            if d < 30
            Ks = -8.125*deta_d^2+19.25*deta_d;
            elseif (d >= 30)&&(d <= 60)
            Ks = -(0.157*d+3.41)*deta_d^2+(0.2793*d+10.87)*deta_d;
            elseif d > 60
            Ks = -12.83*deta_d^2+27.63*deta_d;
            end
        elseif mode == 2%水面位于基台一方时
            if d < 30
            Ks = 7.45*deta_d^2+5.8*deta_d;
            elseif (d >= 30)&&(d <= 60)
            Ks = -(0.125*d+11.2)*deta_d^2+(0.2167*d+0.701)*deta_d;
            elseif d > 60
            Ks = 3.704*deta_d^2+12.3*deta_d;
            end
        end
        L_A = L1 - Ks;
        L = L_A;    
    elseif area == 9 %Mountain area
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        L_mountain = 36.05 + 33.9*log10(f_c) - 13.82*log10(hb)-ahm+(44.9-6.55*log10(hb))*log10(d);
        L = L_mountain;
    end
end
if (f_c>1500)
   if area == 1 %free space
        L_freespace = 32.45 + 20*log10(f_c) + 20*log10(d);
        L = L_freespace;
   elseif area == 2 %large city
        if f_c<=300
            ahm = 8.29 * (log10(1.54 * hm))^2 - 1.1;
        elseif f_c >= 300
            ahm = 3.2 * (log10(11.75 * hm))^2 - 4.97;
        end
        C = 3;
        B = 30 - 25*log10(per_building);
        L_city = 69.55+26.16*(log10(f_c))-13.82*(log10(hb))-ahm+(44.9-6.55*(log10(hb)))*(log10(d))-B+C;
        L = L_city;
    elseif area == 3 %small-sized city
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        B = 30 - 25*log10(per_building);
        C = 0;
        L_scity = 69.55+26.16*(log10(f_c))-13.82*(log10(hb))-ahm +(44.9-6.55*(log10(hb)))*(log10(d))-B+C;
        L = L_scity;
    elseif area == 4 %suburb
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        C = 0;
        L1 = 46.3 + 33.9 * log10(f_c) - 13.82 * log10(hb) - ahm + (44.9 - 6.55 * log10(hb)) * log(d) + C;
        if ((d >= 1)&&(d <= 10))
            Kmr = 2 * (log10(f_c / (d+38)))^2 - 5.4*d + 16.21;
        elseif ((d > 10)&&(d < 20))
            Kmr = 2 * (log10(f_c / (68-2*d)))^2 - 5.4*(d-10) + 10.8;
        elseif d >= 20
            Kmr = 2 * (log10(f_c / 28))^2 - 5.4;
        end
        L_suburb = L1 - Kmr;
        L = L_suburb;
    elseif area == 5 %open area/country
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        C = 0;
        L1 = 46.3 + 33.9 * log10(f_c) - 13.82 * log10(hb) - ahm + (44.9 - 6.55 * log10(hb)) * log(d) + C;
        Q0 = 4.78*(log10(f_c))^2-18.33*log10(f_c)+40.94;
        Qr = 4.78*(log10(f_c))^2-18.33*log10(f_c)+36;
        L_open = L1 - Q0 - Qr;
        L = L_open;
    elseif area == 6 %hill
        %deta_h = max(h_hill)*(0.9 - 0.1);
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        C = 0;
        L1 = 46.3 + 33.9 * log10(f_c) - 13.82 * log10(hb) - ahm + (44.9 - 6.55 * log10(hb)) * log(d) + C;
        if deta_h < 10
            Kh = 0;
            Khf = 0;
        elseif (deta_h >= 10)&&(deta_h <= 500)
            Kh = -5.364*(log10(deta_h))^2+4.23*log10(deta_h)+2.43;
            Khf = -1.92*(log10(deta_h))^2+15.6*log10(deta_h)-11.69;
        end
        L_hill = L1 - Kh - Khf;
        L = L_hill;
    elseif area == 7%slope
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        C = 0;
        L1 = 46.3 + 33.9 * log10(f_c) - 13.82 * log10(hb) - ahm + (44.9 - 6.55 * log10(hb)) * log(d) + C;
        if thetam < 0
            if d < 10
            Ksp = -5e-3*thetam^2+0.15*thetam;
            elseif (d >= 10)&&(d <= 30)
            Ksp = -(d*4.405e-4+5.95e-4)*thetam^2+(d*2.45e-2-9.5e-2)*thetam;
            elseif d > 30
            Ksp = -0.01381*thetam^2+0.64*thetam;
            end
        elseif thetam > 0
            if d < 10
            Ksp = -0.0035*thetam^2+0.235*thetam;
            elseif (d >= 10)&&(d <= 30)
            Ksp = -(7.5e-5*d+2.75e-3)*thetam^2+(0.01125*d+0.1225)*thetam;
            elseif (d > 30)&&(d < 60)
            Ksp = -1.67e-4*d*thetam^2+(0.01133*d+0.12)*thetam;
            elseif d > 60
            Ksp = -0.01*thetam^2+0.8*thetam;
            end
        end
        L_sp = L1 - Ksp;
        L = L_sp;

    elseif area == 8%Amphibious
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        C = 0;
        L1 = 46.3 + 33.9 * log10(f_c) - 13.82 * log10(hb) - ahm + (44.9 - 6.55 * log10(hb)) * log(d) + C;
        deta_d = dsR/d;
        if mode == 1%水面位于移动台一方时
            if d < 30
            Ks = -8.125*deta_d^2+19.25*deta_d;
            elseif (d >= 30)&&(d <= 60)
            Ks = -(0.157*d+3.41)*deta_d^2+(0.2793*d+10.87)*deta_d;
            elseif d > 60
            Ks = -12.83*deta_d^2+27.63*deta_d;
            end
        elseif mode == 2%水面位于基台一方时
            if d < 30
            Ks = 7.45*deta_d^2+5.8*deta_d;
            elseif (d >= 30)&&(d <= 60)
            Ks = -(0.125*d+11.2)*deta_d^2+(0.2167*d+0.701)*deta_d;
            elseif d > 60
            Ks = 3.704*deta_d^2+12.3*deta_d;
            end
        end
        L_A = L1 - Ks;
        L = L_A;
    elseif area == 9 %Mountain area
        ahm = (1.1 * log10(f_c) - 0.7) * hm - (1.56 * log10(f_c) - 0.8);
        L_mountain = 36.05 + 33.9*log10(f_c) - 13.82*log10(hb)-ahm+(44.9-6.55*log10(hb))*log10(d);
        L = L_mountain;
    end
end
end