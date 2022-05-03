clear all; close all; clc;
name = {'Basal Anterior','Basal Anteroseptal','Basal Inferoseptal','Basal Inferior','Basal Inferolateral','Basal Anterolateral',...
    'Mid Anterior','Mid Anteroseptal','Mid Inferoseptal','Mid Inferior','Mid Inferolateral','Mid Anterolateral',...
    'Apical Anterior','Apical Septal','Apical Inferior','Apical Lateral'};

p{1} = 'AN11';
p{2} = 'AN51';
p{3} = 'AN91';
p{4} = 'AN101';
p{5} = 'AN111';
p{6} = 'AN121';
p{7} = 'AN131';
p{8} = 'AN151';
p{9} = 'CVC1907020903';
p{10} = 'CVC1907110858';
p{11} = 'CVC1905310931';
p{12} = 'CVC2001170927';
p{13} = 'CVC2001140915';
p{14} = 'CVC2002271407';
p{15} = 'CVC2002241126';

tconv = [72,93,70,70,70,70,70,70];
int_time = [0:5:1500];

for i = 1:length(p)
    
    if i<9
        load(['/Users/gcolvert/Documents/CViL_Research/Anthracycline_Patients/SQUEEZ_B2L3/',p{i},'/Results/',p{i},'.mat']);
        for t = info.timeframes
            for s = 1:16
                dum(s,t) = Mesh(t).AHA(s);
            end
        end
        for s = 1:16
            time = 0:tconv(i):(tconv(i)*(length(info.timeframes)-1));
            RSct(s,:) = interp1(time,dum(s,:)',int_time);
        end
        clear dum
    else
        load(['/Users/gcolvert/Documents/CViL_Research/SQUEEZ/',p{i},'/Results/',p{i},'.mat']);
        for t = info.timeframes
            for s = 1:16
                dum(s,t) = Mesh(t).AHA(s);
            end
        end
        for s = 1:16
            time = info.time_ms;
            RSct(s,:) = interp1(time,dum(s,:)',int_time);
        end
        clear dum
    end
    %     figure;
    
    dt = 20; % window on either side of min volume to search for peak RSct
    info.vol = interp1(time,info.vol,int_time);
    [~,id_ES] = min(info.vol); % index of min volume
    info.percent_rr = interp1(time,info.percent_rr,int_time);
    
    
    
    for s = 1:16
        dum = NaN(length(info.vol),1);
        dum(id_ES-dt:id_ES+dt,:) = RSct(s,id_ES-dt:id_ES+dt);
        [peak_RSct(i,s),peak_frame(i,s)] = min(dum);
        peak_RR(i,s) = info.percent_rr(peak_frame(i,s));
        %         subplot(4,4,s)
        %         plot(int_time,RSct(s,:)); hold on
        %         xline(int_time(peak_frame(i,s)));
        %         ylim([-0.5 0.1])
        clear dum
    end
    
    int = [20,40];
    
    for s = 1:16
        dum = polyfit(int_time(peak_frame(i,s)+int(1):peak_frame(i,s)+int(2)),RSct(s,peak_frame(i,s)+int(1):peak_frame(i,s)+int(2)),1);
        dias_rate(i,s) = round(dum(1)*1000,4);
        dias_int{i,s} = round([info.percent_rr(peak_frame(i,s)+int(1)),info.percent_rr(peak_frame(i,s)+int(2))],0);
                subplot(4,4,s)
                plot(int_time,RSct(s,:)); hold on
                yest = polyval(dum,int_time(peak_frame(i,s)+int(1):peak_frame(i,s)+int(2)));
                plot(int_time(peak_frame(i,s)+int(1):peak_frame(i,s)+int(2)),yest,'r')
                axis([0 1500 -0.5 0.1])
        clear dum ix
    end
    
    for s = 1:16
        int = [40,20];
        dum = polyfit(int_time(peak_frame(i,s)-int(1):peak_frame(i,s)-int(2)),RSct(s,peak_frame(i,s)-int(1):peak_frame(i,s)-int(2)),1);
        sys_rate(i,s) = round(dum(1)*1000,4);
        sys_int{i,s} = round([info.percent_rr(peak_frame(i,s)-int(1)),info.percent_rr(peak_frame(i,s)-int(2))],0);
%                 subplot(4,4,s)
%                 plot(int_time,RSct(s,:)); hold on
%                 yest = polyval(dum,int_time(peak_frame(i,s)-int(1):peak_frame(i,s)-int(2)));
%                 plot(int_time(peak_frame(i,s)-int(1):peak_frame(i,s)-int(2)),yest,'r')
%                 axis([0 1500 -0.5 0.1])
        clear dum ix
    end
    
    for j3 = 1:16
        
%         subplot(3,6,j3)
%         plot(int_time,RSct(j3,:),'k-','LineWidth',2); hold on
%         ax = gca; ax.FontSize = 10; ax.FontWeight= 'bold';
%         ylim([-0.5 0.1]); xlim([0 1500])
%         yticks([-0.5:0.1:0.1]); %xticks(0:100:1500)
%         ylabel('RS_C_T','FontSize',12); xlabel('Time (ms)','FontSize',12)
%         title([num2str(j3),'. ',name{j3}],'FontSize',15)
%         grid on; grid minor
    end
    
    RSCT_pat_ms{i} = RSct;
end

d1000 = dias_rate;
md1000 = mean(mean(d1000));
stdd1000 = std(std(d1000));

s1000 = sys_rate;
ms1000 = mean(mean(s1000));
stds1000 = std(std(s1000));

%%

for i = 1:length(p)
    for j = 1:16
        Seg_RSct{j}(i,:) = RSCT_pat_ms{i}(j,:);
    end
end

for s = 1:16
    mean_RSct(s,:) = nanmean(Seg_RSct{s});
    std_RSct(s,:) = nanstd(Seg_RSct{s});
end

close all;
figure;

mean_RSct2 = NaN(size(mean_RSct));

std_RSct2 = NaN(size(std_RSct));
for s = 1:16
    id = find(~isnan(mean_RSct(s,:)));
    
    th_sort = linspace(0,2*pi,length(id));
    nHARMO = 5; %no. of modes
    
    % Tpeak period of my signal
    tI = linspace(th_sort(1),th_sort(1)+2*pi,length(id))';
    
    % Enforcing periodicity
    X1 = mean_RSct(s,id);
    
    % Average value
    Avg_X1 = trapz(th_sort,X1)./(2*pi).*ones(length(id),1);
    
    for i = 1:nHARMO
        Si = sin(i*th_sort);
        Ci = cos(i*th_sort);
        
        Avg_X1 = Avg_X1 + trapz(th_sort,X1.*Si)./trapz(th_sort,Si.^2).*...
            sin(i*tI);
        Avg_X1 = Avg_X1 + trapz(th_sort,X1.*Ci)./trapz(th_sort,Ci.^2).*...
            cos(i*tI);
    end
    
    mean_RSct2(s,id) = Avg_X1';
    %%%%%%%%%%%
    id = find(~isnan(std_RSct(s,:)));
    
    th_sort = linspace(0,2*pi,length(id));
    nHARMO = 2; %no. of modes
    
    % Tpeak period of my signal
    tI = linspace(th_sort(1),th_sort(1)+2*pi,length(id))';
    
    % Enforcing periodicity
    X1 = std_RSct(s,id);
    
    % Average value
    Avg_X1 = trapz(th_sort,X1)./(2*pi).*ones(length(id),1);
    
    for i = 1:nHARMO
        Si = sin(i*th_sort);
        Ci = cos(i*th_sort);
        
        Avg_X1 = Avg_X1 + trapz(th_sort,X1.*Si)./trapz(th_sort,Si.^2).*...
            sin(i*tI);
        Avg_X1 = Avg_X1 + trapz(th_sort,X1.*Ci)./trapz(th_sort,Ci.^2).*...
            cos(i*tI);
    end
    
    std_RSct2(s,id) = Avg_X1';
    
end

for j3 = 1:16
    
    subplot(3,6,j3)
    plot(int_time,mean_RSct2(j3,:),'k-','LineWidth',3); hold on
    plot(int_time,mean_RSct2(j3,:)-2*std_RSct2(j3,:),'k-','LineWidth',1);
    plot(int_time,mean_RSct2(j3,:)+2*std_RSct2(j3,:),'k-','LineWidth',1);
    ax = gca; ax.FontSize = 10; ax.FontWeight= 'bold';
    ylim([-0.5 0.1]); xlim([0 1000])
    yticks([-0.5:0.1:0.1]); xticks(0:500:1000)
    ylabel('RS_C_T','FontSize',12); xlabel('Time (ms)','FontSize',12)
    title([num2str(j3),'. ',name{j3}],'FontSize',15)
    grid on; grid minor
    
end

%%
clear all; close all; clc;

p = [1,5,9,10,11,12,13,15];

for i = 1:length(p)
    load(['/Users/gcolvert/Documents/CViL_Research/Anthracycline_Patients/SQUEEZ_B2L3/AN',num2str(p(i)),'1/Results/AN',num2str(p(i)),'1.mat']);
    for t = info.timeframes
        for s = 1:16
            dum(s,t) = Mesh(t).AHA(s);
        end
    end
    for s = 1:16
        RSct{i}(s,:) = interp1(info.percent_rr,dum(s,:)',[0:1:95]);
    end
    clear dum
end

for i = 1:length(p)
    for j = 1:16
        Seg_RSct{j}(i,:) = RSct{i}(j,:);
    end
end

for s = 1:16
    mean_RSct(s,:) = nanmean(Seg_RSct{s});
    std_RSct(s,:) = nanstd(Seg_RSct{s});
end

name = {'Basal Anterior','Basal Anteroseptal','Basal Inferoseptal','Basal Inferior','Basal Inferolateral','Basal Anterolateral',...
    'Mid Anterior','Mid Anteroseptal','Mid Inferoseptal','Mid Inferior','Mid Inferolateral','Mid Anterolateral',...
    'Apical Anterior','Apical Septal','Apical Inferior','Apical Lateral'};


for j3 = 1:16
    
    subplot(3,6,j3)
    plot([0:1:95],mean_RSct(j3,:),'k-','LineWidth',3); hold on
    plot([0:1:95],mean_RSct(j3,:)-std_RSct(j3,:),'k:','LineWidth',2);
    plot([0:1:95],mean_RSct(j3,:)+std_RSct(j3,:),'k:','LineWidth',2);
    ax = gca; ax.FontSize = 10; ax.FontWeight= 'bold';
    ylim([-0.5 0.1]); xlim([0 100])
    yticks([-0.5:0.1:0.1]); xticks(0:20:100)
    ylabel('RS_C_T (mm)','FontSize',12); xlabel('%R-R Phase','FontSize',12)
    title([num2str(j3),'. ',name{j3}],'FontSize',15)
    grid on; grid minor
    
end

%% Calc peak strains and diastolic relaxtion
close all;
clear all; clc;
p = [1,5,9,10,11,12,13,15];

for i = 1:length(p)
    
    load(['/Users/gcolvert/Documents/CViL_Research/Anthracycline_Patients/SQUEEZ_B2L3/AN',num2str(p(i)),'1/Results/AN',num2str(p(i)),'1.mat']);
    
    dt = 2; % window on either side of min volume to search for peak RSct
    [~,id_ES] = min(info.vol); % index of min volume
    
    % Create mat of all row = time, col = segment
    for j = info.timeframes
        for s = 1:16
            RSct_mat(j,s) = Mesh(j).AHA(s);
        end
    end
    
    % Find peak RSct within window dt for each segment s
    for s = 1:16
        dum = NaN(length(info.timeframes),1);
        dum(id_ES-dt:id_ES+dt,:) = RSct_mat(id_ES-dt:id_ES+dt,s);
        [peak_RSct(i,s),peak_frame(i,s)] = min(dum);
        peak_RR(i,s) = info.percent_rr(peak_frame(i,s));
        clear dum
    end
    
    subplot(3,5,i)
    plot([1:16],peak_RSct(i,:),'ko')
    ylim([-0.5 0.1])
    histogram(peak_RSct(i,:),'BinLimits',[-0.5 0.1],'BinWidth',0.05)
    axis([-0.5 0.1 0 16])
    grid on;
    xlabel('Peak RS_C_T'); ylabel('# of AHA Segments')
    %     title(patient_list{i},'Interpreter', 'none')
    set(gca,'FontSize',15)
    
    % Find diastolic relaxation rate
    %     per = [0:1:95];
    %     int = [5,25];
    %     for s = 1:16
    %         RSct_int = interp1(info.percent_rr,RSct_mat(:,s)',per);
    %         [~, ix] = min(abs(per-info.percent_rr(peak_frame(i,s))));
    %         dum = polyfit(per(ix+int(1):ix+int(2)),RSct_int(ix+int(1):ix+int(2)),1);
    %         dias_rate(i,s) = round(dum(1),4);
    %         dias_interv{i,s} = [per(ix+int(1)),per(ix+int(2))];
    
    %         subplot(4,4,s)
    %         plot(info.percent_rr,RSct_mat(:,s)); hold on
    %         yest = polyval(dum,per(ix+int(1):ix+int(2)));
    %         plot(per(ix+int(1):ix+int(2)),yest,'r')
    %         axis([0 100 -0.5 0.1])
    %         clear dum ix
    
    %     end
    
    %     int = [5,25];
    %     for s = 1:16
    %         RSct_int = interp1(info.percent_rr,RSct_mat(:,s)',per);
    %         [~, ix] = min(abs(per-info.percent_rr(peak_frame(i,s))));
    %         dum = polyfit(per(ix-int(2):ix-int(1)),RSct_int(ix-int(2):ix-int(1)),1);
    %         sys_rate(i,s) = round(dum(1),4);
    %         sys_interv{i,s} = [per(ix-int(2)),per(ix-int(1))];
    
    %         subplot(4,4,s)
    %         plot(info.percent_rr,RSct_mat(:,s)); hold on
    %         yest = polyval(dum,per(ix-int(2):ix-int(1)));
    %         plot(per(ix-int(2):ix-int(1)),yest,'r')
    %         axis([0 100 -0.5 0.1])
    %         clear dum ix
    %     end
    
    clearvars -except patient_list dias_rate peak_RSct peak_frame peak_RR dias_interv p sys_rate sys_interv
    close all
    
end
