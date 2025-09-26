function out = get_orthogonal_fc(Fc_total, trans_num, sig_num)

N = length(Fc_total);
out = zeros(trans_num, sig_num);

for i = 1 : sig_num
    uniq = 1; %uniq=0时没有相同频率
    while uniq ~= 0
        Fc_select_temp = randi(N, trans_num, 1);
        uniq=length(Fc_select_temp)-length(unique(Fc_select_temp)); % 判断是否有选择出现相同的频率
    end
    
    for j = 1 : trans_num
        Fc_select_temp(j) = Fc_total(Fc_select_temp(j));
    end
    
    out(:, i) = Fc_select_temp;
end

end