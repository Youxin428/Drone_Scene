function out = tf_change_draw(tf_matrix1,part_long,nfft,Fs)

tf_matrix2 = tf_matrix1;

% tf_matrix2(:,1) = floor((tf_matrix2(:,1)+Fs/2)/(Fs/nfft)); %��ʼƵ�ʶ�Ӧͼ������ֵ
% tf_matrix2(:,2) = floor((tf_matrix2(:,2)+Fs/2)/(Fs/nfft)); %��ֹƵ�ʶ�Ӧͼ������ֵ
tf_matrix2(:,1) = floor((tf_matrix2(:,1))/(Fs/nfft)); %��ʼƵ�ʶ�Ӧͼ������ֵ
tf_matrix2(:,2) = floor((tf_matrix2(:,2))/(Fs/nfft)); %��ֹƵ�ʶ�Ӧͼ������ֵ

tf_matrix2(:,3) = floor(tf_matrix2(:,3)/part_long)+1; %��ʼʱ���Ӧͼ������ֵ
tf_matrix2(:,4) = ceil(tf_matrix2(:,4)/part_long)+1; %��ֹʱ���Ӧͼ������ֵ

out = tf_matrix2;

end