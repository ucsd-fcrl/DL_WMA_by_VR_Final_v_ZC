%% Calculate Error

time_vector = info.timeframes; time_vector(info.timeframes == info.template) = [];
faces = Mesh(info.template).faces;

for j = time_vector
    
    % Calculating errors between corresponding points in registered and target meshes
    temp = sqrt((Mesh(j).CPD(Mesh(info.template).indxs,1) - Mesh(j).vertices(Mesh(j).Correspondence(Mesh(info.template).indxs),1)).^2 +...
        (Mesh(j).CPD(Mesh(info.template).indxs,2) - Mesh(j).vertices(Mesh(j).Correspondence(Mesh(info.template).indxs),2)).^2 +...
        (Mesh(j).CPD(Mesh(info.template).indxs,3) - Mesh(j).vertices(Mesh(j).Correspondence(Mesh(info.template).indxs),3)).^2);
    
    % Initializing error vector to be of same size as original template mesh with points on mitral valve plane and LVOT
    err = zeros(size(Mesh(info.template).vertices,1),1);
    err(~Mesh(info.template).indxs) = NaN; err(Mesh(info.template).indxs) = temp;
    
    % Finding connectivity of points
    [conn,~,~] = meshconn(faces,length(err));
    
    %Averaging error of each point with its neighboring points to de-noise
    for i = 1:length(err)

        ring = unique([conn{i} cell2mat(conn(conn{i})')]);
        err_smooth(i) = nanmean(err(ring));

    end
    
    % NaN-ing points on mitral valve plane and lvot
    err_smooth(~Mesh(info.template).indxs) = NaN;
    Mesh(j).Corr_Err = err_smooth;
    
    clear temp
end

Mesh(info.template).Corr_Err = zeros(length(err),1)';

clearvars -except Mesh info

%% Plot global error
close all;

for j = info.timeframes
    
    Gl_Err(j) = nanmean(Mesh(j).Corr_Err*info.desired_res);
    Gl_Err_std(j) = nanstd(Mesh(j).Corr_Err*info.desired_res);

end

figV = figure(1); errorbar(info.percent_rr,Gl_Err(info.timeframes),Gl_Err_std(info.timeframes),'LineWidth',3)
grid on; grid minor
title('Global Registration Error')
set(gca,'FontSize',50)
axis([0 100 -0.1 10])
xlabel('R-R interval (%)'); ylabel('Mean Error (mm)')

figV.Units='normalized';
figV.Position=[0 0 0.7 1]; 
figV.PaperPositionMode='auto';

savefig([info.save_path,info.patient,'_GlobalError.fig'])