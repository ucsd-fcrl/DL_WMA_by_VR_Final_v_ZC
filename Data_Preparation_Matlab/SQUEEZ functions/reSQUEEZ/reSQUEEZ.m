function Mesh = reSQUEEZ(Mesh,info)

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
    err_smooth = err_smooth'; err_smooth(~Mesh(info.template).indxs) = NaN;
    Mesh(j).Corr_Err = err_smooth;
    
    % Applying error threshold
    dummy = err_smooth>info.error_tol;

    % Identifying points that have error larger than threshold value and pulling their immediate neighbors along for continuity
    conn = conn(dummy);
    list = [conn{:} find(dummy)']; 
    list = unique(list);

    ind = ismember(1:length(err),list); ind = ind';
    ind(~Mesh(info.template).indxs) = 0;
    
    ind1 = sum([ind(faces(:,1)) ind(faces(:,2)) ind(faces(:,3))],2) == 3;
    patch_faces = faces(ind1,:);

    %Isolate disconnected meshes
    facecell = finddisconnsurf(patch_faces);
    clear patch_faces temp dummy
    
    for j1 = 1:length(facecell)
        
        temp = facecell{j1};
        
        ab = Mesh(info.template).crop_verts(temp(:,2),:) - Mesh(info.template).crop_verts(temp(:,1),:);
        ac = Mesh(info.template).crop_verts(temp(:,3),:) - Mesh(info.template).crop_verts(temp(:,1),:);
        c = cross(ab,ac,2);
        
        Ar = sum(0.5*sqrt(sum(c.^2,2)))*info.desired_res^2;
        clear ab ac c
        
        if Ar > info.area_tol
            
            temp = unique(temp);
            ind2 = ismember(1:length(Mesh(info.template).vertices),temp);
            ind2 = ind2';
            
            opts.corresp = 0;
            opts.normalize = 1;
            opts.max_it = 1500;
            opts.tol = 1e-5;
            opts.viz = 0;
            opts.method = 'nonrigid_lowrank';
            opts.fgt = 0;
            opts.eigfgt = 0;
            opts.outliers = 0.01;
            opts.beta = info.resqueez_beta;
            opts.lambda = info.resqueez_lambda;

            uni_corr = unique(Mesh(j).Correspondence(ind2));

            [T, ~] = cpd_register(Mesh(j).vertices(uni_corr,:),Mesh(info.template).vertices(ind2,:),opts);
            
            Mesh(j).CPD(ind2,:) = T.Y;
            
        end
        clear temp
    end
    
    disp(['Done with time frame ',num2str(j)])
end    