function [paths] = Find_paths_belong_to_patients(patient_choice,path_list)

path_num = [];
for i = 1: size(patient_choice,2)
    patient_num = patient_choice(i);
    for k = 1:size(path_list,1)
        a = split(path_list(k,:),"/");
        n_cell = a(size(a,1)-1);
        if str2num(n_cell{1}) == patient_num
            path_num = [path_num k];
        end
    end
end
if size(path_num,1) == 0
    msg = 'Error: no paths are found for these patients'
    error(msg)
else
    paths = path_list(path_num,:);
end

    