function out = tf_change_ori(tf_infor,Fs)

tf_matrix1 = tf_infor;
tf_matrix1(:,1) = tf_infor(:,1)-(tf_infor(:,2)/2); %��ʼƵ��
tf_matrix1(:,2) = tf_infor(:,1)+(tf_infor(:,2)/2); %��ֹƵ��

tf_matrix1(:,3) = floor(tf_matrix1(:,3)*Fs); %��ʼʱ���Ӧ���źŵ���
tf_matrix1(:,4) = ceil(tf_matrix1(:,4)*Fs); %��ֹʱ���Ӧ���źŵ���

out = tf_matrix1;

end