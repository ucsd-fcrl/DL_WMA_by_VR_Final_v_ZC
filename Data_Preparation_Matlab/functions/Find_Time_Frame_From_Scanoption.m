function [TF_string,TF_num] = Find_Time_Frame_From_Scanoption(scanoption)

% make sure it starts with TP
if scanoption(1) ~= 'T' && scanoption(2) ~= 'P'
    msg = 'Error: not start with TP';
    error(msg)
end

% 
i = 3;
TP = [];
while (1 == 1)
    a = str2num(scanoption(i));
    if size(a,1) == 0
        break
    else
        TP = [TP scanoption(i)];
    end
    i = i + 1;
end
TF_string = TP;
TF_num = str2num(TF_string);
    
    
    
