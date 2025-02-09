%% Title: Dissolved Organic Carbon Hysteresis Analysis
% If you utilize any part of this code, please cite Husic et al., 2023 (Water Resources Research).

%This code was modified from Husic et al. 2023's script for hysetersis
%anaylsis for the Amherst Mill River Wet Center station storm 7. 
% This code is organized for analysis of a single storm. 

clear all; close all; clc; warning('off');
addpath(genpath(pwd)) % Adds all folders and subfolders within the current directory to the path

%% Importing Data
dat = readtable("Mill River Storm 7.xlsx"); % Import Excel file
timedate = table2array(dat(:,1)); % Extract time and date values
Flow = table2array(dat(:,2)); % Extract streamflow
DOC = table2array(dat(:,3)); % Extract dissolved organic carbon
O18 = table2array(dat(:,4)); % Extract delta-18O

%% Normalize Flow and DOC
norm_q = (Flow - min(Flow)) / (max(Flow) - min(Flow)); % Normalize Flow
norm_c = (DOC - min(DOC)) / (max(DOC) - min(DOC));    % Normalize DOC

%% Flushing Index (FI) and Hysteresis Index (HI) Calculation

% Find the index of peak flow
[~, peak_idx] = max(Flow);

% Split data into rising and falling limbs
norm_c_rising = norm_c(1:peak_idx);  % Normalized DOC during rising limb
norm_c_falling = norm_c(peak_idx+1:end);  % Normalized DOC during falling limb

% Ensure both limbs have the same length by interpolation
min_length = min(length(norm_c_rising), length(norm_c_falling));
norm_c_rising_resampled = interp1(1:length(norm_c_rising), norm_c_rising, linspace(1, length(norm_c_rising), min_length));
norm_c_falling_resampled = interp1(1:length(norm_c_falling), norm_c_falling, linspace(1, length(norm_c_falling), min_length));

% Calculate Hysteresis Index (HI)
HI = norm_c_rising_resampled - norm_c_falling_resampled; % HI = XiRL - XiFL

% Calculate Flushing Index (FI)
FI = norm_c(peak_idx) - norm_c(1); % FI = XmaxQ - XinitialQ

% Display Results
fprintf('Flushing Index (FI): %.3f\n', FI);
fprintf('Hysteresis Index (HI): %.3f\n', mean(HI));

%% Hysteresis Loop Plot
figure('Position', [100 100 800 800]) % Adjust figure size
colormapcustom = cool(length(norm_q)); %In cool, blue is begining of loop, purple is the end of loop

for r = 1:length(norm_q)-1
    plot([norm_q(r), norm_q(r+1)], [norm_c(r), norm_c(r+1)], '-', ...
        'Color', colormapcustom(r, :), 'LineWidth', 12); % Adjust LineWidth
    hold on;
end

hold on; box on; grid minor;
ax = gca;
ax.XAxis.FontSize = 27;
ax.YAxis.FontSize = 27;
ylabel('Normalized DOC', 'FontSize', 32);
xlabel('Normalized Flow', 'FontSize', 32);
title({'Hysteresis Loop', 'Mill River Storm 7'}, 'FontSize', 40);
% Annotate FI and HI on the hysteresis plot
dim = [0.15 0.75 0.3 0.1]; % [x y w h] position for annotation box
annotation('textbox', dim, 'String', ...
    {['Flushing Index (FI): ', num2str(FI, '%.2f')], ...
     ['Hysteresis Index (HI): ', num2str(mean(HI), '%.2f')]}, ...
    'FitBoxToText', 'on', 'FontSize', 20, 'BackgroundColor', 'white');

%% Time Series Plot
figure('Position', [100 100 1000 800]) % Adjust figure size

yyaxis left
plot(timedate, Flow, 'b-', 'LineWidth', 7.5, 'DisplayName', 'Flow');
ylabel('Discharge (ft^3/s)', 'FontSize', 27);

yyaxis right
plot(timedate, DOC, 'r-', 'LineWidth', 7.5, 'DisplayName', 'DOC');
ylabel('DOC (mg/L)', 'FontSize', 27);

hold on; box on; grid minor;
xlabel('Date', 'FontSize', 27);
title('Mill River - Storm 7', 'FontSize');
legend('Location', 'best', 'FontSize', 30);
