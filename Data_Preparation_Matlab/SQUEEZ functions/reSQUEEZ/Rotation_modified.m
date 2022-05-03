function [Mesh, info] = Rotation_modified(Mesh,info,Data)

R(:,:,1) = [cos(info.th_z) -sin(info.th_z) 0; sin(info.th_z) cos(info.th_z) 0; 0 0 1]; %Rotation about z %make positive
R(:,:,2) = [1 0 0; 0 cos(info.th_x) -sin(info.th_x); 0  sin(info.th_x) cos(info.th_x)];  %Rotation about x
R(:,:,3) = [cos(info.th_y) -sin(info.th_y) 0; sin(info.th_y) cos(info.th_y) 0; 0 0 1];  %Rotation about z (LV long axis)

info.rot_xlim = [1500 -1500]; info.rot_ylim = [1500 -1500]; info.rot_zlim = [1500 -1500]; % For non-rotated LV

% Calculating center of rotation - centroid
center = nanmean(Mesh(info.template).CPD)';
center = repmat(center,1,size(Mesh(info.template).vertices,1));

for j = info.timeframes
    
    % Rotating about Z axis
    so = R(:,:,1)*(Mesh(j).CPD' - center) + center;

    % Rotating about X axis
    so = R(:,:,2)*(so-center) + center;

    % Rotating about Z axis
    so = R(:,:,3)*(so-center) + center;
    
    Mesh(j).rotated_verts = so';
    
    if info.already_rotated == 1
        for ii = 1:size(Mesh(j).CPD,1)
            if all(isnan(Mesh(j).CPD(ii,:))) ~= 1
                equal = round(Mesh(j).CPD(ii,:),2) == round(Mesh(j).rotated_verts(ii,:),2);
                if all(equal)~= 1
                    error('0 degree Rotation changes the data')
                end
            end
        end
    end
    clear so
    
    %Identifying bottom point of LVOT plane for generating AHA segments
    if j == info.template && nnz(Mesh(j).lvot) ~= 0
        
        %Rotating non-NaNed out mesh
        so = R(:,:,1)*(Mesh(j).vertices' - center) + center;
        so = R(:,:,2)*(so-center) + center;
        so = R(:,:,3)*(so-center) + center; so = so';
        
        %Extracting vertices belonging to LVOT plane
        temp = so(Mesh(j).lvot,:);   
        
        %Finding point on template mesh with lowest z value
        [~,lvot] = ismember(temp(temp(:,3) == min(temp(:,3)),:),so,'rows');
       
        %Finding the neighbors of this point
        [conn,~,~] = meshconn(Mesh(j).faces,length(so));
        neighbors = conn{lvot};
        
        %Identifying the neighbor with the lowest z-value
        [~,bottom_neighbor] = min(so(neighbors,3));
        info.lvot_bottom = neighbors(bottom_neighbor);
        
        clear temp so conn lvot neighbors bottom_neighbor
    
    elseif j == info.template && nnz(Mesh(j).lvot) == 0
        info.lvot_bottom = [];
    end    
    
    % Identifying axes limits for mesh plotting
    if max(Mesh(j).rotated_verts(:,1)) > info.rot_xlim(2)
        info.rot_xlim(2) = max(Mesh(j).rotated_verts(:,1)) + 5*(2/info.desired_res);
    end
    
    if max(Mesh(j).rotated_verts(:,2)) > info.rot_ylim(2)
        info.rot_ylim(2) = max(Mesh(j).rotated_verts(:,2)) + 5*(2/info.desired_res);
    end
        
    if max(Mesh(j).rotated_verts(:,3)) > info.rot_zlim(2)
        info.rot_zlim(2) = max(Mesh(j).rotated_verts(:,3)) + 5*(2/info.desired_res);
    end
    
    if min(Mesh(j).rotated_verts(:,1)) < info.rot_xlim(1)
        info.rot_xlim(1) = min(Mesh(j).rotated_verts(:,1)) - 5*(2/info.desired_res);
    end
    
    if min(Mesh(j).rotated_verts(:,2)) < info.rot_ylim(1)
        info.rot_ylim(1) = min(Mesh(j).rotated_verts(:,2)) - 5*(2/info.desired_res);
    end
        
    if min(Mesh(j).rotated_verts(:,3)) < info.rot_zlim(1)
        info.rot_zlim(1) = min(Mesh(j).rotated_verts(:,3)) - 5*(2/info.desired_res);
    end
    
end    

% plot (w/ LA and LVOT)
seg_rot = Data(info.template).seg_rot;
II = zeros(size(seg_rot));
II(seg_rot > 0) = 1;   
[ff,vv] = isosurface(II,0);
MM(info.template).faces = ff; MM(info.template).vertices = vv;

% Calculating center of rotation - centroid
center = nanmean(MM(info.template).vertices)';
center = repmat(center,1,size(MM(info.template).vertices,1));

% Rotating about Z axis
soo = R(:,:,1)*(MM(info.template).vertices' - center) + center;

% Rotating about X axis
soo = R(:,:,2)*(soo-center) + center;
% Rotating about Z axis
soo = R(:,:,3)*(soo-center) + center;
    
MM(info.template).rotated_verts = soo';
    
    
figure('pos',[10 10 2000 1000])
subplot(1,3,1)
patch('Faces',MM(info.template).faces,'Vertices',MM(info.template).vertices,'FaceColor','r');
daspect([1 1 1]); view(0,0);camlight; lighting gouraud;
title('Anterior Wall','FontSize',30)
xlabel('x'); ylabel('y'); zlabel('z')

subplot(1,3,2)
patch('Faces',MM(info.template).faces,'Vertices',MM(info.template).vertices,'FaceColor','r');
daspect([1 1 1]); view(90,0);camlight; lighting gouraud;
title('Lateral Wall','FontSize',30)
xlabel('x'); ylabel('y'); zlabel('z')

subplot(1,3,3)
patch('Faces',MM(info.template).faces,'Vertices',MM(info.template).vertices,'FaceColor','r');
daspect([1 1 1]); view(90,-90);camlight; lighting gouraud;
xlabel('x'); ylabel('y'); zlabel('z')
title('Short axis: apex \rightarrow base','FontSize',30)

