clc
clear
close all
warning off

%% --- 基本仿真参数设置 ---
c = 3e8; 
Fs = 140e6; 
Fd = 20e3; 
nfft = 65536*2;  
duration_s = 0.001;
data_long  = round(duration_s * Fs); 
K = 100; %蒙特卡洛次数

%% --- 位置坐标设置 (米) ---
drones_num = 1; 

drone_loc = [1200, 8000]; 
rec_loc_full = [[600,500];[1000,100];[500,-700];[-400,-600];[-100,500];[100,-1000];[200,100]]; 
wifi_loc = [1100, 0]; 
plotStationLocations(drone_loc, rec_loc_full,wifi_loc);
% [dist_drone_rec, dist_wifi_rec] = calculateDistances(drone_loc, wifi_loc, rec_loc);

ref_site_idx = 1;  %参考站点id
refer_pos = rec_loc_full(ref_site_idx,:);
% mean_pos = [mean(rec_loc_full(:,1)),mean(rec_loc_full(:,2))];
aoa_real = rad2deg(atan2(drone_loc(2) - refer_pos(2), drone_loc(1) - refer_pos(1)));
dist_real = norm(refer_pos - drone_loc);
% aoa_mean = rad2deg(atan2(drone_loc(2) - mean_pos(2), drone_loc(1) - mean_pos(1)));
fprintf('\n--- 无人机相对于站%d的位置信息 ---\n',ref_site_idx);
fprintf('方位（东偏北） = %.2f °\n', aoa_real);
% fprintf('方位（重心） = %.2f °\n', aoa_mean);
fprintf('距站点距离 = %.1f m\n', dist_real);


%% --- 信道模型参数设置 ---
decline_para = [1, 1, 1]; % 传输衰减模型参数

% --- 噪声参数设置 (基于 NPSD 和带宽) ---
N0_dbw_per_hz = -174; % 噪声功率谱密度 (NPSD)，单位 dBW/Hz
B_wifi = 20e6;  
B_drone = 10e6; 

noise_power_dbw_wifi = N0_dbw_per_hz + 10*log10(B_wifi);
noise_power_dbw_drone = N0_dbw_per_hz + 10*log10(B_drone);  %添加的噪声功率（dBW）

%% --- 无人机信号发射参数设置 ---
sig_power_dBm = 26; 
sig_power_W = 10^((sig_power_dBm - 30)*0.1); 

target_freq_start = 5725e6; % 跳频范围起始频率 (Hz)
target_freq_end = 5850e6;   % 跳频范围结束频率 (Hz)

rec_num_vector = 4:7; 


TDOA_MSE = zeros(1,length(rec_num_vector));
MPR_MSE = zeros(1,length(rec_num_vector));
DAD_MSE = zeros(1,length(rec_num_vector));

