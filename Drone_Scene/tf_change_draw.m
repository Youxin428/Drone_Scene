function out = tf_change_draw(tf_matrix1,part_long,nfft,Fs)

tf_matrix2 = tf_matrix1;

% tf_matrix2(:,1) = floor((tf_matrix2(:,1)+Fs/2)/(Fs/nfft)); %起始频率对应图中索引值
% tf_matrix2(:,2) = floor((tf_matrix2(:,2)+Fs/2)/(Fs/nfft)); %终止频率对应图中索引值
tf_matrix2(:,1) = floor((tf_matrix2(:,1))/(Fs/nfft)); %起始频率对应图中索引值
tf_matrix2(:,2) = floor((tf_matrix2(:,2))/(Fs/nfft)); %终止频率对应图中索引值

tf_matrix2(:,3) = floor(tf_matrix2(:,3)/part_long)+1; %起始时间对应图中索引值
tf_matrix2(:,4) = ceil(tf_matrix2(:,4)/part_long)+1; %终止时间对应图中索引值

out = tf_matrix2;

end