
%% �˲�����ֹƵ��==Fd/2��ѡ���ڲ����������˲���

function base_sig = inside_sig_produce_with_filter_up_Fd(label,msg,Fd,Fs)

% label��ѡȡ�����źŵ����࣬��ѡ�ź����ࣺBPSK��8PSK��QPSK��16QAM��2FSK��DQPSK4��OQPSK
% msg���źŷ���
% Fd����Ԫ����
% Fs������Ƶ��


L = Fs/Fd;
new_Fs = Fs;
key = 0;
if rem(L,1) ~= 0
    L = ceil(L);
    if mod(L,2)==1
        L=L+1;
    end
    new_Fs = L*Fd;
    key = 1;
end

beta = 0.35; % ����ϵ��
span = 8; % �ضϷ��ŷ�Χ�����ϲ�һ��ȡ4��8
shape = 'normal'; % �Ƿ�Ϊ��������
h1 = rcosdesign(beta,span,L,shape); % �����˲���ϵ��
h2 = fft(h1);
h3 = h2./max(h2);
h = ifft(h3);


%% --- ���Ƴ����˲�������״ ---
% figure;   % ����һ���µ�ͼ�δ���
% stem(h1); % ʹ�ø�״ͼ������ɢ�ĳ弤��Ӧ��
% grid on; 
% title('�������˲����弤��Ӧ (h1 - ���� rcosdesign)');
% xlabel('���� (Samples)');
% ylabel('���� (Amplitude)');


%%
switch label
    case 'BPSK'
        M = 2;
        ini_phase = 0;
        Rsignal = pskmod(msg,M,ini_phase);
        base_sig = upfirdn(Rsignal,h,L);
        
    case 'QPSK'
        M = 4;
        ini_phase = pi/4;
        Rsignal = pskmod(msg,M,ini_phase);
        base_sig = upfirdn(Rsignal,h,L);  
   
    case '8PSK'
        M = 8;
        ini_phase = 0;
        Rsignal = pskmod(msg,M,ini_phase);
        scatterplot(Rsignal)
        base_sig = upfirdn(Rsignal,h,L); 
        
    case '16QAM'
        M = 16;
        Rsignal = qammod(msg,M);
        
        d = 1/3;
        Rsignal = d.*Rsignal;
        base_sig = upfirdn(Rsignal,h,L);
 
    case '2FSK'

        Fre_space = Fd;
        base_sig = fskmod(msg,2,Fre_space,L,Fs);

    case 'DQPSK4'
        M = 4;
        Rsignal = dpskmod(msg,M,pi/4);
        base_sig = upfirdn(Rsignal,h,L);
        
    case 'OQPSK'
        M = 4;
        Rsignal = pskmod(msg,M,pi/4);        
        
        I_sig1 = real(Rsignal).';
        I_sig2 = upsample(I_sig1,2);
        I_sig = reshape(I_sig2,1,[]);   
        Q_sig1 = imag(Rsignal).';
        Q_sig2 = upsample(Q_sig1,2);
        Q_sig = reshape(Q_sig2,1,[]); 

        I_sig = [I_sig 0];
        Q_sig = [0 Q_sig];
        Rsignal = complex(I_sig,Q_sig);
        base_sig = upfirdn(Rsignal,h,L);

	case '2ASK'
        % 1.ASK
        M = 2;
        ini_phase = 0;
        
        Rsignal = pskmod(msg,M,ini_phase);
		Rsignal(Rsignal==0) = -1;
        base_sig = upfirdn(Rsignal,h,L);	
	
	case '64QAM'
        % 7.64QAM
        M = 64;
        Rsignal = qammod(msg,M);
        
        d = 1/7;
        Rsignal = d.*Rsignal;
        base_sig = upfirdn(Rsignal,h,L);	
    
	otherwise
        % ����
end

if key == 1
    base_sig = resample(base_sig,Fs,new_Fs);
end
filter_len = length(h);
base_sig = base_sig(ceil(filter_len/2):end-floor(filter_len/2));
base_sig = reshape(base_sig,1,[]);
end














