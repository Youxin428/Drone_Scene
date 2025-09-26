function out = tf_change_back(tf_infor, Fs)

tf_matrix1 = tf_infor;

tf_matrix1(:,1) = tf_infor(:,1)+(tf_infor(:,2) - tf_infor(:,1))/2; %载频
tf_matrix1(:,2) = tf_infor(:,2)-tf_infor(:,1); %带宽

tf_matrix1(:,3) = tf_matrix1(:,3) / Fs; %起始时间
tf_matrix1(:,4) = tf_matrix1(:,4) / Fs; %终止时间

out = tf_matrix1;

end