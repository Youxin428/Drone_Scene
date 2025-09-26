% plotStationLocations.m
% 修改后的函数，根据输入顺序绘制 无人机、接收台站、WiFi信号源，减小标记大小，并增大文字标签偏移量
function plotStationLocations(droneLocs, receiverLocs, wifiLocs)
    % plotStationLocations 绘制无人机、接收台站和干扰WiFi信号源的位置
    % droneLocs:    无人机位置坐标 (n_drones x 2 矩阵)
    % receiverLocs: 接收台站位置坐标 (n_rx x 2 矩阵)
    % wifiLocs:     干扰WiFi信号源位置坐标 (n_wifi x 2 矩阵)

    drone_num = size(droneLocs, 1);
    rec_num = size(receiverLocs, 1);
    wifi_num = size(wifiLocs, 1);

    %% --- 创建图窗并绘制位置 ---
    figure();

    % 绘制无人机 (绿色钻石形) - 标记大小 80
    scatter(droneLocs(:, 1), droneLocs(:, 2), 80, 'red', 'd', 'filled', 'DisplayName', '无人机');

    hold on; % 保持当前图窗

    % 绘制接收台站 (蓝色方形) - 标记大小 60
    scatter(receiverLocs(:, 1), receiverLocs(:, 2), 60, 'b', 's', 'filled', 'DisplayName', '接收台站');

    % 绘制干扰WiFi信号源 (黑色六边形) - 标记大小 70
    % scatter(wifiLocs(:, 1), wifiLocs(:, 2), 70, 'k', 'h', 'filled', 'DisplayName', '干扰WiFi信号源');
    scatter(wifiLocs(:, 1), wifiLocs(:, 2), 'k', 'h', 'filled', 'DisplayName', '干扰WiFi信号源');
    %% --- 显示标签 ---
    % **增大文本偏移量，以避免重叠 (原 100 -> 150)**
    text_offset_x = 150;
    text_offset_y = 150;

    % 标记无人机
    for k = 1:drone_num
         x = droneLocs(k, 1);
         y = droneLocs(k, 2);
         text_string = sprintf('Drone %d', k);
         text(x + text_offset_x, y + text_offset_y, text_string, ...
              'VerticalAlignment', 'bottom', ...
              'HorizontalAlignment', 'left', ...
              'Color', 'r');
    end

    % 标记接收台站
    for k = 1:rec_num
        x = receiverLocs(k, 1);
        y = receiverLocs(k, 2);
        text_string = sprintf('Rx %d', k);
        text(x + text_offset_x, y + text_offset_y, text_string, ...
             'VerticalAlignment', 'bottom', ...
             'HorizontalAlignment', 'left', ...
             'Color', 'b');
    end

    % 标记干扰WiFi信号源
    for k = 1:wifi_num
         x = wifiLocs(k, 1);
         y = wifiLocs(k, 2);
         % text_string = sprintf('WiFi %d', k);

    end

    hold off; % 释放图窗保持状态

    % --- 设置图窗属性 ---
    xlabel('横坐标 (米)');
    ylabel('纵坐标 (米) - 正北方向'); % Y轴对应正北
    title('无人机、接收台站与干扰WiFi信号源位置分布');
    legend('show');

    % 设置坐标轴范围 - 考虑所有点和新的文本偏移量
    all_x = [droneLocs(:,1); receiverLocs(:,1); wifiLocs(:,1)];
    all_y = [droneLocs(:,2); receiverLocs(:,2); wifiLocs(:,2)];

    min_x = min(all_x);
    max_x = max(all_x);
    min_y = min(all_y);
    max_y = max(all_y);

    % 增加轴范围的缓冲，确保文本可见
    padding_x = 3 * text_offset_x; % 使用新的偏移量计算缓冲
    padding_y = 3 * text_offset_y; % 使用新的偏移量计算缓冲

    xlim([min_x - padding_x, max_x + padding_x]);
    ylim([min_y - padding_y, max_y + padding_y]);

    grid on; % 显示网格线有助于看清坐标轴

    % 请注意：此版本不包含之前添加的显式坐标轴线和原点标记。
    % 如果需要，请参考上一个回答的代码，将绘制轴线和原点的部分添加到 hold off; 之前。

    % axis equal; % 可选：设置横纵坐标轴比例相等， uncomment 此行 if needed
end