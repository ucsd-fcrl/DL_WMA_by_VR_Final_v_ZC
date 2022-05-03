function [Mesh, info] = Data_Sampling(Mesh,info)

for j = info.timeframes
    
    % Identifying long axis limits
    z_lim(1) = max(Mesh(j).rotated_verts(:,3)); z_lim(2) = min(Mesh(j).rotated_verts(:,3));
    
    % Defining apical and basal slices
    z_lim(1) = z_lim(1) - info.apical_basal_threshold(2)*(z_lim(1) - z_lim(2));
    z_lim(2) = z_lim(2) + info.apical_basal_threshold(1)*(z_lim(1) - z_lim(2));
    
    c = 1; dummy = z_lim(1);
    info.lvot_limit(j) = 0; b = true;
    while (dummy - z_lim(2)) > info.rawdata_slicethickness
        
        %Extracting all points within slice defined by slice thickness ordered from base to apex
        slice{c} = Mesh(j).rotated_verts(Mesh(j).rotated_verts(:,3) <= (z_lim(1) - (c-1)*info.rawdata_slicethickness) &...
            Mesh(j).rotated_verts(:,3) > (z_lim(1) - c*info.rawdata_slicethickness),:);
        
        dummy = z_lim(1) - c*info.rawdata_slicethickness;
        c = c + 1;
        
        % Calculating the point at which the lvot plane ends for AHA segments
        if isempty(info.lvot_bottom)
            info.lvot_limit(j) = 1;
        else
            if dummy < Mesh(j).rotated_verts(info.lvot_bottom,3) && b
                info.lvot_limit(j) = c;
                b = false;
            end
        end    
    end
    clear c dummy
    
    %Calculating radii and angles for each point in every slice
    for k = 1:numel(slice) %Slice loop
        
        % For slices that contain the lvot, choosing centroid of the slice with a complete circumference to avoid biasing 
        if k < info.lvot_limit(j)
            centroid = mean(slice{info.lvot_limit(j)}); centroid = centroid(1:2);
        else % For slices that do not contain the lvot
            centroid = mean(slice{k}); centroid = centroid(1:2);
        end
        
        %radius of all points in slice
        rad = sqrt((slice{k}(:,1) - centroid(1)).^2 + (slice{k}(:,2) - centroid(2)).^2);
        
        %angles of each point
        thetas = atan2(slice{k}(:,1) - centroid(1),slice{k}(:,2) - centroid(2));
        thetas(thetas<0) = 2*pi + thetas(thetas<0);
        
        % Calculating angle bin-width
        bin_width = sqrt(2)/median(rad);
        
        c = 1; dummy = 0;
        while 2*pi - dummy > bin_width %Azimuthal loop
            
            % To detect the outermost point within the bin_width
            list = thetas >= (c-1)*bin_width & thetas < c*bin_width;
            temp = zeros(size(thetas)); temp(list) = rad(list);
            [~,ind] = max(temp);
            
            if nnz(list) == 0
                data{k}(1,c) = NaN; % 1st row is SQUEEZ values
                data{k}(2,c) = mean([(c-1)*bin_width, c*bin_width]); % 2nd row is corresponding theta value
                data{k}(3,c) = NaN; % 3rd row is indices of sampled points
            else
                [~,locb] = ismember(slice{k}(ind,:),Mesh(j).rotated_verts,'rows');
                data{k}(1,c) = Mesh(j).RSct_vertex(locb);
                data{k}(2,c) = thetas(ind);
                data{k}(3,c) = locb;
            end
            
            dummy = c*bin_width;
            c = c + 1;
        end    
    end
    
    Mesh(j).Polar_Data = data;
    clearvars -except Mesh info j
    
end    