function out = tf_change(tf_infor,part_long,nfft,Fs)
% 函数定义：将信号的物理参数（载频、带宽、时间）转换为瀑布图上的索引或坐标
% 
% tf_infor：输入矩阵，通常包含每一段信号的物理参数，格式为 [载频(Hz), 带宽(Hz), 起始时间(s), 结束时间(s)] 的多行矩阵。
% part_long：用于生成瀑布图时的时间段长度（采样点数）。
% nfft：用于生成瀑布图时进行FFT的点数。
% Fs：信号的采样频率。
% out：输出矩阵，包含转换后的瀑布图上的索引或坐标，格式为 [起始频率, 终止频率, 图中起始索引, 图中终止索引]。

tf_matrix1 = tf_infor;
tf_matrix1(:,1) = tf_infor(:,1)-(tf_infor(:,2)/2); 
tf_matrix1(:,2) = tf_infor(:,1)+(tf_infor(:,2)/2);

tf_matrix1(:,3) = floor(tf_matrix1(:,3)*Fs); % 起始时间对应的信号点数
tf_matrix1(:,4) = ceil(tf_matrix1(:,4)*Fs);  % 终止时间对应的信号点数

tf_matrix2 = tf_matrix1;

tf_matrix2(:,1) = floor((tf_matrix2(:,1))/(Fs/nfft)); %起始频率
tf_matrix2(:,2) = floor((tf_matrix2(:,2))/(Fs/nfft)); %终止频率
% tf_matrix2(:,1) = floor((tf_matrix2(:,1)+Fs/2)/(Fs/nfft)); %起始频率对应图中索引值
% tf_matrix2(:,2) = floor((tf_matrix2(:,2)+Fs/2)/(Fs/nfft)); %终止频率对应图中索引值

tf_matrix2(:,3) = floor(tf_matrix2(:,3)/part_long)+1;    % 起始时间对应图中索引值
tf_matrix2(:,4) = ceil(tf_matrix2(:,4)/part_long)+1;      % 终止时间对应图中索引值

out = tf_matrix2;

end