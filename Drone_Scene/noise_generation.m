% 函数定义：生成指定长度和功率的高斯白噪声
% function [noise, noise_power_compute] = noise_generation(data_long, noise_power)
% data_long：需要生成的噪声向量的长度（采样点数）
% noise_power：期望生成的噪声的平均功率（线性值，不是 dBm）
% noise：生成的噪声向量（通常是复数）
% noise_power_compute：计算出的最终生成的噪声的平均功率（用于验证）
function [noise, noise_power_compute] = noise_generation(data_long, noise_power)
% 生成噪声
noise = randn(1,data_long)+1i*randn(1,data_long);
noise = noise-mean(noise);
noise = noise/std(noise);
noise_std_power = sum(abs(noise).^2)/data_long;
noise = (sqrt(1/noise_std_power))*noise;
noise = noise*sqrt(noise_power);
noise_power_compute = sum(abs(noise).^2)/length(noise);

end