for num_idx = 1:length(rec_num_vector)
    rec_num = rec_num_vector(num_idx);
    rec_loc = rec_loc_full(1:rec_num,:);
    mean_pos = [mean(rec_loc(:,1)),mean(rec_loc(:,2))];
    aoa_mean = rad2deg(atan2(drone_loc(2) - mean_pos(2), drone_loc(1) - mean_pos(1)));
    fprintf('方位（重心） = %.2f °\n', aoa_mean);

    %% --- 通用绘图和分析参数设置 ---
    plot_part_long_analysis = 20000;
    noverlap = round(nfft * 0.5);
    rf_plot_center = (target_freq_start + target_freq_end) / 2; % Spectrogram 频率轴中心参考 (Hz)

    %% --- 数据存储与处理初始化 ---
    rec_sig = cell(drones_num, rec_num); % 无人机 i 到接收站 j 的信号
    rec_message_raw = cell(drones_num, rec_num); % 无人机 waterfall_message (时延补偿后)时频图中的索引，[]
    ori_message_raw = cell(drones_num, rec_num); % 无人机 signal_parameters (时延补偿后)[起始频率，终止频率，信号起始点索引，信号终止点索引]
    rec_wifi_sig = cell(1, rec_num);

    len = zeros(1, rec_num);
    td = zeros(drones_num, rec_num);
    point = zeros(drones_num, rec_num);

    TDOA_est_bias = zeros(1,K);
    MPR_est_bias = zeros(1,K);
    DAD_est_bias = zeros(1,K);

    for kk = 1:K
        %% --- 模拟无人机信号到达每个站 无人机 ---

        for i = 1:drones_num % 循环处理每个无人机

            [downlink_signal, used_Fc_sequence, waterfall_message, signal_parameters, waterfall_segment_long, rf_from_func] = generateDownlinkSignal(Fs, ...
                sig_power_W, nfft, data_long,target_freq_start,target_freq_end,B_drone);
            for j = 1:rec_num % 循环处理每个接收站接收到的信号
                % 1. 计算距离
                d_ij = sqrt((rec_loc(j, 1) - drone_loc(i, 1))^2 + (rec_loc(j, 2) - drone_loc(i, 2))^2);

                % 2. 计算时延
                td(i, j) = d_ij / c;
                point(i, j) = round(td(i, j) * Fs);

                % 3. 创建并应用时延
                temp_long_ij = data_long + point(i, j);
                len(j) = max(len(j), temp_long_ij); % 更新接收站所需最大长度
                delay_data_ij = zeros(1, temp_long_ij);
                delay_data_ij(point(i, j) + 1 : temp_long_ij) = downlink_signal;

                % 4. 计算并应用传输衰减
                %后面可以优化 使用跳频范围的中心作为路径损耗计算频率 (简化处理)
                f_c_i = min(used_Fc_sequence) + (max(used_Fc_sequence) - min(used_Fc_sequence)) / 2;
                loss_temp_ij_db = decline_mode(decline_para, f_c_i/1e6, d_ij/1e3);
                loss_ij_linear = power(10, loss_temp_ij_db/20); % 线性衰减因子
                attenuated_signal_ij = delay_data_ij / loss_ij_linear; % 应用衰减

                % 5. 添加噪声 (功率基于 NPSD 和无人机带宽)
                noise_ij = wgn(1, temp_long_ij, noise_power_dbw_drone, 1, 'complex');
                noise_power_compute_ij = sum(abs(noise_ij).^2)/temp_long_ij;

                % 7. 叠加信号与噪声
                rec_sig{i, j} = attenuated_signal_ij + noise_ij;
                % rec_sig{i, j} = attenuated_signal_ij ;

                % --- 可选: 绘制中间信号时频图 (需要 plot_signal_analysis2 函数) ---
                % if i == 1 && j == 1
                %    plot_signal_analysis2(rec_sig{i, j}, Fs, plot_part_long_analysis, nfft, rf_plot_center,...
                %       sprintf('drone %d to Rx %d - After Attenuation and Noise', i, j));
                % end

                % --- 调整接收站 j 的标注信息 (时延补偿) ---
                point_change_ij = round(point(i, j) / waterfall_segment_long) + 1;
                rec_message_raw{i, j} = waterfall_message;
                rec_message_raw{i, j}(:, 3 : 4) = rec_message_raw{i, j}(:, 3 : 4) + point_change_ij; % 时间信息在第 3/4 列，按瀑布图段偏移

                ori_message_temp_ij = tf_change_ori(signal_parameters, Fs); % 转换时间单位为采样点数
                ori_message_raw{i, j} = ori_message_temp_ij;
                ori_message_raw{i, j}(:, 3 : 4) = ori_message_raw{i, j}(:, 3 : 4) + point(i, j);

            end % 结束接收站循环
        end % 结束无人机循环


        %% --- 跳频信号接收端处理：信号合成 ---
        overall_max_len = max(len);

        % 初始化 cell 数组存储每个接收站合成后的信号和合并后的标注信息
        finally_data_rec = cell(1, rec_num); % finally_data_rec{j} 存储接收站 j 合成后的信号
        rec_message_combined = cell(1, rec_num); % 合并后的无人机 waterfall_message 标注信息
        ori_message_combined = cell(1, rec_num); % 合并后的无人机 signal_parameters 标注信息

        % 遍历每个接收站进行信号合成
        for j = 1:rec_num
            % 初始化接收站 j 合成后的总信号向量，长度为全局最大长度
            finally_data_rec{j} = zeros(1, overall_max_len);

            % 将来自 WiFi 干扰源的信号添加到合成信号中
            sig_wifi_j = rec_wifi_sig{j};
            padded_sig_wifi_j = [sig_wifi_j, zeros(1, overall_max_len - length(sig_wifi_j))];
            finally_data_rec{j} = finally_data_rec{j} + padded_sig_wifi_j;

            % 初始化接收站 j 合并后的标注信息矩阵 (只针对无人机信号)
            rec_message_combined{j} = [];
            ori_message_combined{j} = [];

            % 叠加来自每个无人机的信号
            for i = 1:drones_num
                % 获取来自 Tx i 到 Rx j 的接收信号 (已包含时延、衰减和噪声)
                sig_ij = rec_sig{i, j};
                % 将无人机信号用零填充到全局最大长度
                padded_sig_ij = [sig_ij, zeros(1, overall_max_len - length(sig_ij))];
                % 叠加无人机信号
                finally_data_rec{j} = finally_data_rec{j} + padded_sig_ij;

                % 合并来自 Tx i 的标注信息 (只针对无人机信号)
                rec_message_combined{j} = [rec_message_combined{j}; rec_message_raw{i, j}];
                ori_message_combined{j} = [ori_message_combined{j}; ori_message_raw{i, j}];
            end

            % 对接收站 j 合成后的无人机信号标注信息进行排序 (按时间顺序)
            rec_message_combined{j} = sortrows(rec_message_combined{j});
            ori_message_combined{j} = sortrows(ori_message_combined{j});

            % --- 可选：绘制接收站 j 合成信号的幅度图和时频图 (需要 plot_signal_analysis2 函数) ---
            % if j == 1 % 例如只绘制第一个接收站的合成信号图
            %     plot_part_long_synthesis = 2000; % 分析窗口长度
            %     plot_signal_analysis2(finally_data_rec{j}, Fs, plot_part_long_synthesis, nfft, rf_plot_center, ...
            %         sprintf('Composite Signal Received at Rx%d (Power + Noise)', j));
            % end

        end % 结束接收站合成循环


        %% --- 使用接收站信息协同测向 ---
        band_width = signal_parameters(2);
        fc = signal_parameters(1);

        sig_baseband = zeros(rec_num, length(finally_data_rec{1}));
        sig_rec = zeros(rec_num, length(finally_data_rec{1}));
        for i = 1:rec_num
            % t_ddc = (0:N-1)/Fs;  % 重新定义时间向量避免累积误差
            % sig_baseband(i,:) = finally_data_rec{i} .* exp(-1i*2*pi*fc*t_ddc);
            sig_baseband(i,:) = Fc_Change_0302(finally_data_rec{i}, Fs, fc-rf_plot_center);
            sig_rec(i,:) = overlap_retention(sig_baseband(i,:), Fs, 12e6);
        end
        % plot_checkFliter(finally_data_rec{1},sig_baseband(1,:),sig_rec(1,:),Fs);

        %% --- SUM_MPR ---
        % 计算互相关
        for i = 1:rec_num
            signal1 = sig_rec(ref_site_idx,:);
            signal2 = sig_rec(i,:);

            if i == ref_site_idx
                TDOA(i) = 0;
                continue;
            end
            rdoa_max = norm(rec_loc(i,:)-rec_loc(ref_site_idx,:));
            [TDOA(i),fdoa(i),ratio_cad_XI(i)]  = fast_Caf_F_joint_v9(Fs,signal1,signal2,signal_parameters(2),rdoa_max*1.05);
        end
        rcvPos_ori = rec_loc;
        A = repmat(rec_loc(ref_site_idx,:),rec_num,1);
        rec_loc =rec_loc-A;
        tdoa_sig = TDOA';
        %把参考站的位置放在首位，并取转置以输入MPR
        rec_loc([1 ref_site_idx], :) = rec_loc([ref_site_idx 1], :);
        tdoa_sig([1 ref_site_idx], :) = tdoa_sig([ref_site_idx 1], :);
        rec_loc = rec_loc';
        rdoa = tdoa_sig*c;

        sigmaSquareDB = 0;
        M = length(rec_loc(1,:));
        Q = 10^(sigmaSquareDB/10) * (ones(M-1, M-1)+eye(M-1))/2;

        [theta, g] = TDOA_SUM_MPR(rec_loc, rdoa(2:rec_num), Q);
        aoa_MPR = theta*180/pi;
        r_MPR = 1/g;
        fprintf('\n--- 相对于站%d的MPR测向结果 ---\n',ref_site_idx);
        fprintf('方位（东偏北） = %.2f °\n', aoa_MPR);
        % fprintf('距站点距离 = %.1f m\n', r_MPR);
        MPR_est_bias(kk) = (aoa_MPR-aoa_real)^2;

        %% --- TODA:LS+牛顿迭代 ---
        % u0 = TDOA_LS_2D(rec_loc,rdoa(2:rec_num)') + rcvPos_ori(ref_site_idx,:)';
        rdoa_NEWTON = rdoa(2:rec_num)';
        u0 = TDOA_LS_2D(rec_loc,rdoa_NEWTON) ;

        Newton_loc = [rec_loc(:,1),rec_loc(:,2),rec_loc(:,1),rec_loc(:,3),rec_loc(:,1),rec_loc(:,4)];
        u_TDOA = TDOA_NEWTON_2D(u0, Newton_loc, -rdoa_NEWTON) + rcvPos_ori(ref_site_idx,:)';
        aoa_TDOA = rad2deg(atan2(u_TDOA(2) - refer_pos(2), u_TDOA(1) - refer_pos(1)));
        dist_TDOA = norm(u_TDOA' - refer_pos);
        fprintf('\n--- 相对于站%d的TDOA测向结果 ---\n',ref_site_idx);
        fprintf('方位（东偏北） = %.2f °\n', aoa_TDOA);
        % fprintf('距站点距离 = %.1f m\n', dist_TDOA);
        TDOA_est_bias(kk) = (aoa_TDOA-aoa_real)^2;

        %% --- DAD ---
        sig_fft = zeros(rec_num, size(sig_rec,2));
        for i = 1:rec_num
            sig_fft(i,:) = fftshift(fft(sig_rec(i,:)));
        end
        [aoa_DAD_rough,~] = DAD_parfor(rcvPos_ori,sig_fft,Fs,60,1,120);
        [aoa_DAD,~] = DAD_parfor(rcvPos_ori,sig_fft,Fs,aoa_DAD_rough-1,0.1,aoa_DAD_rough+1);

        fprintf('\n--- 相对于站%d的DAD测向结果 ---\n',ref_site_idx);
        fprintf('方位（东偏北） = %.2f °\n', aoa_DAD);
        % fprintf('距站点距离 = %.1f m\n', r_DAD);
        DAD_est_bias(kk) = (aoa_DAD-aoa_mean)^2;

        rec_loc = rec_loc_full(1:rec_num,:);
    end

    TDOA_MSE(num_idx) = 10*log10(sum(TDOA_est_bias)/K);
    MPR_MSE(num_idx) = 10*log10(sum(MPR_est_bias)/K);
    DAD_MSE(num_idx) = 10*log10(sum(DAD_est_bias)/K);
    % TDOA_MSE(num_idx) = sqrt(sum(TDOA_est_bias)/K);
    % MPR_MSE(num_idx) = sqrt(sum(MPR_est_bias)/K);
    % DAD_MSE(num_idx) = sqrt(sum(DAD_est_bias)/K);

end

% 画图
figure;

plot(rec_num_vector, TDOA_MSE, 'o-', 'color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5, 'MarkerSize', 8); hold on;
plot(rec_num_vector, MPR_MSE, 's--', 'color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5, 'MarkerSize', 8);
plot(rec_num_vector, DAD_MSE, '^-.', 'color', [0.4660 0.6740 0.1880], 'LineWidth', 1.5, 'MarkerSize', 8);

% 图例、标题、坐标轴
legend({'TDOA-LS', 'SUM-MPR', 'DAD'}, 'FontSize', 12);
title('站点数量对测向性能影响仿真对比图', 'FontSize', 14);
xlabel('站点数量', 'FontSize', 12);
ylabel('10*logMSE(θ)(°²)', 'FontSize', 12);
grid on;