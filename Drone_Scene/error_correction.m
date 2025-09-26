function [ori_message1_recover, ori_message2_recover] = error_correction(ori_message1_error, ori_message2_error, sig_depart1, sig_depart2)

% �ȶԱ���ʼƵ��,��ֹƵ�ʣ� �ٶԱ�����ʱ�̣�Ȼ��Ա���ֹʱ�̣�Ȼ��һ��Ƶ�ʶ��ĺ�ʱ�������ԭʼ�źŵ�������
ori_message1_recover = []; % ����̨վ�ж���ͬһ�źŵķ�����ͬ������λ��
ori_message2_recover = []; % ����̨վ�ж���ͬһ�źŵķ�����ͬ������λ��

for i = 1 : length(ori_message1_error)
    % �ҳ������ź�
    for j = 1 : length(ori_message2_error)
        if abs(ori_message1_error(i, 1) - ori_message2_error(j, 1)) < 0.01 * (ori_message1_error(i, 2) - ori_message1_error(i, 1)) %��ʼƵ�ʷ�Χһ��
            if abs(ori_message1_error(i, 2) - ori_message2_error(j, 2)) < 0.01 * (ori_message1_error(i, 2) - ori_message1_error(i, 1)) %��ֹƵ�ʷ�Χһ��
                if abs(ori_message1_error(i, 3) - ori_message2_error(j, 3)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %��ʼʱ�䷶Χһ��
                    if abs(ori_message1_error(i, 4) - ori_message2_error(j, 4)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %��ֹʱ�䷶Χһ��
                        % ��ʼ����ֹƵ��һ�£���ʼ����ֹʱ��һ�£���Ϊ��վ����ȷ����ͬһ�ź�
                        % ������վͼ�����Ӧ�������źŵ�ʱ���
                        [corr_peak2, tdoa2, mean_acor2] = TD_est(sig_depart1(i, :),sig_depart2(j, :));
                        if (corr_peak2 > 5e-16 && corr_peak2 / mean_acor2 > 5)
                            ori_message1_recover = [ori_message1_recover; ori_message1_error(i, :)];
                            ori_message2_recover = [ori_message2_recover; ori_message2_error(j, :)];
                            break; %����ͼ��ͬһ�ź�
                        end
                    else % ��ʼ����ֹƵ��һ�£���ʼʱ��һ�£�����ֹʱ�䲻һ�£�����ܳ�����ͬһƵ��������ʱ������ŵ��źű���Ϊ��һ��
                        % ������վͼ�����Ӧ�������źŵ�ʱ���
                        [corr_peak2, tdoa2, mean_acor2] = TD_est(sig_depart1(i, :),sig_depart2(j, :));
                        if (corr_peak2 > 5e-16 && corr_peak2 / mean_acor2 > 5)
                            % Ƶ�ʼ����ñ�վ��⵽����ʼ����ֹƵ�ʣ���ʼʱ������ñ�վ��⵽����ʼʱ�䣬��ֹʱ���ñ�վ��ʼʱ��+��һ����վ��⵽�źŵ�ʱ��
                            % ���ж�һ�´�����̨վ1����̨վ2
                            ori_message1_temp = ori_message1_error(i, :);
                            ori_message2_temp = ori_message2_error(j, :);
                            if (ori_message1_error(i, 4) - ori_message1_error(i, 3) > ori_message2_error(i, 4) - ori_message2_error(i, 3)) %̨վ1���
                                ori_message1_temp(4) = ori_message1_temp(3) + (ori_message2_temp(4) - ori_message2_temp(3));
                                ori_message1_temp(5) = ori_message2_temp(5);
                            else %̨վ2���
                                ori_message2_temp(4) = ori_message2_temp(3) + (ori_message1_temp(4) - ori_message1_temp(3));
                                ori_message2_temp(5) = ori_message1_temp(5);
                            end
                            ori_message1_recover = [ori_message1_recover; ori_message1_temp];
                            ori_message2_recover = [ori_message2_recover; ori_message2_temp];
                            continue; %�ҵ���������ʱ�����ڵ��ź���ʱ�俿ǰ��
                        end
                    end
                else % ��ʼ����ֹƵ�ʾ�һ�£���ֹʱ��һ�£�����ʼʱ�䲻һ�£�����ܳ�����ͬһƵ��������ʱ������ŵ��źű���Ϊ��һ��
                    if abs(ori_message1_error(i, 4) - ori_message2_error(j, 4)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %��ֹʱ�䷶Χһ��
                        % ������վͼ�����Ӧ�������źŵ�ʱ���
                        [corr_peak2, tdoa2, mean_acor2] = TD_est(sig_depart1(i, :),sig_depart2(j, :));
                        if (corr_peak2 > 5e-16 && corr_peak2 / mean_acor2 > 5)
                            % Ƶ�ʼ����ñ�վ��⵽����ʼ����ֹƵ�ʣ���ֹʱ������ñ�վ��⵽����ֹʱ�䣬��ʼʱ���ñ�վ��ֹʱ��-��һ����վ��⵽�źŵ�ʱ��
                            % ���ж�һ�´�����̨վ1����̨վ2
                            ori_message1_temp = ori_message1_error(i, :);
                            ori_message2_temp = ori_message2_error(j, :);
                            if (ori_message1_error(i, 4) - ori_message1_error(i, 3) > ori_message2_error(i, 4) - ori_message2_error(i, 3)) %̨վ1���
                                ori_message1_temp(3) = ori_message1_temp(4) - (ori_message2_temp(4) - ori_message2_temp(3));
                                ori_message1_temp(5) = ori_message2_temp(5);
                            else %̨վ2���
                                ori_message2_temp(3) = ori_message2_temp(4) - (ori_message1_temp(4) - ori_message1_temp(3));
                                ori_message2_temp(5) = ori_message1_temp(5);
                            end
                            ori_message1_recover = [ori_message1_recover; ori_message1_temp];
                            ori_message2_recover = [ori_message2_recover; ori_message2_temp];
                            continue; %�ҵ���������ʱ�����ڵ��ź���ʱ�俿���
                        end
                    end
                end     
            else % ��ʼ����ֹʱ���һ�£���ʼƵ��һ�£�����ֹƵ�ʲ�һ�£�����ܳ�����ͬһʱ��������Ƶ�ʽ����ŵ��źű���Ϊ��һ��
                if abs(ori_message1_error(i, 3) - ori_message2_error(j, 3)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %��ʼʱ�䷶Χһ��
                    if abs(ori_message1_error(i, 4) - ori_message2_error(j, 4)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %��ֹʱ�䷶Χһ��
                        % ������վͼ�����Ӧ�������źŵ�ʱ���
                        [corr_peak2, tdoa2, mean_acor2] = TD_est(sig_depart1(i, :),sig_depart2(j, :));
                        if (corr_peak2 > 5e-16 && corr_peak2 / mean_acor2 > 5)
                            % Ƶ��ֱ������һ̨վ��⵽����ʼ����ֹƵ�ʣ���ʼʱ���ñ�վ��⵽��ʼʱ��+TDOA����ֹʱ����У�������ʼʱ��+��һ����վ��⵽�źŵ�ʱ��
                            % ���ж�һ�´�����̨վ1����̨վ2
                            ori_message1_temp = ori_message1_error(i, :);
                            ori_message2_temp = ori_message2_error(j, :);
                            if (ori_message1_error(i, 2) - ori_message1_error(i, 1) > ori_message2_error(i, 2) - ori_message2_error(i, 1)) %̨վ1���
                                ori_message1_temp(1: 2) = ori_message2_temp(1: 2);
                                ori_message1_temp(3) = ori_message1_temp(3) + tdoa2;
                                ori_message1_temp(4) = ori_message1_temp(3) + (ori_message2_temp(4) - ori_message2_temp(3));
                                ori_message1_temp(5) = ori_message2_temp(5);
                            else %̨վ2���
                                ori_message2_temp(1: 2) = ori_message1_temp(1: 2);
                                ori_message2_temp(3) = ori_message2_temp(3) + tdoa2;
                                ori_message2_temp(4) = ori_message2_temp(3) + (ori_message1_temp(4) - ori_message1_temp(3));
                                ori_message2_temp(5) = ori_message1_temp(5);
                            end
                            ori_message1_recover = [ori_message1_recover; ori_message1_temp];
                            ori_message2_recover = [ori_message2_recover; ori_message2_temp];
                            continue; %�ҵ���������Ƶ�����ڵ��ź���Ƶ�ʿ�ǰ��
                        end
                    end
                end
            end
        else % ��ʼ����ֹʱ���һ�£���ֹƵ��һ�£�����ʼƵ�ʲ�һ�£�����ܳ�����ͬһʱ��������Ƶ�ʽ����ŵ��źű���Ϊ��һ��
            if abs(ori_message1_error(i, 2) - ori_message2_error(j, 2)) < 0.01 * (ori_message1_error(i, 2) - ori_message1_error(i, 1)) %��ֹƵ�ʷ�Χһ��
                if abs(ori_message1_error(i, 3) - ori_message2_error(j, 3)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %��ʼʱ�䷶Χһ��
                    if abs(ori_message1_error(i, 4) - ori_message2_error(j, 4)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %��ֹʱ�䷶Χһ��
                        % ������վͼ�����Ӧ�������źŵ�ʱ���
                        [corr_peak2, tdoa2, mean_acor2] = TD_est(sig_depart1(i, :),sig_depart2(j, :));
                        if (corr_peak2 > 5e-16 && corr_peak2 / mean_acor2 > 5)
                            % Ƶ��ֱ������һ̨վ��⵽����ʼ����ֹƵ�ʣ���ʼʱ���ñ�վ��⵽��ʼʱ��+TDOA����ֹʱ����У�������ʼʱ��+��һ����վ��⵽�źŵ�ʱ��
                            % ���ж�һ�´�����̨վ1����̨վ2
                            ori_message1_temp = ori_message1_error(i, :);
                            ori_message2_temp = ori_message2_error(j, :);
                            if (ori_message1_error(i, 2) - ori_message1_error(i, 1) > ori_message2_error(i, 2) - ori_message2_error(i, 1)) %̨վ1���
                                ori_message1_temp(1: 2) = ori_message2_temp(1: 2);
                                ori_message1_temp(3) = ori_message1_temp(3) + tdoa2;
                                ori_message1_temp(4) = ori_message1_temp(3) + (ori_message2_temp(4) - ori_message2_temp(3));
                                ori_message1_temp(5) = ori_message2_temp(5);
                            else %̨վ2���
                                ori_message2_temp(1: 2) = ori_message1_temp(1: 2);
                                ori_message2_temp(3) = ori_message2_temp(3) + tdoa2;
                                ori_message2_temp(4) = ori_message2_temp(3) + (ori_message1_temp(4) - ori_message1_temp(3));
                                ori_message2_temp(5) = ori_message1_temp(5);
                            end
                            ori_message1_recover = [ori_message1_recover; ori_message1_temp];
                            ori_message2_recover = [ori_message2_recover; ori_message2_temp];
                            continue; %�ҵ���������Ƶ�����ڵ��ź���Ƶ�ʿ����
                        end
                    end
                end
            end
        end
    end
end

end