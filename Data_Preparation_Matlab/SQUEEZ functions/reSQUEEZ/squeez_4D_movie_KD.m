function [Mesh,info] = squeez_4D_movie_KD(Mesh,info)
name = [info.patient];

mov_VU=[0 0];

fig=figure(5);
fig.Units='Normalized';
fig.Position=[0.01 0.01 0.4 0.8];

deg = 0:-30:-330;
for i = 1:length(deg)
    VU_mat(i,:)=[mov_VU(1)+deg(i) mov_VU(2)];
end

VU_label = ["Anterior", "AnteroSeptal 1", "AnteroSeptal 2", "Septum", "InferoSeptal 1", "InferoSeptal 2", "Inferior", "InferoLateral 1", "InferoLateral 2", "Lateral", "AnteroLateral 1", "AnteroLateral 2"];

for i = info.timeframes
    vert=Mesh(i).rotated_verts;
    min_v(:,i)=min(vert);
    max_v(:,i)=max(vert);
    
end

max_val=max(max_v,[],2);
min_val=min(min_v,[],2);
ax_vals=[min_val(1) max_val(1) min_val(2) max_val(2) min_val(3) max_val(3)];

buff_val=0.2;
info.ax_vals=[ax_vals(1)-buff_val*(ax_vals(2)-ax_vals(1)) ax_vals(2)+buff_val*(ax_vals(2)-ax_vals(1)) ax_vals(3)-buff_val*(ax_vals(4)-ax_vals(3)) ax_vals(4)+buff_val*(ax_vals(4)-ax_vals(3))  ax_vals(5)-buff_val*(ax_vals(6)-ax_vals(5)) ax_vals(6)+buff_val*(ax_vals(6)-ax_vals(5))];

n = [info.patient,'_AllViews_4DSqueez'];
mov_all_savename = fullfile([info.save_path,n]);

vid_obj2 = VideoWriter(mov_all_savename,'MPEG-4');
vid_obj2.FrameRate = length(Mesh);
open(vid_obj2);


for j=1:size(VU_mat,1)
    
    clear vid_obj;
    
    mov_savename=sprintf('%d_Mov',j);
    
    % Lets append name with the parallel or sequential name;
    mov_savename=[info.patient,'_',mov_savename];
    mov_savename = fullfile(info.save_path,mov_savename);
    
    vid_obj = VideoWriter(mov_savename,'MPEG-4');
    vid_obj.FrameRate = length(Mesh);
    open(vid_obj);
    
    for i = info.timeframes
        
        figure(5);
        clf;
        axis vis3d
        set(gca,'CLim', info.RSct_limits)
        
        axis off
        daspect([1 1 1])
        
        
        
        patch('Faces',Mesh(info.template).faces,'Vertices',Mesh(i).rotated_verts,'FaceVertexCData',Mesh(i).RSct_vertex','EdgeColor','none');
%       plot3(Mesh(i).rotated_verts(:,1),Mesh(i).rotated_verts(:,2),Mesh(i).rotated_verts(:,3),'k.'); axis equal
        view(VU_mat(j,:))
        axis(info.ax_vals)
        h = colorbar;
        set(get(h,'Title'),'string','RS_{CT}')
        alpha(1)
        shading interp
        camlight
        lighting none
        colormap lce
        
        frame = num2str(i);
        tot = num2str(length(Mesh));
        v = string(VU_label(j));
        str1 = [frame,'/',tot];
        str2 = [v,str1];
        title(str2, 'FontSize',14);
        
        
        drawnow;
        
        currFrame = getframe(gcf);
        writeVideo(vid_obj,currFrame);
        
        writeVideo(vid_obj2,currFrame);
        
    end
    
    
end
close(vid_obj);
close(vid_obj2);

close all;
clear vid_obj;

mov_savename=[info.patient,'_','ApicalView'];
mov_savename = fullfile(info.save_path,mov_savename);

vid_obj = VideoWriter(mov_savename,'MPEG-4');
vid_obj.FrameRate = length(Mesh);
open(vid_obj);

for i = info.timeframes
    
    figure(143);
    clf;
    axis vis3d
    set(gca,'CLim', info.RSct_limits)
    
    axis off
    daspect([1 1 1])
    
    axis(info.ax_vals)
    
    patch('Faces',Mesh(info.template).faces,'Vertices',Mesh(i).rotated_verts,'FaceVertexCData',Mesh(i).RSct_vertex','EdgeColor','none');
%     plot3(Mesh(i).rotated_verts(:,1),Mesh(i).rotated_verts(:,2),Mesh(i).rotated_verts(:,3),'k.')
    view(0,-90)
    axis(info.ax_vals)
    h = colorbar;
    set(get(h,'Title'),'string','RS_{CT}')
    alpha(0.9)
    camlight
    shading interp
    
    lighting none
    colormap lce
    
    frame = num2str(i);
    tot = num2str(length(Mesh));
    str1 = [frame,'/',tot];
    str2 = ['     ',str1];
    title(str2, 'FontSize',14);
    
    
    drawnow;
    
    currFrame = getframe(gcf);
    writeVideo(vid_obj,currFrame);
    
end
close(vid_obj);
end

