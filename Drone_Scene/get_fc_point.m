function out = get_fc_point(f_start,f_end,max_band,fc_num)

if fc_num <= 0
    error('fc_num 必须大于 0');
end

% f_end= f_end - max_band/2;
% f_start= f_start + max_band/2;
fc_all = f_end - f_start;
fc_part = fc_all / fc_num;

fc1 = f_start : fc_part : f_end;
fc2 = fc1(1:end-1);
fc3_candidates = fc2 + fc_part/2; % 这些是 fc_num 个候选频率点

m_coef = [0 0 1 0 1];               %  对应 x^5 + x^3 + 1
m_initial_state = [1 1 1 0 0];  %   一个非全零的初始状态
m_seq = mseq_gen(m_coef, m_initial_state);
m_seq_period = length(m_seq);   % m序列的周期，这里是31
% selected_fc = zeros(1, fc_num);
out = zeros(1, fc_num);
m_decimal_index_1to31 = zeros(1, fc_num);

random= randi([1, 1000]);
randomNumber= randi([1, fc_num-32]);


for i = 1:fc_num
    % 计算构成当前5位滑窗的元素在原始m_seq中的实际索引
    % 当前滑窗的概念起始索引是 i
    % 概念索引序列是: i, i+1, i+2, i+3, i+4
    conceptual_indices = i+random : i+4+random;

    % 将概念索引通过模运算映射到原始m_seq的实际索引 (1-based)
    m_seq_indices = mod(conceptual_indices - 1, m_seq_period) + 1;

    % 从原始m_seq中提取出当前的5位滑窗
    current_binary_window  = m_seq(m_seq_indices);

    % 将5位二进制窗口转换为十进制数字
    decimal_index_1to31 = bin2dec(char('0' + current_binary_window));

    % 将十进制索引 (实际范围 1到31) 映射到 fc3_candidates 的有效索引范围 (1-based, 1到fc_num)
    % 使用 mod(a, n) + 1 模式将数值映射到 1-based 范围。
    % 这里的 a 是 decimal_index_1to31 (范围 1到31)，n 是 fc_num。
%     index_for_fc3 = mod(decimal_index_1to31 - 1, fc_num) + 1; % 修正此处映射，更清晰地从1-based映射到1-based

    % 从候选频率点中选取对应的频率
    m_decimal_index_1to31(i)=decimal_index_1to31;
out(i) = fc3_candidates(randomNumber+decimal_index_1to31);
% out(i) = fc3_candidates(decimal_index_1to31);

end

end

function [seq]=mseq_gen(coef,initial_state)
%m序列发生器
%coef 为生成多项式
m=length(coef);
len=2^m-1; % 得到序列的长度
seq=zeros(1,len); % 给生成的m序列预分配
% initial_state = [1  zeros(1, m-2) 1]; % 给寄存器分配初始结果
for i=1:len
    seq(i)=initial_state(m);
    backQ = mod(sum(coef.*initial_state) , 2);
    initial_state(2:length(initial_state)) = initial_state(1:length(initial_state)-1);
    initial_state(1)=backQ;
end
end
