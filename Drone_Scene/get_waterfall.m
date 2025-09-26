function out = get_waterfall(sig1,part_long,nfft,Fs)

N = length(sig1);
water_row = floor(N/part_long);
waterfall1 = zeros(water_row,nfft);

for ii = 1:water_row-1
    waterfall1(ii,:) = fftshift(abs(fft(sig1((ii-1)*part_long+1:ii*part_long),nfft)));
end
waterfall1(water_row,:) = fftshift(abs(fft(sig1((water_row-1)*part_long+1:end),nfft)));

left_point = nfft/2+1;
right_point = ceil(nfft/2+nfft/2*(20/25));
waterfall2 = waterfall1(:,left_point:right_point);
% waterfall2 = waterfall1;

waterfall3 = waterfall2.^2;
max_value = max(max(waterfall3));

out = (waterfall3./max_value)*10;

end