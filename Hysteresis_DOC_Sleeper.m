%% Title: Dissolved Organic Carbon hysteresis as a tool for revealing storm-event dynamics and improving water quality model performance
%If you utilize any part of this code, please cite Husic et al., 2023 (Water Resources Research).

%his code was modified from Husic et al. 2023's script for hysetersis
%anaylsis for the Sleepers River USGS experimental research station

clear all; close all; clc; warning('off'); 
addpath(genpath(pwd)) %this code adds all folders and subfolders within the current director to the path

%% Importing Data
dat = readtable("Sleepers River Aqueous Chemistry - working copy.csv"); %import csv table of data
timedate = table2array(dat(:,1)); %extract time and date values
Qstream = table2array(dat(:,2)); %extract streamflow
DOC = table2array(dat(:,3)); %extract dissolved organic carbon
WT = table2array(dat(:,4)); %extract water temp


%% Detecting Storms Algorithm
Storm_Cri = 5; %Criterion for storm identification (Q_max must be at least 7 times starting flow, Q_base)
Storm_Buf = 30; %Number of points to evaluate if streamflow is decreasing
%Here, we run a function to identify storms that meet our above criteria
[Storms, Storm_Info] = stormfind_fun(Qstream, Storm_Cri, Storm_Buf);
%'Storms' returns a cell array of the discharge values for each storm event 
%'Storm_Info' returns six columns, which represent: 
%   (1) starting Q for an event, (2) max Q for an event, (3) ending Q for an event, 
%   (4) index for event start, (5) index for event max Q, (6) index for event end 

%Retrieve DOC values at (1) event start, (2) event max Q, (3) event end 
DOC_Info = [DOC(Storm_Info(:,4)), DOC(Storm_Info(:,5)), DOC(Storm_Info(:,6))]; 
%Retrieve Water Temperature values at (1) event start, (2) event max Q, (3) event end 
WT_Info = [WT(Storm_Info(:,4)), WT(Storm_Info(:,5)), WT(Storm_Info(:,6))];


%Below, we ammend each 'Storms' cell array to add in corresponding SC and Turbidity data
for i = 1:length(Storms)
   beg = Storm_Info(i,4); %cell value of storm start
   fin = Storm_Info(i,6); %cell value of storm end
   Storms{i}(:,2) = DOC(beg:fin); %Add in the DOC data from the event
   %Storms{i}(:,3) = WT(beg:fin); %Add in the Temperature data from the event
end


%% Hysteresis Analysis
%make sure to conduct hysteresis only on events that (1) have corresponding DOC data and
%(2) have enough of a falling limb to meaninfully calculate indices
available_storms = 1:length(Storms);

%For all qualifying storm events, we conduct hysteresis of DOC
for p = available_storms

Q_D = Storms{p}(:,1); %flow data 
C_D = Storms{p}(:,2); %DOC data
% W_D = Storms{p}(:,3); %Water temp data

nt = 50; %number of increments for hysteresis 
%Here, we calculate hysteresis      
[q_Norm_dat,n_Norm_dat, HI_dat, FI_dat] = hysteresis_fun(Q_D, C_D, nt); %return hyteresis loop normalized C and Q values based on input time-series

HI(1,p) = HI_dat; %this retrieves the calculated hysteresis index
FI(1,p) = FI_dat; %this retrieves the calculated flushing index

norm_q(p,:) = q_Norm_dat; %retrieve normalized discharge values for loop plots
norm_c(p,:) = n_Norm_dat; %treieve normalized concentration values for loop plots
end


%% Plot some summary results
close all force
figure('Position',[300 300 250 225])
HI_plot = HI(available_storms); %avoid empty cells
FI_plot = FI(available_storms); %avoid empty cells

xline(0); %this generates a horizontal line through the origin
hold on; box on; grid minor;
yline(0); %this generates a vertical line through the origin 
scatter(HI_plot,FI_plot,'MarkerFaceColor',[0.2 0.6 0.4],'MarkerFaceAlpha',0.5)
ylabel('Flushing Index (FI)')
xlabel('Hysteresis Index (HI)')
xlim([-1.05, 1.05]); ylim([-1.05 1.05]);
title('DOC Results')

%close all force
figure('Position',[100 100 1100 800]) % Adjust the figure size as needed

num_storms = length(Storms);
rows = 3; %rows and columns of figure
cols = 4;
single=13; %plots a single storms hysteresis loop and time series

t = tiledlayout(rows, cols);
int_storm=1; %initial storm for plotting
fin_storm=12;%final storm to be plotted

