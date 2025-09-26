function [ori_message1_recover, ori_message2_recover] = error_correction(ori_message1_error, ori_message2_error, sig_depart1, sig_depart2)

% 先对比起始频率,终止频率； 再对比起跳时刻，然后对比终止时刻；然后看一下频率多框的和时间多框的与原始信号的相关情况
ori_message1_recover = []; % 两个台站判断是同一信号的放入相同的坐标位置
ori_message2_recover = []; % 两个台站判断是同一信号的放入相同的坐标位置

for i = 1 : length(ori_message1_error)
    % 找出错检的信号
    for j = 1 : length(ori_message2_error)
        if abs(ori_message1_error(i, 1) - ori_message2_error(j, 1)) < 0.01 * (ori_message1_error(i, 2) - ori_message1_error(i, 1)) %起始频率范围一致
            if abs(ori_message1_error(i, 2) - ori_message2_error(j, 2)) < 0.01 * (ori_message1_error(i, 2) - ori_message1_error(i, 1)) %终止频率范围一致
                if abs(ori_message1_error(i, 3) - ori_message2_error(j, 3)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %起始时间范围一致
                    if abs(ori_message1_error(i, 4) - ori_message2_error(j, 4)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %终止时间范围一致
                        % 起始、终止频率一致，起始、终止时间一致，则为两站均正确检测的同一信号
                        % 计算两站图中相对应的两个信号的时间差
                        [corr_peak2, tdoa2, mean_acor2] = TD_est(sig_depart1(i, :),sig_depart2(j, :));
                        if (corr_peak2 > 5e-16 && corr_peak2 / mean_acor2 > 5)
                            ori_message1_recover = [ori_message1_recover; ori_message1_error(i, :)];
                            ori_message2_recover = [ori_message2_recover; ori_message2_error(j, :)];
                            break; %两张图中同一信号
                        end
                    else % 起始、终止频率一致，起始时间一致，但终止时间不一致，则可能出现了同一频率有两个时间紧挨着的信号被框为了一个
                        % 计算两站图中相对应的两个信号的时间差
                        [corr_peak2, tdoa2, mean_acor2] = TD_est(sig_depart1(i, :),sig_depart2(j, :));
                        if (corr_peak2 > 5e-16 && corr_peak2 / mean_acor2 > 5)
                            % 频率继续用本站检测到的起始、终止频率；起始时间继续用本站检测到的起始时间，终止时间用本站起始时间+另一接收站检测到信号的时长
                            % 先判断一下错检的是台站1还是台站2
                            ori_message1_temp = ori_message1_error(i, :);
                            ori_message2_temp = ori_message2_error(j, :);
                            if (ori_message1_error(i, 4) - ori_message1_error(i, 3) > ori_message2_error(i, 4) - ori_message2_error(i, 3)) %台站1错检
                                ori_message1_temp(4) = ori_message1_temp(3) + (ori_message2_temp(4) - ori_message2_temp(3));
                                ori_message1_temp(5) = ori_message2_temp(5);
                            else %台站2错检
                                ori_message2_temp(4) = ori_message2_temp(3) + (ori_message1_temp(4) - ori_message1_temp(3));
                                ori_message2_temp(5) = ori_message1_temp(5);
                            end
                            ori_message1_recover = [ori_message1_recover; ori_message1_temp];
                            ori_message2_recover = [ori_message2_recover; ori_message2_temp];
                            continue; %找到框错的两个时间相邻的信号中时间靠前的
                        end
                    end
                else % 起始、终止频率均一致，终止时间一致，但起始时间不一致，则可能出现了同一频率有两个时间紧挨着的信号被框为了一个
                    if abs(ori_message1_error(i, 4) - ori_message2_error(j, 4)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %终止时间范围一致
                        % 计算两站图中相对应的两个信号的时间差
                        [corr_peak2, tdoa2, mean_acor2] = TD_est(sig_depart1(i, :),sig_depart2(j, :));
                        if (corr_peak2 > 5e-16 && corr_peak2 / mean_acor2 > 5)
                            % 频率继续用本站检测到的起始、终止频率；终止时间继续用本站检测到的终止时间，起始时间用本站终止时间-另一接收站检测到信号的时长
                            % 先判断一下错检的是台站1还是台站2
                            ori_message1_temp = ori_message1_error(i, :);
                            ori_message2_temp = ori_message2_error(j, :);
                            if (ori_message1_error(i, 4) - ori_message1_error(i, 3) > ori_message2_error(i, 4) - ori_message2_error(i, 3)) %台站1错检
                                ori_message1_temp(3) = ori_message1_temp(4) - (ori_message2_temp(4) - ori_message2_temp(3));
                                ori_message1_temp(5) = ori_message2_temp(5);
                            else %台站2错检
                                ori_message2_temp(3) = ori_message2_temp(4) - (ori_message1_temp(4) - ori_message1_temp(3));
                                ori_message2_temp(5) = ori_message1_temp(5);
                            end
                            ori_message1_recover = [ori_message1_recover; ori_message1_temp];
                            ori_message2_recover = [ori_message2_recover; ori_message2_temp];
                            continue; %找到框错的两个时间相邻的信号中时间靠后的
                        end
                    end
                end     
            else % 起始、终止时间均一致，起始频率一致，但终止频率不一致，则可能出现了同一时间有两个频率紧挨着的信号被框为了一个
                if abs(ori_message1_error(i, 3) - ori_message2_error(j, 3)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %起始时间范围一致
                    if abs(ori_message1_error(i, 4) - ori_message2_error(j, 4)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %终止时间范围一致
                        % 计算两站图中相对应的两个信号的时间差
                        [corr_peak2, tdoa2, mean_acor2] = TD_est(sig_depart1(i, :),sig_depart2(j, :));
                        if (corr_peak2 > 5e-16 && corr_peak2 / mean_acor2 > 5)
                            % 频率直接用另一台站检测到的起始、终止频率；起始时间用本站检测到起始时间+TDOA，终止时间用校正后的起始时间+另一接收站检测到信号的时长
                            % 先判断一下错检的是台站1还是台站2
                            ori_message1_temp = ori_message1_error(i, :);
                            ori_message2_temp = ori_message2_error(j, :);
                            if (ori_message1_error(i, 2) - ori_message1_error(i, 1) > ori_message2_error(i, 2) - ori_message2_error(i, 1)) %台站1错检
                                ori_message1_temp(1: 2) = ori_message2_temp(1: 2);
                                ori_message1_temp(3) = ori_message1_temp(3) + tdoa2;
                                ori_message1_temp(4) = ori_message1_temp(3) + (ori_message2_temp(4) - ori_message2_temp(3));
                                ori_message1_temp(5) = ori_message2_temp(5);
                            else %台站2错检
                                ori_message2_temp(1: 2) = ori_message1_temp(1: 2);
                                ori_message2_temp(3) = ori_message2_temp(3) + tdoa2;
                                ori_message2_temp(4) = ori_message2_temp(3) + (ori_message1_temp(4) - ori_message1_temp(3));
                                ori_message2_temp(5) = ori_message1_temp(5);
                            end
                            ori_message1_recover = [ori_message1_recover; ori_message1_temp];
                            ori_message2_recover = [ori_message2_recover; ori_message2_temp];
                            continue; %找到框错的两个频率相邻的信号中频率靠前的
                        end
                    end
                end
            end
        else % 起始、终止时间均一致，终止频率一致，但起始频率不一致，则可能出现了同一时间有两个频率紧挨着的信号被框为了一个
            if abs(ori_message1_error(i, 2) - ori_message2_error(j, 2)) < 0.01 * (ori_message1_error(i, 2) - ori_message1_error(i, 1)) %终止频率范围一致
                if abs(ori_message1_error(i, 3) - ori_message2_error(j, 3)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %起始时间范围一致
                    if abs(ori_message1_error(i, 4) - ori_message2_error(j, 4)) < 0.005 * (ori_message1_error(i, 4) - ori_message1_error(i, 3)) %终止时间范围一致
                        % 计算两站图中相对应的两个信号的时间差
                        [corr_peak2, tdoa2, mean_acor2] = TD_est(sig_depart1(i, :),sig_depart2(j, :));
                        if (corr_peak2 > 5e-16 && corr_peak2 / mean_acor2 > 5)
                            % 频率直接用另一台站检测到的起始、终止频率；起始时间用本站检测到起始时间+TDOA，终止时间用校正后的起始时间+另一接收站检测到信号的时长
                            % 先判断一下错检的是台站1还是台站2
                            ori_message1_temp = ori_message1_error(i, :);
                            ori_message2_temp = ori_message2_error(j, :);
                            if (ori_message1_error(i, 2) - ori_message1_error(i, 1) > ori_message2_error(i, 2) - ori_message2_error(i, 1)) %台站1错检
                                ori_message1_temp(1: 2) = ori_message2_temp(1: 2);
                                ori_message1_temp(3) = ori_message1_temp(3) + tdoa2;
                                ori_message1_temp(4) = ori_message1_temp(3) + (ori_message2_temp(4) - ori_message2_temp(3));
                                ori_message1_temp(5) = ori_message2_temp(5);
                            else %台站2错检
                                ori_message2_temp(1: 2) = ori_message1_temp(1: 2);
                                ori_message2_temp(3) = ori_message2_temp(3) + tdoa2;
                                ori_message2_temp(4) = ori_message2_temp(3) + (ori_message1_temp(4) - ori_message1_temp(3));
                                ori_message2_temp(5) = ori_message1_temp(5);
                            end
                            ori_message1_recover = [ori_message1_recover; ori_message1_temp];
                            ori_message2_recover = [ori_message2_recover; ori_message2_temp];
                            continue; %找到框错的两个频率相邻的信号中频率靠后的
                        end
                    end
                end
            end
        end
    end
end

end