% �ϲ�Ƶ����ͬ��ʱ�����ڵ���Ϊ�����
function [rec_message_error_time, ori_message_error_time] = merge_adjacent_time(rec_message, ori_message, Fs, data_time, Fc_total)

rec_message_error_time = [];
ori_message_error_time = [];
i = 1;
while (i <= length(ori_message))
    if i == length(ori_message)
        rec_message_error_time = [rec_message_error_time; rec_message(i, :)];
        ori_message_error_time = [ori_message_error_time; ori_message(i, :)];
        break;
    end
    % ����Ƶ��һ����ʱ������ŵĿ��һ����
    if  (abs(ori_message(i, 1) - ori_message(i+1, 1)) < (Fc_total(2)-Fc_total(1))/2500 && abs(ori_message(i, 3) - ori_message(i+1, 3)) < 0.06 * data_time * Fs)
        rec_message1_temp(1) = min(rec_message(i, 1), rec_message(i+1, 1)); % ������ʼƵ��
        ori_message1_temp(1) = min(ori_message(i, 1), ori_message(i+1, 1));
        rec_message1_temp(2) = max(rec_message(i, 2), rec_message(i+1, 2)); % ������ֹƵ��
        ori_message1_temp(2) = max(ori_message(i, 2), ori_message(i+1, 2));
        rec_message1_temp(3) = min(rec_message(i, 3), rec_message(i+1, 3)); % ������ʼʱ��
        ori_message1_temp(3) = min(ori_message(i, 3), ori_message(i+1, 3));
        rec_message1_temp(4) = max(rec_message(i, 4), rec_message(i+1, 4)); % ������ֹʱ��
        ori_message1_temp(4) = max(ori_message(i, 4), ori_message(i+1, 4));
        rec_message1_temp(5) = 0;
        ori_message1_temp(5) = 0;
        
        rec_message_error_time = [rec_message_error_time; rec_message1_temp];
        ori_message_error_time = [ori_message_error_time; ori_message1_temp];
        i = i + 2; % ���Ѿ���ǰһ������һ����ź�����
        continue;
    else
        rec_message_error_time = [rec_message_error_time; rec_message(i, :)];
        ori_message_error_time = [ori_message_error_time; ori_message(i, :)];
        i = i + 1;
        continue;
    end
end
end