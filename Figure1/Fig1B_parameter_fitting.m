%% Sepsis Model - Visualization Script
clear all; close all; clc 


% Load experimental data
data = load('peritonitis_data.mat').A;

% Exp data is the table with columns:
% Hours, n, N, M1, M2, sigma_N, sigma_N_bar, sigma_M1, sigma_M1_bar, sigma_M2, sigma_M2_bar

% Extract experimental time points and cell counts
exp_time = data(:, 1); % Hours column
exp_N = data(:, 3);  % N column
exp_M1 = data(:, 4); % M1 column
exp_M2 = data(:, 5); % M2 column

% Extract standard errors (using sigma_bar values for weighting)
se_N = data(:, 7);   % sigma_N_bar column
se_M1 = data(:, 9);  % sigma_M1_bar column
se_M2 = data(:, 11); % sigma_M2_bar column

% Combine experimental data into a single matrix
experimental_data = [exp_N, exp_M1, exp_M2];
standard_errors = [se_N, se_M1, se_M2];

% Simulation settings
Patho = 20;
first_exp_time_days = exp_time(1)/24; % Convert hours to days
tspan = first_exp_time_days:0.01:8;   % Start simulation at first exp time
% tspan = 0:0.01:8;
options = odeset('RelTol', 1e-10, 'AbsTol', 1e-10);

% Initial conditions
x0 = [exp_N(1) 1 exp_M1(1) exp_M2(1) Patho 0 0];
% N,Mo,M1,M2,P,IL6,TGFbeta

% Load and display fitted p values
p= load('p_fitted.mat').p;

disp('Fitted parameters:');
disp(p);

% Run simulation
[t, y] = ode23s(@(t,x) ODEModel(t, x, p), tspan, x0, options);

% Extract cell populations
Neutrophil = y(:,1);
M1 = y(:,3);
M2 = y(:,4);

% Convert experimental time points to indices in simulation
timePoints = zeros(size(exp_time));
for i = 1:length(exp_time)
    [~, timePoints(i)] = min(abs(t - exp_time(i)/24));
end

%% ====================== FIGURE 1: Sim vs Exp ======================
fig = figure(1); clf;

set(fig, ...
    'Color', 'w', ...
    'PaperUnits', 'inches', ...
    'PaperType', 'usletter', ...
    'PaperOrientation', 'portrait', ...
    'PaperPositionMode', 'manual', ...
    'PaperPosition', [0, 0, 7, 3.5], ...  % [left, bottom, width, height]
    'Units', 'inches', ...
    'Position', [0, 0, 7, 3.5]);             % On-screen size = print size

tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');


LRed = [0.84 0.53 0.52];  DRed = [211 76 73]/255;
LBlue = [0.50 0.58 1.0];  DBlue = [73 87 252]/255;
LGreen = [0.49 0.71 0.72]; DGreen = [ 38 127 128]/255;

nexttile; 
plot(t, Neutrophil, 'Color', LBlue, 'LineWidth', 2);hold on;%'-b',
errorbar(exp_time./24, exp_N, se_N,'diamond', 'Color', DBlue, 'MarkerSize', 8, 'MarkerFaceColor',DBlue,'LineWidth',1.2);%'bo' % 'b'
leg1=legend('fit', 'exp.', 'Location', 'Northeast');
set(leg1,'Box','off')
xlabel('Time (days)'); ylabel('Neutrophils');
xlim([0 8])

nexttile;
plot(t, M1, 'Color', LRed, 'LineWidth', 2);hold on;%'-g',
errorbar(exp_time./24, exp_M1, se_M1, 'o', 'Color', DRed, 'MarkerSize', 8, 'MarkerFaceColor', DRed,'LineWidth',1.2);%'go','g'
xlabel('Time (days)'); ylabel('M1 Macrophages');
leg2=legend('fit', 'exp.', 'Location', 'Northeast');
set(leg2,'Box','off')
xlim([0 8]); 

nexttile;
plot(t, M2,'Color', LGreen, 'LineWidth', 2);hold on;%'-m',
errorbar(exp_time./24, exp_M2, se_M2, 'square', 'Color', DGreen, 'MarkerSize', 8, 'MarkerFaceColor', DGreen, 'LineWidth',1.2);%'mo','m'
xlabel('Time (days)'); ylabel('M2 Macrophages');
% title('M2 Macrophages Over Time');
leg3=legend('fit', 'exp.', 'Location', 'Northeast');
set(leg3,'Box','off')
xlim([0 8])

% Get all axes in the figure (in order of creation)
all_axes = findall(gcf, 'Type', 'axes');

% Standardize formatting for all axes
for ax = all_axes'
    set(ax, ...
        'FontName', 'Helvetica', ...
        'FontSize', 14, ...
        'LineWidth', 1, ...
        'Box', 'on', ...
        'TickDir', 'in');
end

% Plot all state variables - Figure 2
fig_all = figure(2); clf;

set(fig_all, ...
    'Color', 'w', ...
    'PaperUnits', 'inches', ...
    'PaperType', 'usletter', ...
    'PaperOrientation', 'portrait', ...
    'PaperPositionMode', 'manual', ...
    'PaperPosition', [1, 1, 7, 9.167], ...  % [left, bottom, width, height]
    'Units', 'inches', ...
    'Position', [0, 0, 7, 9.167]);             % On-screen size = print size

tiledlayout(4,2, 'Padding', 'compact', 'TileSpacing', 'compact');
stateNames = {'Neutrophil', 'Monocyte', 'M1', 'M2', 'P', 'IL-6', 'TGF-\beta'};

for i = 1:7
    nexttile;
    plot(t, y(:,i), 'LineWidth', 1.5);
    title(stateNames{i});
    xlabel('Time (days)');
    grid on;
end

% Get all axes in the figure (in order of creation)
all_axes = findall(gcf, 'Type', 'axes');

% Standardize formatting for all axes
for ax = all_axes'
    set(ax, ...
        'FontName', 'Helvetica', ...
        'FontSize', 14, ...
        'LineWidth', 1.0, ...
        'Box', 'on', ...
        'TickDir', 'in');
end

% Convert experimental time points to indices in simulation
timePoints = zeros(size(exp_time));
for i = 1:length(exp_time)
    [~, timePoints(i)] = min(abs(t - exp_time(i)/24));
end

Error_N = sum((exp_N - Neutrophil(timePoints)).^2);
Error_M1 = sum((exp_M1- M1(timePoints)).^2);
Error_M2 = sum((exp_M2 - M2(timePoints)).^2);

% Total error
objective = Error_N + Error_M1 + Error_M2;

% Display current error
disp(['SSE Objective: ' num2str(objective)]);

% Get all axes in the figure (in order of creation)
all_axes = findall(gcf, 'Type', 'axes');

% Standardize formatting for all axes
for ax = all_axes'
    set(ax, ...
        'FontName', 'Helvetica', ...
        'FontSize', 14, ...
        'LineWidth', 1, ...
        'Box', 'on', ...
        'TickDir', 'in');
end
