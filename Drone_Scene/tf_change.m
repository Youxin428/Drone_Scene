function out = tf_change(tf_infor,part_long,nfft,Fs)
% �������壺���źŵ������������Ƶ������ʱ�䣩ת��Ϊ�ٲ�ͼ�ϵ�����������
% 
% tf_infor���������ͨ������ÿһ���źŵ������������ʽΪ [��Ƶ(Hz), ����(Hz), ��ʼʱ��(s), ����ʱ��(s)] �Ķ��о���
% part_long�����������ٲ�ͼʱ��ʱ��γ��ȣ�������������
% nfft�����������ٲ�ͼʱ����FFT�ĵ�����
% Fs���źŵĲ���Ƶ�ʡ�
% out��������󣬰���ת������ٲ�ͼ�ϵ����������꣬��ʽΪ [��ʼƵ��, ��ֹƵ��, ͼ����ʼ����, ͼ����ֹ����]��

tf_matrix1 = tf_infor;
tf_matrix1(:,1) = tf_infor(:,1)-(tf_infor(:,2)/2); 
tf_matrix1(:,2) = tf_infor(:,1)+(tf_infor(:,2)/2);

tf_matrix1(:,3) = floor(tf_matrix1(:,3)*Fs); % ��ʼʱ���Ӧ���źŵ���
tf_matrix1(:,4) = ceil(tf_matrix1(:,4)*Fs);  % ��ֹʱ���Ӧ���źŵ���

tf_matrix2 = tf_matrix1;

tf_matrix2(:,1) = floor((tf_matrix2(:,1))/(Fs/nfft)); %��ʼƵ��
tf_matrix2(:,2) = floor((tf_matrix2(:,2))/(Fs/nfft)); %��ֹƵ��
% tf_matrix2(:,1) = floor((tf_matrix2(:,1)+Fs/2)/(Fs/nfft)); %��ʼƵ�ʶ�Ӧͼ������ֵ
% tf_matrix2(:,2) = floor((tf_matrix2(:,2)+Fs/2)/(Fs/nfft)); %��ֹƵ�ʶ�Ӧͼ������ֵ

tf_matrix2(:,3) = floor(tf_matrix2(:,3)/part_long)+1;    % ��ʼʱ���Ӧͼ������ֵ
tf_matrix2(:,4) = ceil(tf_matrix2(:,4)/part_long)+1;      % ��ֹʱ���Ӧͼ������ֵ

out = tf_matrix2;

end