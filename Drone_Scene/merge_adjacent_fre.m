% 合并时间相同，频率相邻的作为错检结果
function [rec_message_error, ori_message_error] = merge_adjacent_fre(rec_message_error_time, ori_message_error_time, Fs, data_time, Fc_total)

rec_message_error = [];
ori_message_error = [];
i = 1;
while (i <= length(ori_message_error_time))
    if i == length(ori_message_error_time)
        rec_message_error = [rec_message_error; rec_message_error_time(i, :)];
        ori_message_error = [ori_message_error; ori_message_error_time(i, :)];
        break;
    end
    % （将时间一样，频率紧挨着的框成一个）
    if (abs(ori_message_error_time(i, 3) - ori_message_error_time(i+1, 3)) < 0.006 * data_time * Fs && abs(ori_message_error_time(i, 1) - ori_message_error_time(i+1, 1)) < (Fc_total(2)-Fc_total(1))*1.2)
        rec_message1_temp(1) = min(rec_message_error_time(i, 1), rec_message_error_time(i+1, 1)); % 错检后起始频率
        ori_message1_temp(1) = min(ori_message_error_time(i, 1), ori_message_error_time(i+1, 1));
        rec_message1_temp(2) = max(rec_message_error_time(i, 2), rec_message_error_time(i+1, 2)); % 错检后终止频率
        ori_message1_temp(2) = max(ori_message_error_time(i, 2), ori_message_error_time(i+1, 2));
        rec_message1_temp(3) = min(rec_message_error_time(i, 3), rec_message_error_time(i+1, 3)); % 错检后起始时间
        ori_message1_temp(3) = min(ori_message_error_time(i, 3), ori_message_error_time(i+1, 3));
        rec_message1_temp(4) = max(rec_message_error_time(i, 4), rec_message_error_time(i+1, 4)); % 错检后终止时间
        ori_message1_temp(4) = max(ori_message_error_time(i, 4), ori_message_error_time(i+1, 4));
        rec_message1_temp(5) = 0;
        ori_message1_temp(5) = 0;
        
        rec_message_error = [rec_message_error; rec_message1_temp];
        ori_message_error = [ori_message_error; ori_message1_temp];
        i = i + 2; % 把已经和前一个框在一起的信号跳过
        continue;
    else
        rec_message_error = [rec_message_error; rec_message_error_time(i, :)];
        ori_message_error = [ori_message_error; ori_message_error_time(i, :)];
        i = i + 1;
        continue;
    end
end