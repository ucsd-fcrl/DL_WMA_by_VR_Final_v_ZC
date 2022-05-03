clear all; close all; clc

patient_list{1} = 'CVC1901301419_kawasaki';
patient_list{2} = 'CVC1903130917';
patient_list{3} = 'CVC1904170908';
patient_list{4} = 'CVC1904171101';
patient_list{5} = 'CVC1908071009_kawasaki';
patient_list{6} = 'CVC1908140919_kawasaki';
patient_list{7} = 'CVC1908220904_kawasaki';
patient_list{8} = 'CVC1908281435_kawasaki_70ms';
patient_list{9} = 'CVC1909250911_Kawasaki';
patient_list{10} = 'CVC1909251405_Kawasaki';
patient_list{11} = 'CVC1911270907_kawasaki';
patient_list{12} = 'CVC1912231315_kawasaki';
patient_list{13} = 'CVC2001081447_kawasaki';

tconv = [70,70,70,70,70,70,70,70,70,70,70,70,70];

for i = 1:length(patient_list)
    
    if i == 8
        load(['/Users/gcolvert/Documents/CViL_Research/SQUEEZ/',patient_list{i},'/SSF2/Results/',patient_list{i},'.mat'])
    else
        load(['/Users/gcolvert/Documents/CViL_Research/SQUEEZ/',patient_list{i},'/Results/',patient_list{i},'.mat'])
    end
    
    figure;
    for t = info.timeframes
        for s = 1:16
            dum(s,t) = Mesh(t).AHA(s);
        end
    end
    
    for s = 1:16
        if i ==8
            time = [0:tconv(i):(tconv(i)*(length(info.timeframes)-1))]-35;
            RSct(s,:) = interp1(time,dum(s,:)',[0:5:1500]);
        else
            time = 0:tconv(i):(tconv(i)*(length(info.timeframes)-1));
            RSct(s,:) = interp1(time,dum(s,:)',[0:5:1500]);
        end
    end
    clear dum
    
    dt = 20; % window on either side of min volume to search for peak RSct
    info.vol = interp1(time,info.vol,[0:5:1500]);
    [~,id_ES] = min(info.vol); % index of min volume
    info.percent_rr = interp1(time,info.percent_rr,[0:5:1500]);
    
    int_time = [0:5:1500];
    
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
    
    int = [15,35];
    
    for s = 1:16
        int_time = [0:5:1500];
        dum = polyfit(int_time(peak_frame(i,s)+int(1):peak_frame(i,s)+int(2)),RSct(s,peak_frame(i,s)+int(1):peak_frame(i,s)+int(2)),1);
        dias_rate(i,s) = round(dum(1)*1000,4);
        dias_int{i,s} = round([info.percent_rr(peak_frame(i,s)+int(1)),info.percent_rr(peak_frame(i,s)+int(2))],0);
        %         subplot(4,4,s)
        %         plot(int_time,RSct(s,:)); hold on
        %         yest = polyval(dum,int_time(peak_frame(i,s)+int(1):peak_frame(i,s)+int(2)));
        %         plot(int_time(peak_frame(i,s)+int(1):peak_frame(i,s)+int(2)),yest,'r')
        %         axis([0 1500 -0.5 0.1])
        clear dum ix
    end
    
    for s = 1:16
        int = [35,15];
        dum = polyfit(int_time(peak_frame(i,s)-int(1):peak_frame(i,s)-int(2)),RSct(s,peak_frame(i,s)-int(1):peak_frame(i,s)-int(2)),1);
        sys_rate(i,s) = round(dum(1)*1000,4);
        sys_int{i,s} = round([info.percent_rr(peak_frame(i,s)-int(1)),info.percent_rr(peak_frame(i,s)-int(2))],0);
        subplot(4,4,s)
        plot(int_time,RSct(s,:)); hold on
        yest = polyval(dum,int_time(peak_frame(i,s)-int(1):peak_frame(i,s)-int(2)));
        plot(int_time(peak_frame(i,s)-int(1):peak_frame(i,s)-int(2)),yest,'r')
        axis([0 1500 -0.5 0.1])
        clear dum ix
    end
    RSCT_pat_ms{i} = RSct;
end

% d1000 = dias_rate*1000;
% md1000 = mean(mean(d1000));
% stdd1000 = std(std(d1000));
%
% s1000 = sys_rate*1000;
% ms1000 = mean(mean(s1000));
% stds1000 = std(std(s1000));

%%
% for i = 1:length(patient_list)
%
%     load(['/Users/gcolvert/Documents/CViL_Research/SQUEEZ/',patient_list{i},'/Results/',patient_list{i},'.mat'])
%
%     dt = 1; % window on either side of min volume to search for peak RSct
%     [~,id_ES] = min(info.vol); % index of min volume
%
%     % Create mat of all row = time, col = segment
%     for j = info.timeframes
%         for s = 1:16
%             RSct_mat(j,s) = Mesh(j).AHA(s);
%         end
%     end
%
%     % Find peak RSct within window dt for each segment s
%     for s = 1:16
%         dum = NaN(length(info.timeframes),1);
%         dum(id_ES-dt:id_ES+dt,:) = RSct_mat(id_ES-dt:id_ES+dt,s);
%         [peak_RSct(i,s),peak_frame(i,s)] = min(dum);
%         peak_RR(i,s) = info.percent_rr(peak_frame(i,s));
%         clear dum
%     end
%
%     subplot(3,5,i)
%     % plot([1:16],peak_RSct(i,:),'ko')
%     % ylim([-0.5 0.1])
%     histogram(peak_RSct(i,:),'BinLimits',[-0.5 0.1],'BinWidth',0.05)
%     axis([-0.5 0.1 0 16])
%     grid on;
%     xlabel('Peak RS_C_T'); ylabel('# of AHA Segments')
%     title(patient_list{i},'Interpreter', 'none')
%     set(gca,'FontSize',15)
%
%     % Find diastolic relaxation rate
%     per = [0:1:95];
%     int = [5,25];
%     for s = 1:16
%         RSct_int = interp1(info.percent_rr,RSct_mat(:,s)',per);
%         [~, ix] = min(abs(per-info.percent_rr(peak_frame(i,s))));
%         dum = polyfit(per(ix+int(1):ix+int(2)),RSct_int(ix+int(1):ix+int(2)),1);
%         dias_rate(i,s) = round(dum(1),4);
%         dias_interv{i,s} = [per(ix+int(1)),per(ix+int(2))];
%
% %         subplot(4,4,s)
% %         plot(info.percent_rr,RSct_mat(:,s)); hold on
% %         yest = polyval(dum,per(ix+int(1):ix+int(2)));
% %         plot(per(ix+int(1):ix+int(2)),yest,'r')
% %         axis([0 100 -0.5 0.1])
%         clear dum ix
%     end
%
%     clearvars -except patient_list dias_rate peak_RSct peak_frame peak_RR dias_interv
% %     close all
%
% end

%% Put Kawasaki curves on top of AN curves
close all;

patient_list{1} = 'CVC1901301419_kawasaki';
patient_list{2} = 'CVC1903130917';
patient_list{3} = 'CVC1904170908';
patient_list{4} = 'CVC1904171101';
patient_list{5} = 'CVC1908071009_kawasaki';
patient_list{6} = 'CVC1908140919_kawasaki';
patient_list{7} = 'CVC1908220904_kawasaki';
patient_list{8} = 'CVC1908281435_kawasaki_70ms';
patient_list{9} = 'CVC1909250911_Kawasaki';
patient_list{10} = 'CVC1909251405_Kawasaki';
patient_list{11} = 'CVC1911270907_kawasaki';
patient_list{12} = 'CVC1912231315_kawasaki';
patient_list{13} = 'CVC2001081447_kawasaki';

name = {'Basal Anterior','Basal Anteroseptal','Basal Inferoseptal','Basal Inferior','Basal Inferolateral','Basal Anterolateral',...
    'Mid Anterior','Mid Anteroseptal','Mid Inferoseptal','Mid Inferior','Mid Inferolateral','Mid Anterolateral',...
    'Apical Anterior','Apical Septal','Apical Inferior','Apical Lateral'};

for i = 1:length(patient_list)
    
    fig1=figure(1);
    fig1.Units='Normalized';
    fig1.Position=[0.01 0.01 1 1];
    
    for j = 1:16
        subplot(3,6,j)
        plot(int_time,RSCT_pat_ms{i}(j,:),'r-','LineWidth',2); hold on
        ax = gca; ax.FontSize = 10; ax.FontWeight= 'bold';
        ylim([-0.5 0.1]); xlim([0 1000])
        yticks([-0.5:0.1:0.1]); %xticks(0:100:1500)
        ylabel('RS_C_T','FontSize',12); xlabel('Time (ms)','FontSize',12)
        title([num2str(j),'. ',name{j}],'FontSize',15)
        grid on; grid minor
    end
    hline = findobj(gcf, 'type', 'line');
    
    
    fig2 = open('/Users/gcolvert/Documents/CViL_Research/Anthracycline_Patients/SQUEEZ_B2L3/AN+males_AHA_all_2STD_ms_incl_1_5_9_10_11_12_13_15.fig');
    
    ax1 = get(fig1, 'Children');
    ax2 = get(fig2, 'Children');
    
    for xt = 1 : numel(ax2)
        ax2Children = get(ax2(xt),'Children');
        copyobj(ax2Children, ax1(xt));
    end
    
    close(fig2)
    
    
    savefig(['/Users/gcolvert/Documents/CViL_Research/Kawasaki_Data/AHAcurves_wNorm/',patient_list{i},'_AHA_wNorm_2Stdev.fig'])
    saveas(fig1,['/Users/gcolvert/Documents/CViL_Research/Kawasaki_Data/AHAcurves_wNorm/',patient_list{i},'_AHA_wNorm_2Stdev.tif'],'tif')
    
    
    close(fig1)
end

%% Make movie
clear all; close all; clc;

repo_path = '/Users/gcolvert/Documents/MATLAB/squeez-code/';
addpath(genpath(repo_path));

patient_list{1} = 'CVC1901301419_kawasaki';
patient_list{2} = 'CVC1903130917';
patient_list{3} = 'CVC1904170908';
patient_list{4} = 'CVC1904171101';
patient_list{5} = 'CVC1908071009_kawasaki';
patient_list{6} = 'CVC1908140919_kawasaki';
patient_list{7} = 'CVC1908220904_kawasaki';
patient_list{8} = 'CVC1908281435_kawasaki_70ms';
patient_list{9} = 'CVC1909250911_Kawasaki';
patient_list{10} = 'CVC1909251405_Kawasaki';
patient_list{11} = 'CVC1911270907_kawasaki';
patient_list{12} = 'CVC1912231315_kawasaki';
patient_list{13} = 'CVC2001081447_kawasaki';

i=7;

load(['/Users/gcolvert/Documents/CViL_Research/SQUEEZ/',patient_list{i},'/Results/',patient_list{i},'.mat'])

info.save_path = '/Users/gcolvert/Desktop/KDvid';
mkdir(info.save_path)

[Mesh,info] = squeez_4D_movie_KD(Mesh,info);


