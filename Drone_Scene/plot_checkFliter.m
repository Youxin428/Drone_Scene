function plot_checkFliter(finally_data_rec,sig_baseband,sig_rec,Fs)

figure;
N = length(finally_data_rec);
f = (-N/2:N/2-1)*Fs/N;
target_freq_start = 5725e6; % 跳频范围起始频率 (Hz)
target_freq_end = 5850e6;   % 跳频范围结束频率 (Hz)
rf_plot_center = (target_freq_start + target_freq_end) / 2;
fc = 5820e6;

subplot(3,1,1);
spectrum_original = abs(fftshift(fft(finally_data_rec)));
plot(f/1e6 + rf_plot_center/1e6, 20*log10(spectrum_original));
xlabel('频率 (MHz)'); ylabel('幅度 ');
title(['原始信号频谱 (中心频率 ' num2str(fc/1e9) 'GHz)']);
xlim([fc/1e6-65 fc/1e6+65]);  % 显示范围
grid on;

subplot(3,1,2);
spectrum_baseband = abs(fftshift(fft(sig_baseband)));
plot(f/1e6, 20*log10(spectrum_baseband));
xlabel('频率 (MHz)'); ylabel('幅度 ');
title('移频信号频谱');
xlim([-65 65]);  % 显示20MHz范围
grid on;

subplot(3,1,3);
spectrum_rec = abs(fftshift(fft(sig_rec)));
plot(f/1e6, 20*log10(spectrum_rec/max(spectrum_rec)));
xlabel('频率 (MHz)'); ylabel('幅度 ');
title('滤波信号频谱');
xlim([-20 20]);  % 显示20MHz范围
grid on;
end