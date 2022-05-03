function [Mesh,info] = AHA_Test_modified(Mesh,info,percentage,save_image)
% lower LVOT plane
fig1 = figure('pos',[10 10 2400 1800]);
fig2 = figure('pos',[10 10 2400 1800]);

seg = [4 5 6 1 2 3 10 11 12 7 8 9 15 16 13 14]; % Order of AHA segments from 0 degrees

name = {'Basal Anterior','Basal Anteroseptal','Basal Inferoseptal','Basal Inferior','Basal Inferolateral','Basal Anterolateral',...
    'Mid Anterior','Mid Anteroseptal','Mid Inferoseptal','Mid Inferior','Mid Inferolateral','Mid Anterolateral',...
    'Apical Anterior','Apical Septal','Apical Inferior','Apical Lateral'};

count = 1; % Counter for segments

data = Mesh(info.reference).Polar_Data;

%Defining basal, mid, and apical chunk lengths
down = round((numel(data) - info.lvot_limit(info.reference) + 1) * percentage);
if down == 0
    info.down(info.reference) = 1;
else
    info.down(info.reference) = down;
end 

info.lvot_limit_down(info.reference) = info.lvot_limit(info.reference) + info.down(info.reference);
disp([info.lvot_limit(info.reference) , info.down(info.reference)]);

chunks = round((numel(data) - info.lvot_limit(info.reference) + 1)/3);

%Defining basal, mid, and apical slices
list = {info.lvot_limit(info.reference):info.lvot_limit(info.reference) + chunks-1,
    info.lvot_limit(info.reference) + chunks:info.lvot_limit(info.reference) + 2*chunks - 1,
    info.lvot_limit(info.reference) + 2*chunks:numel(data)};

% Basal-1, mid-2, apex-3
for j1 = 1:3

    angles = []; indices = [];

    % Extracting all angles in the respective section slices and their corresponding strains
    for j2 = list{j1}

        angles = [angles, data{j2}(2,:)];
        indices = [indices, data{j2}(3,:)];

    end

    if j1 == 1 || j1 ==2

        % rotating aha 16 segment plot by 30 for easy extraction of values, making segments 4 and 10 start at 6 o'clock instead of 7 o'clock
        angles = angles + pi/6;
        angles(angles>=2*pi) = angles(angles>=2*pi) - 2*pi;

        c = 1; dummy = 0;
        while dummy < 2*pi
            % Finding indices of points in the reference mesh corresponding to the particular AHA segment
            aha{seg(count)} = indices(angles >= dummy & angles < c*(pi/3));
            dummy = c*(pi/3);
            c = c + 1;
            count = count + 1;
        end

    else

        % rotating aha 16 segment plot by 45 for easy extraction of values, making segment 15 start at 6 o'clock instead of 7:30 o'clock
        angles = angles + pi/4;
        angles(angles>=2*pi) = angles(angles>=2*pi) - 2*pi;

        c = 1; dummy = 0;
        while dummy < 2*pi
            % Finding indices of points in the reference mesh corresponding to the particular AHA segment
            aha{seg(count)} = indices(angles >= dummy & angles < c*(pi/2));
            dummy = c*(pi/2);
            c = c + 1;
            count = count + 1;
        end

    end

end
    
for j = info.timeframes
    
    % Finding the mean rsct of all points on the registered meshes within the defined AHA segments
    for j1 = 1:16
        rsct(j1) = nanmean(Mesh(j).RSct_vertex(aha{j1}(~isnan(aha{j1}))));
    end    
    
    Mesh(j).AHA = rsct;
    
    clear chunks list rsct
end

clear aha

%figure('pos',[10 10 2400 1800])
% Plotting loop
for j3 = 1:16
    
    for j = 1:length(info.timeframes)
        
        aha(j) = Mesh(info.timeframes(j)).AHA(j3);
        
    end
    
    figure(fig1)
    subplot(3,6,j3)
    plot(info.percent_rr,aha,'LineWidth',3);
    ax = gca; ax.FontSize = 10; ax.FontWeight= 'bold';
    ylim([info.RSct_limits]); xlim([0 100])
    %xlim([info.percent_rr(1) info.percent_rr(end)])
    yticks([-1:0.1:1]); xticks(0:20:100)
    ylabel('RS_{CT}','FontSize',12); xlabel('%R-R Phase','FontSize',12)
    title([num2str(j3),': ',name{j3}],'FontSize',15)
    grid on; grid minor  
    
    
    figure(fig2)
    subplot(3,6,j3);
    plot(info.time_ms,aha,'LineWidth',3);
    ax = gca; ax.FontSize = 10; ax.FontWeight= 'bold';
    ylim([info.RSct_limits]); xlim([0 1200])
    yticks([-1:0.1:1]); xticks(0:500:1500)
    ylabel('RS_{CT}','FontSize',12); xlabel('Time (ms)','FontSize',12)
    title([num2str(j3),'. ',name{j3}],'FontSize',15)
    grid on; grid minor
end

if save_image == 1
    s_path = info.save_image_path;
    saveas(fig1,[s_path,info.patient,'_AHA.fig'])
    saveas(fig1,[s_path,info.patient,'_AHA'],'jpg')
    saveas(fig2,[s_path,info.patient,'_AHA_ms.fig'])
    saveas(fig2,[s_path,info.patient,'_AHA_ms'],'jpg')
end