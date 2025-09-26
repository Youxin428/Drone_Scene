function out = tf_change_ori(tf_infor,Fs)

tf_matrix1 = tf_infor;
tf_matrix1(:,1) = tf_infor(:,1)-(tf_infor(:,2)/2); %起始频率
tf_matrix1(:,2) = tf_infor(:,1)+(tf_infor(:,2)/2); %终止频率

tf_matrix1(:,3) = floor(tf_matrix1(:,3)*Fs); %起始时间对应的信号点数
tf_matrix1(:,4) = ceil(tf_matrix1(:,4)*Fs); %终止时间对应的信号点数

out = tf_matrix1;

end