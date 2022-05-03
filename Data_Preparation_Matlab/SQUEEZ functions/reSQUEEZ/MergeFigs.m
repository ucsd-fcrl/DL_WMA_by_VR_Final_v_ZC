%% Combine AHA curves

fig1 = open('/Users/gcolvert/Documents/CViL_Research/SQUEEZ/CVC1901301419_kawasaki/Results/CVC1901301419_kawasaki_VolvsRRper.fig');
hline = findobj(gcf, 'type', 'line');
set(hline,'Color','r');

fig2 = open('/Users/gcolvert/Documents/CViL_Research/SQUEEZ/CVC2001081447_kawasaki/Results/CVC2001081447_kawasaki_VolvsRRper.fig');

% fig1 = open('/Users/gcolvert/Documents/CViL_Research/SQUEEZ/CVC1909251405_kawasaki/Results_B2L3_PapsFill/CVC1909251405_kawasaki_AHA.fig');
% hline = findobj(gcf, 'type', 'line');
% set(hline,'Color','r');
% 
% fig2 = open('/Users/gcolvert/Documents/CViL_Research/SQUEEZ/CVC1909251405_kawasaki/Results/CVC1909251405_kawasaki_AHA.fig');

ax1 = get(fig1, 'Children');
ax2 = get(fig2, 'Children');

for i = 1 : numel(ax2) 
   ax2Children = get(ax2(i),'Children');
   copyobj(ax2Children, ax1(i));
end

% title('006-E002')
% legend('paps filled','W paps')
close(fig2)


%% Compare Error between paps filled and not filled
close all;

fig1 = open('/Users/gcolvert/Documents/CViL_Research/Anthracycline_Patients/SQUEEZ_B2L3/AN101/Results/AN101_AHA.fig');
hline = findobj(gcf, 'type', 'line');
set(hline,'Color','r');

fig2 = open('/Users/gcolvert/Documents/CViL_Research/Anthracycline_Patients/SQUEEZ_B2L3/AN101/Results_noTempSmooth/AN101_AHA.fig');

ax1 = get(fig1, 'Children');
ax2 = get(fig2, 'Children');
 
for i = 1 : numel(ax2) 
   ax2Children = get(ax2(i),'Children');
   copyobj(ax2Children, ax1(i));
end

legend('Temp Smoothing','No Smoothing')
close(fig2)

%%
fig1 = open('/Users/gcolvert/Documents/CViL_Research/Anthracycline_Patients/SQUEEZ_2pt0/AN12/Results_wPaps/AN12_GlobalError.fig');
hline = get(fig1,'Children');
hline.Children.Color = 'r';

fig2 = open('/Users/gcolvert/Documents/CViL_Research/Anthracycline_Patients/SQUEEZ_2pt0/AN12/Results/AN12_GlobalError.fig');

ax1 = get(fig1, 'Children');
ax2 = get(fig2, 'Children');
 
for i = 1 : numel(ax2) 
   ax2Children = get(ax2(i),'Children');
   copyobj(ax2Children, ax1(i));
end

legend('w Paps','Paps Filled')
close(fig2)

%%
clear all; close all; clc;

fig1 = open('/Users/gcolvert/Documents/CViL_Research/Anthracycline_Patients/SQUEEZ_2pt0/AN11/Results_B2L3_wPaps/AN11_AHA.fig');
hline1 = findobj(gcf, 'type', 'line');

XData1=get(hline1,'XData'); %get the x data
YData1=get(hline1,'YData'); %get the y data

fig2 = open('/Users/gcolvert/Documents/CViL_Research/Anthracycline_Patients/SQUEEZ_2pt0/AN12/Results_B2L3_wPaps/AN12_AHA.fig');
hline2 = findobj(gcf, 'type', 'line');

XData2=get(hline2,'XData'); %get the x data
YData2=get(hline2,'YData'); %get the y data

close all;

name = {'Basal Anterior','Basal Anteroseptal','Basal Inferoseptal','Basal Inferior','Basal Inferolateral','Basal Anterolateral',...
    'Mid Anterior','Mid Anteroseptal','Mid Inferoseptal','Mid Inferior','Mid Inferolateral','Mid Anterolateral',...
    'Apical Anterior','Apical Septal','Apical Inferior','Apical Lateral'};
info.RSct_limits = [-0.5 0.1];

for j3 = 1:16
      
    subplot(3,6,j3)
    plot(XData1{1},YData1{j3},'r','LineWidth',3);
    hold on;
    plot(XData2{1}-6,YData2{j3},'LineWidth',3);
    ax = gca; ax.FontSize = 10; ax.FontWeight= 'bold';
    ylim([info.RSct_limits]); xlim([0 100])
    yticks([-1:0.1:1]); xticks(0:20:100)
    ylabel('RS_{CT}','FontSize',12); xlabel('%R-R Phase','FontSize',12)
    title([num2str(j3),'. ',name{j3}],'FontSize',15)
    grid on; grid minor
        
end

%%