f_titlesingle=50; %font size of plot titles
f_xysingle=40; %font size of x and y headers

f_titlehysteresis=65;
f_xyhystersis=55;

f_titlegrid=15; %font size of plot titles
f_xygrid=10; %font size of x and y headers
f_legendgrid=8;

for i = int_storm:fin_storm
    nexttile
    
    % Retrieve storm event details
    start_val = Storm_Info(i,4);
    end_val = Storm_Info(i,6);
    t_plot = timedate(start_val:end_val);
    q_plot = Storms{i}(:,1);
    sc_plot = Storms{i}(:,2);
    
    % Plot discharge and DOC
    yyaxis left
    plot(t_plot, q_plot, 'b', 'DisplayName', 'Discharge');
    ylabel('Discharge (ft^{3}/s)')
    
    yyaxis right
    plot(t_plot, sc_plot, 'r', 'DisplayName', 'DOC');
    ylabel('DOC (mg/L)')
    
    hold on; box on; grid minor;
    xlabel('Date')
    title(['Time Series - Storm ' num2str(i)])
    
    legend('Location', 'best'); % Add legend with default location
    
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k'; % Make both axes black
end
figure('Position',[100 100 1000 800]) % Creates new figure, adjust the figure size as needed

for i = single %plots single storm time series
    
    % Retrieve storm event details
    start_val = Storm_Info(i,4);
    end_val = Storm_Info(i,6);
    t_plot = timedate(start_val:end_val);
    q_plot = Storms{i}(:,1);
    sc_plot = Storms{i}(:,2);
    ax = gca;
    
    % Plot discharge and DOC
    yyaxis left
    plot(t_plot, q_plot, 'b', 'DisplayName', 'Discharge','LineWidth',7.5);
    ax.YAxis(1).FontSize = 27;
    ylabel('Discharge (ft^{3}/s)','FontSize',f_xysingle)
    
    yyaxis right
    plot(t_plot, sc_plot, 'r', 'DisplayName', 'DOC','LineWidth',7.5);
    ax.YAxis(2).FontSize = 27;
    ylabel('DOC (mg/L)', 'FontSize',f_xysingle)
    
    hold on; box on; grid minor;
    xlabel('Date', 'FontSize',f_xysingle) 
    title( ['Sleepers River - Storm ' num2str(i)] , 'FontSize', f_titlesingle);
    
    legend('Location', 'best', 'FontSize', 30); % Add legend with default location
    ax.XAxis.FontSize = 30;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k'; % Make both axis black
    
    
end
%% Next figure: hysterisis loops
figure('Position',[100 100 1000 800])  % Adjust the figure size as needed

t = tiledlayout(rows, cols); %plots the # of storms on a single gridded figure

for i = int_storm:fin_storm % creates a tile for each storm from range 
    nexttile % Plot the hysteresis loop for each storm event
    numcolors = 50; % Number of hysteresis plot
    colormapcustom = cool(numcolors); %In cool, blue is begining of loop, purple is the end of loop
    for r = 1:numcolors-1
        plot([norm_q(i,r),norm_q(i,r+1)],[norm_c(i,r),norm_c(i,r+1)],'-','color',colormapcustom(r,:),'LineWidth',2.5)
        hold on
    end   
    hold on; box on; grid minor;
    ylabel('Normalized DOC Conc.')
    xlabel('Normalized Flow')
    title(['Hysteresis Loop - Storm ' num2str(i)])
end
figure('Position',[100 100 1000 800])  % Adjust the figure size as needed

for i = single % plots single storm hysteresis
    numcolors = 50; % Number of hysteresis plot
    colormapcustom = cool(numcolors); %In cool, blue is begining of loop, purple is the end of loop
    for r = 1:numcolors-1
        plot([norm_q(i,r),norm_q(i,r+1)],[norm_c(i,r),norm_c(i,r+1)],'-','color',colormapcustom(r,:),'LineWidth',12)
        hold on
    end   
    hold on; box on; grid minor;
    ax=gca;
    ax.XAxis.FontSize = 0.25;
    ax.YAxis.FontSize = 0.25;
    ylabel('Normalized DOC','FontSize',f_xyhystersis)
    xlabel('Normalized Flow','FontSize',f_xyhystersis)
    %title(['Hysteresis Loop - Storm ' num2str(i)], 'FontSize', f_titlesingle)
    title(['Hysteresis Loop Storm ' num2str(i)], 'FontSize', f_titlehysteresis)
end

