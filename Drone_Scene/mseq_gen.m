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