clc
close all
clear
load DAD_RMSE_SNR.mat;
load MPR_RMSE_SNR.mat;
load TDOA_RMSE_SNR.mat;
load SNR_receive.mat;

figure;

semilogy(SNR_receive, TDOA_MSE, 'o-', 'color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5, 'MarkerSize', 8); hold on;
semilogy(SNR_receive, MPR_MSE, 's--', 'color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5, 'MarkerSize', 8);
semilogy(SNR_receive, DAD_MSE, '^-.', 'color', [0.4660 0.6740 0.1880], 'LineWidth', 1.5, 'MarkerSize', 8);

% 图例、标题、坐标轴
legend({'TDOA-LS', 'SUM-MPR', 'DAD'}, 'FontSize', 12);
title('不同SNR测向性能对比图', 'FontSize', 14);
xlabel('SNR(dB)', 'FontSize', 12);
ylabel('RMSE(θ)(°)', 'FontSize', 12);
grid on;