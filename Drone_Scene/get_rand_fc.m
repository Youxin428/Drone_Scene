function out = get_rand_fc(Fc,num)

% FcΪ����ѡ���Ƶ��
% num���ɶ��ٶ��ź�

peoject_interval = 2; % �������������ѡ��һ��Fc_now�����������peoject_Fc��Fc_afterӦ����Fc_now����ͬ
                      % �������һ��Fc1�󣬺�����������peoject_Fc��Fc����Ӧ�õ���Fc1
N = length(Fc);
out = zeros(1,num);
project_Fc = zeros(1,peoject_interval);

for ii = 1:num
    rand_Fc = 0;
    while(1)
        rand_Fc = randi([1, N]);
        if (sum(ismember(project_Fc,rand_Fc)) < 0.5)
            for jj = 1:(peoject_interval-1)
                project_Fc(jj) = project_Fc(jj+1);
            end
            project_Fc(peoject_interval) = rand_Fc;
            break;
        end
    end
    
    out(ii) = Fc(rand_Fc);%��������ȡ����Ӧ��Ƶ��
end

end


% 1. ��ǰ�����߼���peoject_interval=2��
% ����������壺ȷ����ǰѡ���Ƶ���ڽ������� 2 ��λ�� �в����ظ���
% ʵ�ַ�ʽ��
% ά��һ������Ϊ 2 �Ĵ��� project_Fc����¼���ѡ���Ƶ��������
% ÿ��������Ƶ��ʱ�����������Ƿ�����ڴ����С�
% ������������ѡ��ֱ���ҵ�һ�����ڴ����е�������
% ���´��ڣ��Ƴ���ɵ������������������

% 2. �޸Ĳ�����Ӱ�죨peoject_interval =3��
% ���������չ����ǰѡ���Ƶ���ڽ������� 3 ��λ�� �в����ظ���
% Ч����
% ����������Ƶ�㲻�ظ���ȷ��ÿ����Ƶ����ǰ����λ�õ�Ƶ�ʲ�ͬ��
% ���ڳ��ȵ�����project_Fc ���鳤�ȱ�Ϊ 3����¼�������ѡ���������
% ѡ�����Ƽ�ǿ����Ƶ�ʱ������������ѡ���Ƶ�ʲ�ͬ��