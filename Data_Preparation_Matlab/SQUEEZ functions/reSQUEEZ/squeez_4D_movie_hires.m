function [Mesh,info] = squeez_4D_movie(Mesh,info,lims)
name = info.patient;

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
    vert=Mesh.HiResCropVerts;
    min_v(:,i)=min(vert);
    max_v(:,i)=max(vert);
    
end

max_val=max(max_v,[],2);
min_val=min(min_v,[],2);
ax_vals=[min_val(1) max_val(1) min_val(2) max_val(2) min_val(3) max_val(3)];

buff_val=0.2;
info.ax_vals=[ax_vals(1)-buff_val*(ax_vals(2)-ax_vals(1)) ax_vals(2)+buff_val*(ax_vals(2)-ax_vals(1)) ax_vals(3)-buff_val*(ax_vals(4)-ax_vals(3)) ax_vals(4)+buff_val*(ax_vals(4)-ax_vals(3))  ax_vals(5)-buff_val*(ax_vals(6)-ax_vals(5)) ax_vals(6)+buff_val*(ax_vals(6)-ax_vals(5))];

n = [info.patient,'_AllViews_4DSqueezHiRes'];
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
        
        axis(lims)
        NaNidx = ~isnan(Mesh(i).rotated_verts(:,1));
        
        F = scatteredInterpolant(Mesh(i).rotated_verts(NaNidx,1)./max(Mesh(i).rotated_verts(NaNidx,1)),Mesh(i).rotated_verts(NaNidx,2)./max(Mesh(i).rotated_verts(NaNidx,2)),Mesh(i).rotated_verts(NaNidx,3)./max(Mesh(i).rotated_verts(NaNidx,3)),Mesh(i).RSct_vertex(NaNidx)');
        
        InterpVals = F(Mesh(i).HiResCropVerts(:,1)./max(Mesh(i).HiResCropVerts(:,1)),Mesh(i).HiResCropVerts(:,2)./max(Mesh(i).HiResCropVerts(:,2)),Mesh(i).HiResCropVerts(:,3)./max(Mesh(i).HiResCropVerts(:,3)));
        
        patch('Faces',Mesh(i).HiResFaces,'Vertices',Mesh(i).HiResCropVerts,'FaceVertexCData',InterpVals,'EdgeColor','none');
        
        view(VU_mat(j,:))
        
        colorbar
        alpha(0.9)
        camlight
        shading interp
        
        lighting flat
        colormap lce
        
        frame = num2str(i);
        tot = num2str(length(Mesh));
        v = string(VU_label(j));
        str1 = [frame,'/',tot];
        str2 = [name,v,str1];
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

mov_savename=[info.patient,'_','ApicalViewHiRes'];
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
    
    axis(lims)
    
    NaNidx = ~isnan(Mesh(i).rotated_verts(:,1));
    
    F = scatteredInterpolant(Mesh(i).rotated_verts(NaNidx,1)./max(Mesh(i).rotated_verts(NaNidx,1)),Mesh(i).rotated_verts(NaNidx,2)./max(Mesh(i).rotated_verts(NaNidx,2)),Mesh(i).rotated_verts(NaNidx,3)./max(Mesh(i).rotated_verts(NaNidx,3)),Mesh(i).RSct_vertex(NaNidx)');
    
    InterpVals = F(Mesh(i).HiResCropVerts(:,1)./max(Mesh(i).HiResCropVerts(:,1)),Mesh(i).HiResCropVerts(:,2)./max(Mesh(i).HiResCropVerts(:,2)),Mesh(i).HiResCropVerts(:,3)./max(Mesh(i).HiResCropVerts(:,3)));
    
    patch('Faces',Mesh(i).HiResFaces,'Vertices',Mesh(i).HiResCropVerts,'FaceVertexCData',InterpVals,'EdgeColor','none','FaceColor','flat');
    
    view(0,-90)
    
    colorbar
    alpha(0.9)
    camlight
    shading interp
    
    lighting gouraud
    colormap lce
    
    frame = num2str(i);
    tot = num2str(length(Mesh));
    str1 = [frame,'/',tot];
    str2 = [name,'     ',str1];
    title(str2, 'FontSize',14);
    
    
    drawnow;
    
    currFrame = getframe(gcf);
    writeVideo(vid_obj,currFrame);
    
end
close(vid_obj);
end

