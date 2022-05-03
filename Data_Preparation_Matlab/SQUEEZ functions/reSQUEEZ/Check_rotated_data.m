% plot data + rotated by angles
j = 1;
seg = Data(info.timeframes(j)).seg;
I = zeros(size(seg));
I(seg > 0) = 1;       


CC = bwconncomp(I);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx]= max(numPixels);
I = zeros(size(I));
I(CC.PixelIdxList{idx})=1;
clear idx

[f,v] = isosurface(I,0);
M(j).faces = f; M(j).vertices = v;


th_z = Data(1).rotinfo.first_z;
th_x = Data(1).rotinfo.second_x;
th_y = Data(1).rotinfo.third_z;

R(:,:,1) = [cos(th_z) -sin(th_z) 0; sin(th_z) cos(th_z) 0; 0 0 1]; %Rotation about z %make positive
R(:,:,2) = [1 0 0; 0 cos(th_x) -sin(th_x); 0  sin(th_x) cos(th_x)];  %Rotation about x
R(:,:,3) = [cos(th_y) -sin(th_y) 0; sin(th_y) cos(th_y) 0; 0 0 1];  %Rotation about z (LV long axis)

center = nanmean(M(j).vertices)';
center = repmat(center,1,size(M(j).vertices,1));

% Rotating about Z axis
so = R(:,:,1)*(M(j).vertices' - center) + center;

% Rotating about X axis
so = R(:,:,2)*(so-center) + center;

% Rotating about Z axis
so = R(:,:,3)*(so-center) + center;
    
M(j).rotated_verts = so';


figure('pos',[10 10 2000 1000])
subplot(1,3,1)
patch('Faces',M(j).faces,'Vertices',M(j).rotated_verts,'FaceColor','r');
daspect([1 1 1]); view(0,0);camlight; lighting gouraud;
title('Anterior Wall','FontSize',30)
xlabel('x'); ylabel('y'); zlabel('z')

subplot(1,3,2)
patch('Faces',M(j).faces,'Vertices',M(j).rotated_verts,'FaceColor','r');
daspect([1 1 1]); view(90,0);camlight; lighting gouraud;
title('Lateral Wall','FontSize',30)
xlabel('x'); ylabel('y'); zlabel('z')

subplot(1,3,3)
patch('Faces',M(j).faces,'Vertices',M(j).rotated_verts,'FaceColor','r');
daspect([1 1 1]); view(90,-90);camlight; lighting gouraud;
xlabel('x'); ylabel('y'); zlabel('z')
title('Short axis: apex \rightarrow base','FontSize',30)




% plot rotated data directly
seg_rot = Data(info.timeframes(j)).seg_rot;
II = zeros(size(seg_rot));
II(seg_rot > 0) = 1;   
[ff,vv] = isosurface(II,0);
MM(j).faces = ff; MM(j).vertices = vv;

figure('pos',[10 10 2000 1000])
subplot(1,3,1)
patch('Faces',MM(j).faces,'Vertices',MM(j).vertices,'FaceColor','r');
daspect([1 1 1]); view(0,0);camlight; lighting gouraud;
title('Anterior Wall','FontSize',30)
xlabel('x'); ylabel('y'); zlabel('z')

subplot(1,3,2)
patch('Faces',MM(j).faces,'Vertices',MM(j).vertices,'FaceColor','r');
daspect([1 1 1]); view(90,0);camlight; lighting gouraud;
title('Lateral Wall','FontSize',30)
xlabel('x'); ylabel('y'); zlabel('z')

subplot(1,3,3)
patch('Faces',MM(j).faces,'Vertices',MM(j).vertices,'FaceColor','r');
daspect([1 1 1]); view(90,-90);camlight; lighting gouraud;
xlabel('x'); ylabel('y'); zlabel('z')
title('Short axis: apex \rightarrow base','FontSize',30)
