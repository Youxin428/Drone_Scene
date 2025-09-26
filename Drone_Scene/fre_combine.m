function out = fre_combine(data)

out = [];
if (~isempty(data))
    hold = 10;
    data_time = data;
    
    while(true)
        zz = 1;
        data_time = sortrows(data_time,1);
        N = length(data_time(:,1));
        temp_data = zeros(N,4);
        
        for ii = 1:N-1
            cur = [];
            if (data_time(ii,1) ~= -999)
                cur = data_time(ii,:);
                for jj = ii+1:N
                    if (data_time(jj,1) ~= -999)
                        flag = 0;
                        if (cur(1) <= data_time(jj,1))
                            if ((data_time(jj,1) <= cur(2)) || ((data_time(jj,1)-cur(2)) <= hold))
                                flag = 1;
                            end
                        else
                            if ((cur(1) <= data_time(jj,2)) || ((cur(1)-data_time(jj,2)) <= hold))
                                flag = 1;
                            end
                        end
                        
                        if (flag == 1)
                            if ((cur(3) <= data_time(jj,4)) && (cur(4) > data_time(jj,3)))
                                cur(1) = min([cur(1) data_time(jj,1)]);
                                cur(2) = max([cur(2) data_time(jj,2)]);
                                cur(3) = min([cur(3) data_time(jj,3)]);
                                cur(4) = max([cur(4) data_time(jj,4)]);
                                
                                data_time(jj,1) = -999;
                                break;
                            end
                        end
                    end
                end
            end
            if (~isempty(cur))
                temp_data(zz,:) = cur;
                zz = zz+1;
            end
        end
        
        if (data_time(N,1) ~= -999)
            temp_data(zz,:) = data_time(N,:);
            zz = zz+1;
        end
        temp_data(zz:end,:) = [];
        
        if (length(temp_data(:,1)) == N)
            out = temp_data;
            break;
        end
        data_time = temp_data;
        
    end
    
end

end