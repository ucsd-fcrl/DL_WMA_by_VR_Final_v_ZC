function [WMA_patches_measures] = Measure_Region_of_WMA_Size_From_Labeled_Volshow(WMA_exist, seg_WMA_multi,patient_id,image_save_folder,view_angle,rows_of_Mitral_Valve,rows_of_Mitral_Valve_center,dilate_size,multi_class_in_WMA,config_label_MI,save_file_basename)

% this function measures regional of WMA sizes from the labeled Volshow for each view angle. 
% rows_of_MV, dilate_size are inputs for function Measure_WMA_Patches_Size_From_BinaryI_w_MV_removed.m

scale = [2,2,2];
position = config_label_MI.CameraPosition';


if WMA_exist == 1
    for i = 1:size(view_angle,2)
        angle = view_angle(:,i);

        Image_WMA = imread([image_save_folder,'/',patient_id,'_label_WMA_',num2str(angle),'.png']);
        [Image_WMA_bw,num_WMA] = Count_Non_White_Pixel(Image_WMA,0);
        Image_WMA_bw = ~Image_WMA_bw;

        Image_LV = imread([image_save_folder,'/',patient_id,'_label_LV_',num2str(angle),'.png']);
        [Image_LV_bw,num_LV] = Count_Non_White_Pixel(Image_LV,0);
        Image_LV_bw = ~Find_Biggest_Component(Image_LV_bw,0);
        close all
        
        if i == 4 || i == 5
            [Image_WMA_remove_dilate,Image_colored,WMA_patches_sizes] = Measure_WMA_Patches_Size_From_BinaryI_w_MV_removed(Image_WMA_bw,Image_LV_bw,rows_of_Mitral_Valve_center,dilate_size,0);
        else
            [Image_WMA_remove_dilate,Image_colored,WMA_patches_sizes] = Measure_WMA_Patches_Size_From_BinaryI_w_MV_removed(Image_WMA_bw,Image_LV_bw,rows_of_Mitral_Valve,dilate_size,0);
        end
        close all

        % save image + measures
        WMA_patches_measures(i).angle = angle;
        WMA_patches_measures(i).num_LV = num_LV;
        WMA_patches_measures(i).num_WMA_no_processed = num_WMA;
        WMA_patches_measures(i).percentage_WMA_no_processed = num_WMA / num_LV;
        WMA_patches_measures(i).WMA_patches_sizes = WMA_patches_sizes;
        WMA_patches_measures(i).num_WMA_processed = sum(WMA_patches_sizes);
        WMA_patches_measures(i).percentage_WMA_processed = sum(WMA_patches_sizes) / num_LV;
        
        h3 = figure();
        lim = size(Image_WMA_remove_dilate,2);
        subplot(1,3,1)
        imagesc(Image_WMA_bw);
        xlim([0 lim]);ylim([0,lim]);
        axis equal

        subplot(1,3,2)
        imagesc(Image_WMA_remove_dilate);
        xlim([0 lim]);ylim([0,lim]);
        axis equal

        subplot(1,3,3)
        imagesc(Image_colored);
        xlim([0 lim]);ylim([0,lim]);
        axis equal

        saveas(gcf,[image_save_folder,'/',patient_id,'_label_WMA_colored_',num2str(angle),'.png']);
        close all

        if multi_class_in_WMA == 1 % also want to calculate the percentage of each class
            [rot_in_xy,~] = Rotation_Matrix_From_Three_Axis(0,0,angle,1);
            new_position = rot_in_xy * position;
            config_label_MI.CameraPosition = new_position';
            
            % calculate the moderate
            if any(unique(seg_WMA_multi) == 9) == 1 % have moderate regions
                seg_WMA_moderate = seg_WMA_multi;
                seg_WMA_moderate(seg_WMA_moderate == 20) = 1;
                h = figure('pos',[10 10 200 200]);
                labelvolshow(double(seg_WMA_moderate),config_label_MI,'ScaleFactor',scale);
                saveas(gcf,[image_save_folder,'/',patient_id,'_label_moderate_',num2str(angle),'.png']);
                close all
                Image_moderate = imread([image_save_folder,'/',patient_id,'_label_moderate_',num2str(angle),'.png']);
                [Image_moderate_bw,num_moderate] = Count_Non_White_Pixel(Image_moderate,0);
                Image_moderate_bw = ~Image_moderate_bw;
                if i == 4 || i == 5
                    [~,~,moderate_patches_sizes] = Measure_WMA_Patches_Size_From_BinaryI_w_MV_removed(Image_moderate_bw,Image_LV_bw,rows_of_Mitral_Valve+10,dilate_size,0);
                else
                    [~,~,moderate_patches_sizes] = Measure_WMA_Patches_Size_From_BinaryI_w_MV_removed(Image_moderate_bw,Image_LV_bw,rows_of_Mitral_Valve,dilate_size,0);
                end

                WMA_patches_measures(i).num_moderate_no_processed = num_moderate;
                WMA_patches_measures(i).percentage_moderate_no_processed = num_moderate / num_LV;
                WMA_patches_measures(i).moderate_patches_sizes = moderate_patches_sizes;
                WMA_patches_measures(i).num_moderate_processed = sum(moderate_patches_sizes);
                WMA_patches_measures(i).percentage_moderate_processed = sum(moderate_patches_sizes) / num_LV;

                delete([image_save_folder,'/',patient_id,'_label_moderate_',num2str(angle),'.png'])
           else
                WMA_patches_measures(i).num_moderate_no_processed = 0;
                WMA_patches_measures(i).percentage_moderate_no_processed = 0;
                WMA_patches_measures(i).moderate_patches_sizes = 0;
                WMA_patches_measures(i).num_moderate_processed = 0;
                WMA_patches_measures(i).percentage_moderate_processed = 0;
        end

        % calculate for severe regions
        if any(unique(seg_WMA_multi) == 20) == 1 % have severe regions
                seg_WMA_severe = seg_WMA_multi;
                seg_WMA_severe(seg_WMA_severe == 9) = 1;
                h = figure('pos',[10 10 200 200]);
                labelvolshow(double(seg_WMA_severe),config_label_MI,'ScaleFactor',scale);
                saveas(gcf,[image_save_folder,'/',patient_id,'_label_severe_',num2str(angle),'.png']);
                close all
                Image_severe = imread([image_save_folder,'/',patient_id,'_label_severe_',num2str(angle),'.png']);
                [Image_severe_bw,num_severe] = Count_Non_White_Pixel(Image_severe,0);
                Image_severe_bw = ~Image_severe_bw;
                if i == 4 || i == 5
                    [~,~,severe_patches_sizes] = Measure_WMA_Patches_Size_From_BinaryI_w_MV_removed(Image_severe_bw,Image_LV_bw,rows_of_Mitral_Valve+10,dilate_size,0);
                else
                    [~,~,severe_patches_sizes] = Measure_WMA_Patches_Size_From_BinaryI_w_MV_removed(Image_severe_bw,Image_LV_bw,rows_of_Mitral_Valve,dilate_size,0);
                end

                WMA_patches_measures(i).num_severe_no_processed = num_severe;
                WMA_patches_measures(i).percentage_severe_no_processed = num_severe / num_LV;
                WMA_patches_measures(i).severe_patches_sizes = severe_patches_sizes;
                WMA_patches_measures(i).num_severe_processed = sum(severe_patches_sizes);
                WMA_patches_measures(i).percentage_severe_processed = sum(severe_patches_sizes) / num_LV;

                delete([image_save_folder,'/',patient_id,'_label_severe_',num2str(angle),'.png'])
           else
                WMA_patches_measures(i).num_severe_no_processed = 0;
                WMA_patches_measures(i).percentage_severe_no_processed = 0;
                WMA_patches_measures(i).severe_patches_sizes = 0;
                WMA_patches_measures(i).num_severe_processed = 0;
                WMA_patches_measures(i).percentage_severe_processed = 0;
        end                
    end
