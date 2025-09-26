%% 输入为坐标、RDOA值、几个站都可以，但需要有参考节点
function u = TDOA_LS_2D(s,rdoa_s)
    a = size(s,2) - 1;
    for i = 1:a
        Gr(i,:) = 2*[(s(:,i+1)-s(:,1))',rdoa_s(i)];
        hr(i,1) = s(:,i+1)'*s(:,i+1) - s(:,1)'*s(:,1) - rdoa_s(i)^2;
    end
        v = inv(Gr'*Gr)*Gr'*hr;
        u = v(1:2,1);
end