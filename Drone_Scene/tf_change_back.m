function out = tf_change_back(tf_infor, Fs)

tf_matrix1 = tf_infor;

tf_matrix1(:,1) = tf_infor(:,1)+(tf_infor(:,2) - tf_infor(:,1))/2; %��Ƶ
tf_matrix1(:,2) = tf_infor(:,2)-tf_infor(:,1); %����

tf_matrix1(:,3) = tf_matrix1(:,3) / Fs; %��ʼʱ��
tf_matrix1(:,4) = tf_matrix1(:,4) / Fs; %��ֹʱ��

out = tf_matrix1;

end