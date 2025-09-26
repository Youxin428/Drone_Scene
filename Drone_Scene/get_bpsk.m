function out = get_bpsk(part_len,Fd,Fs)

% 计算所需符号数（考虑过采样和滤波器时延）
% 每个符号采样数 = Fs/Fd
% 乘2原因：考虑滤波器群时延导致的信号前后扩展，避免截断后长度不足
num = ceil(2*part_len/(Fs/Fd)); % 向上取整确保符号数足够

% 生成随机二进制消息序列
msg = randi([0,1],1,num); % 生成num个0/1随机比特
base_sig = inside_sig_produce_with_filter_up_Fd2('BPSK',msg,Fd,Fs);
out = base_sig(1:part_len);


end