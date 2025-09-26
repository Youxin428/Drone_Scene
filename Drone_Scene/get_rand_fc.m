function out = get_rand_fc(Fc,num)

% Fc为可以选择的频率
% num生成多少段信号

peoject_interval = 2; % 保护间隔，即当选定一个Fc_now后，其后面连着peoject_Fc个Fc_after应该与Fc_now不相同
                      % 即随机出一个Fc1后，后面接着随机出peoject_Fc个Fc都不应该等于Fc1
N = length(Fc);
out = zeros(1,num);
project_Fc = zeros(1,peoject_interval);

for ii = 1:num
    rand_Fc = 0;
    while(1)
        rand_Fc = randi([1, N]);
        if (sum(ismember(project_Fc,rand_Fc)) < 0.5)
            for jj = 1:(peoject_interval-1)
                project_Fc(jj) = project_Fc(jj+1);
            end
            project_Fc(peoject_interval) = rand_Fc;
            break;
        end
    end
    
    out(ii) = Fc(rand_Fc);%按照索引取出相应的频率
end

end


% 1. 当前代码逻辑（peoject_interval=2）
% 保护间隔定义：确保当前选择的频率在接下来的 2 个位置 中不会重复。
% 实现方式：
% 维护一个长度为 2 的窗口 project_Fc，记录最近选择的频率索引。
% 每次生成新频率时，检查该索引是否存在于窗口中。
% 若存在则重新选择，直至找到一个不在窗口中的索引。
% 更新窗口：移除最旧的索引，添加新索引。

% 2. 修改参数的影响（peoject_interval =3）
% 保护间隔扩展：当前选择的频率在接下来的 3 个位置 中不会重复。
% 效果：
% 相邻三个跳频点不重复：确保每个新频率与前三个位置的频率不同。
% 窗口长度调整：project_Fc 数组长度变为 3，记录最近三次选择的索引。
% 选择限制加强：新频率必须与最近三次选择的频率不同。