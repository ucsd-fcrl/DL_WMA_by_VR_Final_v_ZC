function [Mesh, info] = HiRes(Mesh,info)

cd(info.seg_path)

% Rotation matrix
R(:,:,1) = [cos(info.th_z) -sin(info.th_z) 0; sin(info.th_z) cos(info.th_z) 0; 0 0 1]; %Rotation about z %make positive
R(:,:,2) = [1 0 0; 0 cos(info.th_x) -sin(info.th_x); 0  sin(info.th_x) cos(info.th_x)];  %Rotation about x
R(:,:,3) = [cos(info.th_y) -sin(info.th_y) 0; sin(info.th_y) cos(info.th_y) 0; 0 0 1];  %Rotation about z (LV long axis)

info.high_xlim = [1500 -1500]; info.high_ylim = [1500 -1500]; info.high_zlim = [1500 -1500]; % For non-rotated LV

for j = 1:length(info.timeframes) % Time frame loop

    %Reading data
    data = load_nii(['seg_',num2str(info.timeframes(j)-1,'%02d'),'.nii.gz']);
    res = data.hdr.dime.pixdim(2:4);

    % xxxxxxxxxxxx IMAGE PREPARATION xxxxxxxxxxxx
    I = zeros(size(data.img));
    I(data.img == info.lv_label) = 1;       % Extracting LV
    I(data.img == info.la_label) = 2;       % Extracting LA
    I(data.img == info.lvot_label) = 4;     % Extracting LVOT

    % Direction matrix Transformation from .nii to .mat
    I = permute(I,[2 1 3]);
    I = flip(I,1);
    I = flip(I,2);
    
    % Interpolating to make it isotropic resolution
    x = (1:size(I,2)).*res(2);
    y = (1:size(I,1)).*res(1);
    z = (1:size(I,3)).*res(3);

    xq = linspace(1*res(2),size(I,2)*res(2),round(length(x)*(res(2)/info.iso_res)));
    yq = linspace(1*res(1),size(I,1)*res(1),round(length(y)*(res(1)/info.iso_res)));
    zq = linspace(1*res(3),size(I,3)*res(3),round(length(z)*(res(3)/info.iso_res)));

    I = interp3(x,y,z,I,xq,yq',zq,'nearest');
    
    clear x y z xq yq zq
    
    %Initializing individual images
    im_lv = zeros(size(I)); im_lv(I==1) = 1;
    im_la = zeros(size(I)); im_la(I==2) = 1;
    im_lvot = zeros(size(I)); im_lvot(I==4) = 1;

    %Dilating images to identify planes
    im_lv_dilate = imdilate(im_lv,ones(4,4,4));
    im_la_dilate = imdilate(im_la,ones(4,4,4));
    im_lvot_dilate = imdilate(im_lvot,ones(4,4,4));
    
    %Identifying coordinates of planes
    [ym,xm,zm] = ind2sub(size(im_lv),find((im_lv_dilate + im_la) == 2));            % mitral valve plane
    [yl,xl,zl] = ind2sub(size(im_lv),find((im_lv_dilate + im_lvot) == 2));          % lvot plane
    [yb,xb,zb] = ind2sub(size(im_lv),find((im_la_dilate + im_lvot_dilate) == 2));   % band of tissue between mitral valve and lvot
    
    %Extracting mesh of LV
    [f,v] = isosurface(im_lv,0);
    Mesh(info.timeframes(j)).HiResFaces = f; Mesh(info.timeframes(j)).HiResVertices = v;
    
    %Identifying vertices that belong to planes identified previously
    [mi,~] = ismember(Mesh(info.timeframes(j)).HiResVertices,[xm ym zm],'rows');
    [li,~] = ismember(Mesh(info.timeframes(j)).HiResVertices,[xl yl zl],'rows');
    [bi,~] = ismember(Mesh(info.timeframes(j)).HiResVertices,[xb yb zb],'rows');
    
    %Logical list of vertices that do not belong to planes
    ind = ~logical(mi + li + bi);
    
    %Extracting faces belonging to all the vertices
    dummy = sum([ind(Mesh(info.timeframes(j)).HiResFaces(:,1)) ind(Mesh(info.timeframes(j)).HiResFaces(:,2)) ind(Mesh(info.timeframes(j)).HiResFaces(:,3))],2) == 3;
    face_objs = [Mesh(info.timeframes(j)).HiResFaces(dummy,1) Mesh(info.timeframes(j)).HiResFaces(dummy,2) Mesh(info.timeframes(j)).HiResFaces(dummy,3)];

    %Isolate disconnected meshes
    facecell = finddisconnsurf(face_objs);

    %Choosing the object with largest number of faces
    num = cellfun(@numel,facecell);
    [~,idx] = max(num);
    temp = facecell{idx};

    %Extracting the vertices corresponding to those faces
    temp = temp(:);
    temp = unique(temp);
    
    % NaN-ing out vertices all vertices on plane or disconnected ones
    Mesh(info.timeframes(j)).HiResCropVerts = NaN.*ones(size(Mesh(info.timeframes(j)).HiResVertices));
    Mesh(info.timeframes(j)).HiResCropVerts(temp,:) = Mesh(info.timeframes(j)).HiResVertices(temp,:);
    
    % Rotating the vertices to long axis coordinates
    
    % Calculating center of rotation - centroid
    center = nanmean(Mesh(info.timeframes(j)).HiResCropVerts)';
    center = repmat(center,1,size(Mesh(info.timeframes(j)).HiResCropVerts,1));
    
    % Rotating about Z axis
    so = R(:,:,1)*(Mesh(info.timeframes(j)).HiResCropVerts' - center) + center;

    % Rotating about X axis
    so = R(:,:,2)*(so-center) + center;

    % Rotating about Z axis
    so = R(:,:,3)*(so-center) + center;
    
    Mesh(info.timeframes(j)).HiResCropVerts = so';
    
    % Identifying axes limits for mesh plotting
    if max(Mesh(info.timeframes(j)).HiResCropVerts(:,1)) > info.high_xlim(2)
        info.high_xlim(2) = max(Mesh(info.timeframes(j)).HiResCropVerts(:,1)) + 5*(2/info.desired_res);
    end
    
    if max(Mesh(info.timeframes(j)).HiResCropVerts(:,2)) > info.high_ylim(2)
        info.high_ylim(2) = max(Mesh(info.timeframes(j)).HiResCropVerts(:,2)) + 5*(2/info.desired_res);
    end
        
    if max(Mesh(info.timeframes(j)).HiResCropVerts(:,3)) > info.high_zlim(2)
        info.high_zlim(2) = max(Mesh(info.timeframes(j)).HiResCropVerts(:,3)) + 5*(2/info.desired_res);
    end
    
    if min(Mesh(info.timeframes(j)).HiResCropVerts(:,1)) < info.high_xlim(1)
        info.high_xlim(1) = min(Mesh(info.timeframes(j)).HiResCropVerts(:,1)) - 5*(2/info.desired_res);
    end
    
    if min(Mesh(info.timeframes(j)).HiResCropVerts(:,2)) < info.high_ylim(1)
        info.high_ylim(1) = min(Mesh(info.timeframes(j)).HiResCropVerts(:,2)) - 5*(2/info.desired_res);
    end
        
    if min(Mesh(info.timeframes(j)).HiResCropVerts(:,3)) < info.high_zlim(1)
        info.high_zlim(1) = min(Mesh(info.timeframes(j)).HiResCropVerts(:,3)) - 5*(2/info.desired_res);
    end
    
    clearvars -except info Mesh j R
    disp(['Done with time frame ',num2str(info.timeframes(j))])
    
end

cd([info.home_path])