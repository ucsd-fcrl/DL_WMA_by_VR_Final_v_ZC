function Mesh = Bullseye_Plots(Mesh,info)

load('RSct_Colormap.mat')

rows = ceil(length(info.timeframes)/info.polar_NoOfCols);
c = 1;
figure('pos',[10 10 2400 1800])

for jj = 1:size(info.timeframes,2)
    
    j = info.timeframes(jj);
    data = Mesh(j).Polar_Data;
    
    % Interpolating raw data to achieve desired bullseye plot resolution in the azimuthal direction
    for k = 1:numel(data)
                
        if k < info.lvot_limit(j)
            temp = interp1(data{k}(2,:),data{k}(1,:),linspace(min(data{k}(2,:)),max(data{k}(2,:)),info.polar_res(1)));
        else
           ind = ~isnan(data{k}(1,:));
           temp = interp1(data{k}(2,ind),data{k}(1,ind),linspace(min(data{k}(2,ind)),max(data{k}(2,ind)),info.polar_res(1)));
        end   
        
        bull_data(k,:) = temp;
        clear temp
    end
    
    %Interpolating bull_data to achieve desired resolution in slice direction
    temp = interp1(1:numel(data),bull_data,linspace(1,numel(data),info.polar_res(2)));
    temp = flip(temp);
       
    % Putting last value at first and first value at last to ensure a smooth bullseye plot
    temp = [temp(:,end), temp];
    temp = [temp, temp(:,2)];
    temp = temp';
    
    Mesh(j).Bullseye = temp;
    
    subplot(rows,info.polar_NoOfCols,c)
    bullseye(temp); colormap(cmap); caxis(info.RSct_limits);
    h = colorbar; set(h,'position',[0.93 0.05 0.015 0.9]); h.FontSize = 15; h.FontWeight = 'bold'; h.Ticks = -1:0.05:1; set(get(h,'Title'),'string','RS_{CT}');
    title([num2str(info.percent_rr(jj)),'%'],'FontSize',15','FontWeight','bold')
    
    c = c + 1;
    clear bull_data temp
end
