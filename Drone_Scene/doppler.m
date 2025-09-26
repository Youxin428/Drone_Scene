function out = doppler(sig,Fs)
   %% base-parameters
    df = 1;
    n = length(sig);
    t = (0:1/Fs:(n-1)/Fs);   
%     M = length(sig(1,:));
    out = zeros(1,n);
    t_all = zeros(1,n);
%     index = zeros(n);
 
    %% 
%     max_val_dop = [
%         77.8;97.2;166.7;222.2;340;355; % 1-6
%         311.1;388.9;666.7;888.9;1360;1420; % 7-12
%         466.7;583.3;1000;1333.3;2040;2130; % 13-18
%         829.6;1037;1777.8;2370.4;3626.7;3786.7 % 19-24
%         ];
    cycle = [2;4;6;8];
    max_val_dop = [1e3/(4*pi), 5e3/(4*pi)];
   
    
    x1 = linspace(0,cycle(1)*pi,n);
%     x2 = linspace(0,cycle(1)*pi,n);
%     x3 = linspace(0,cycle(1)*pi,n);
%     x4 = linspace(0,cycle(1)*pi,n);

    index1 = max_val_dop(2)*(x1);
%     index2 = max_val_dop(23)*(x2);
%     index3 = max_val_dop(15)*sin(x3);
%     index4 = max_val_dop(22)*(x4);
    


%     index(:,2)= index2.';
%     index(:,3)= index3.';
%     index(:,4)= index4.';
    %% 
%     for i = 1:M
        t_all = t.*index1.*df;
%     end
%     for iu = 1:M
        out = sig.*exp(1j*2*pi*t_all);
%     end
    
end