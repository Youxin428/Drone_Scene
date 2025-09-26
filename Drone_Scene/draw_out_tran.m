%% 对把横轴纵轴转化为真实时间、频率后的图做标记

function draw_out_tran(out,part_len,nfft,Fs,color)

tran_out = out;
tran_out(:,1) = out(:,1)*Fs/nfft;
tran_out(:,2) = out(:,2)*Fs/nfft;

tran_out(:,3) = (out(:,3)-1)*part_len/Fs;
tran_out(:,4) = out(:,4)*part_len/Fs;

draw_out(tran_out,color)

end