end
    
    [dirname,~,~] = fileparts(image_save_folder);
    save([dirname,'/',save_file_basename],'WMA_patches_measures');
   
    
else
    for i = 1:size(view_angle,2)
        angle = view_angle(:,i);
        Image_LV = imread([image_save_folder,'/',patient_id,'_label_LV_',num2str(angle),'.png']);
        [Image_LV_bw,num_LV] = Count_Non_White_Pixel(Image_LV,0);
        WMA_patches_measures(i).angle = angle;
        WMA_patches_measures(i).num_LV = num_LV;
        WMA_patches_measures(i).num_WMA_no_processed = 0;
        WMA_patches_measures(i).percentage_WMA_no_processed = 0;
        WMA_patches_measures(i).WMA_patches_sizes = 0;
        WMA_patches_measures(i).num_WMA_processed = 0;
        WMA_patches_measures(i).percentage_WMA_processed = 0;
        if multi_class_in_WMA == 1
            WMA_patches_measures(i).num_moderate_no_processed = 0;
            WMA_patches_measures(i).percentage_moderate_no_processed = 0;
            WMA_patches_measures(i).moderate_patches_sizes = 0;
            WMA_patches_measures(i).num_moderate_processed = 0;
            WMA_patches_measures(i).percentage_moderate_processed = 0;
            WMA_patches_measures(i).num_severe_no_processed = 0;
            WMA_patches_measures(i).percentage_severe_no_processed = 0;
            WMA_patches_measures(i).severe_patches_sizes = 0;
            WMA_patches_measures(i).num_severe_processed = 0;
            WMA_patches_measures(i).percentage_severe_processed = 0;
        end
    
    end
    [dirname,~,~] = fileparts(image_save_folder);
    save([dirname,'/',save_file_basename],'WMA_patches_measures');
end
        
    
    
    

