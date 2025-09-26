% calculateAndDisplaySourceReceiverDistances.m
function [droneRecDistMatrix, wifiRecDistMatrix] = calculateDistances(droneLocs, wifiLocs, receiverLocs)
% calculateAndDisplaySourceReceiverDistances 计算无人机和 WiFi 源到接收站点的欧氏距离并打印结果
%   [droneRecDistMatrix, wifiRecDistMatrix] = calculateAndDisplaySourceReceiverDistances(droneLocs, wifiLocs, receiverLocs)
%
%   输入参数:
%     droneLocs:    无人机位置坐标 (n_drones x 2 矩阵)。每一行代表一架无人机 [x, y]。
%     wifiLocs:     WiFi 信号源位置坐标 (n_wifi x 2 矩阵)。每一行代表一个 WiFi 源 [x, y]。
%     receiverLocs: 接收台站位置坐标 (n_rx x 2 矩阵)。每一行代表一个接收站 [x, y]。
%
%   输出参数:
%     droneRecDistMatrix: 计算出的无人机到接收站距离矩阵 (n_drones x n_rx 矩阵)。
%     wifiRecDistMatrix:  计算出的 WiFi 源到接收站距离矩阵 (n_wifi x n_rx 矩阵)。
%                     距离单位与输入坐标单位一致 (这里假定为米)。
%
%   同时，此函数会将计算出的距离矩阵打印到命令窗口。

    % 获取源和接收站的数量
    drones_num = size(droneLocs, 1);
    wifi_num = size(wifiLocs, 1); % 获取 WiFi 源数量
    rec_num = size(receiverLocs, 1);

    %% --- 计算无人机到接收站点的距离 ---
    droneRecDistMatrix = zeros(drones_num, rec_num); % 初始化矩阵

    for i = 1:drones_num % 循环遍历每架无人机
        x_drone = droneLocs(i, 1);
        y_drone = droneLocs(i, 2);
        for j = 1:rec_num % 循环遍历每个接收站点
            x_rec = receiverLocs(j, 1);
            y_rec = receiverLocs(j, 2);
            droneRecDistMatrix(i, j) = sqrt((x_rec - x_drone)^2 + (y_rec - y_drone)^2);
        end
    end

    %% --- 计算 WiFi 信号源到接收站点的距离 ---
    wifiRecDistMatrix = zeros(wifi_num, rec_num); % 初始化矩阵

    for i = 1:wifi_num % 循环遍历每个 WiFi 信号源
        x_wifi = wifiLocs(i, 1);
        y_wifi = wifiLocs(i, 2);
        for j = 1:rec_num % 循环遍历每个接收站点
            x_rec = receiverLocs(j, 1);
            y_rec = receiverLocs(j, 2);
            wifiRecDistMatrix(i, j) = sqrt((x_rec - x_wifi)^2 + (y_rec - y_wifi)^2);
        end
    end

    %% --- 显示计算出的距离结果 ---

    % 显示无人机到接收站的距离
    fprintf('\n--- 无人机到接收站点的距离 (米) ---\n');
    row_labels_drone = cell(1, drones_num);
    for i = 1:drones_num
        row_labels_drone{i} = sprintf('Drone %d', i);
    end
    col_labels = cell(1, rec_num);
    for j = 1:rec_num
        col_labels{j} = sprintf('Rx %d', j);
    end
    fprintf('%10s', '');
    for j = 1:rec_num
        fprintf('%15s', col_labels{j});
    end
    fprintf('\n');
    for i = 1:drones_num
        fprintf('%-10s', row_labels_drone{i});
        for j = 1:rec_num
            fprintf('%15.2f', droneRecDistMatrix(i, j));
        end
        fprintf('\n');
    end

    % 显示 WiFi 信号源到接收站的距离
    fprintf('\n--- WiFi 信号源到接收站点的距离 (米) ---\n');
    row_labels_wifi = cell(1, wifi_num);
     for i = 1:wifi_num
        row_labels_wifi{i} = sprintf('WiFi %d', i);
    end
    % 列标签 (接收站) 与上面相同，无需重复创建

    fprintf('%10s', '');
    for j = 1:rec_num
        fprintf('%15s', col_labels{j});
    end
    fprintf('\n');
    for i = 1:wifi_num
        fprintf('%-10s', row_labels_wifi{i});
        for j = 1:rec_num
            fprintf('%15.2f', wifiRecDistMatrix(i, j));
        end
        fprintf('\n');
    end

    % 函数执行完毕，距离矩阵作为输出返回
    % droneRecDistMatrix 将是第一个输出
    % wifiRecDistMatrix 将是第二个输出

end