function Make_Labeled_Volshow_For_WMA(view_angle,seg_rot,seg_WMA,seg_WMA_multi,config_label_LV,config_label_MI,config_label_overlaid_multi_class_for_WMA,config_label_overlaid_severe_WMA,config_label_overlaid_moderate_WMA,image_save_folder,patient_class,patient_id)


scale = [2,2,2];
position = config_label_LV.CameraPosition';

for i = 1:size(view_angle,2)
    angle = view_angle(:,i);
    [rot_in_xy,~] = Rotation_Matrix_From_Three_Axis(0,0,angle,1);
    new_position = rot_in_xy * position;
    config_label_LV.CameraPosition = new_position';
    config_label_MI.CameraPosition = new_position';
    config_label_overlaid_multi_class_for_WMA.CameraPosition = new_position';
    config_label_overlaid_moderate_WMA.CameraPosition = new_position';
    config_label_overlaid_severe_WMA.CameraPosition = new_position';
    
    h = figure('pos',[10 10 200 200]);
    if size(unique(seg_WMA),1) == 3
        labelvolshow(seg_WMA,config_label_MI,'ScaleFactor',scale);
        saveas(gcf,[image_save_folder,'/',patient_id,'_label_WMA_',num2str(angle),'.png']);
        close all
    elseif size(unique(seg_WMA),1) == 2
        disp('no WMA');
    else
        error('wrong number of class in seg_WMA');
    end
        

    h2 = figure('pos',[10 10 200 200]);
    s = seg_rot == 1;
    labelvolshow(double(s),config_label_LV,'ScaleFactor',scale);
    saveas(gcf,[image_save_folder,'/',patient_id,'_label_LV_',num2str(angle),'.png']);
    close all
    
    h4 = figure('pos',[10 10 200 200]);
    s = seg_rot > 0;
    labelvolshow(double(s),config_label_LV,'ScaleFactor',scale);
    saveas(gcf,[image_save_folder,'/',patient_id,'_label_All_Chambers_',num2str(angle),'.png']);
    close all
    
    h3 = figure('pos',[10 10 200 200]);
    if size(unique(seg_WMA),1) == 3
        if size(unique(seg_WMA_multi),1) == 4
            labelvolshow(seg_WMA_multi,config_label_overlaid_multi_class_for_WMA,'ScaleFactor',scale);
        elseif size(unique(seg_WMA_multi),1) == 3
            list = sort(unique(seg_WMA_multi));
            if list(3) == 9
                labelvolshow(seg_WMA_multi,config_label_overlaid_moderate_WMA,'ScaleFactor',scale);
            elseif list(3) == 20
                labelvolshow(seg_WMA_multi,config_label_overlaid_severe_WMA,'ScaleFactor',scale);
            end
        end
                
        saveas(gcf,[image_save_folder,'/',patient_id,'_label_Overlaid_',num2str(angle),'.png']);
        close all
    elseif size(unique(seg_WMA),1) == 2
        disp('no WMA');
    else
        error('wrong number of class in seg_WMA');
    end
   
  
end
    
    
    

