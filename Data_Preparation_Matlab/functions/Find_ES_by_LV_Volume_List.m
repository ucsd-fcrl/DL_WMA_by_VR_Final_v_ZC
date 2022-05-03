function [ES lv_volume_list] = Find_ES_by_LV_Volume_List(seg_path,timeframes)

lv_volume_list = [];
for i = 1:size(timeframes,2)
    seg_file_name = [seg_path,num2str(timeframes(i)-1),'.nii.gz'];
    seg_data = load_nii(seg_file_name);
    lv_volume_list = [lv_volume_list size(find(seg_data.img == 1),1)];
end
ES = find(lv_volume_list == min(lv_volume_list));