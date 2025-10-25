%% Global Sensitivity Analysis
close all; clear; clc;

% Load results
load('Robust_GSA_Results.mat');

% Extract trajectories for healed and septic cases
healed_trajectories = cell(length(Healed_Params), 1);
septic_trajectories = cell(length(Septic_Params), 1);

% Get common time vector 
tspan = Healed_Params{1}.t;

% Initialize arrays to collect all states
state_names = {
    'Neutrophils', 
    'M_o Monocytes', 
    'M_1 Macrophages', 
    'M_2 Macrophages',
    'Pathogen',
    'IL-6',
    'TGF-β'
};
num_states = 7;

Patho = 20;
required = 0.10*20; % 90% clearance threshold

% Preallocate storage matrices
all_healed = cell(num_states, 1);
all_septic = cell(num_states, 1);
for s = 1:num_states
    all_healed{s} = [];
    all_septic{s} = [];
end

% Collect healed trajectories
for i = 1:length(Healed_Params)
    y = Healed_Params{i}.y;
    for s = 1:num_states
        all_healed{s} = [all_healed{s},abs(y(:,s))];
    end
end

% Collect septic trajectories
for i = 1:length(Septic_Params)
    y = Septic_Params{i}.y;
    for s = 1:num_states
        all_septic{s} = [all_septic{s},y(:,s)];
    end
end

% === Compute min/max instead of std ===
min_healed = cell(num_states, 1);
max_healed = cell(num_states, 1);
min_septic = cell(num_states, 1);
max_septic = cell(num_states, 1);

for s = 1:num_states
    min_healed{s} = min(all_healed{s}, [], 2);
    max_healed{s} = max(all_healed{s}, [], 2);
    min_septic{s} = min(all_septic{s}, [], 2);
    max_septic{s} = max(all_septic{s}, [], 2);
end
%% ====================== FIGURE 1: Original vs Controlled ======================
fig = figure(1); clf;
set(fig, ...
    'Color', 'w', ...
    'PaperUnits', 'inches', ...
    'PaperType', 'usletter', ...
    'PaperOrientation', 'portrait', ...
    'PaperPositionMode', 'manual', ...
    'PaperPosition', [1, 1, 7, 7], ...  % [left, bottom, width, height]
    'Units', 'inches', ...
    'Position', [0, 0, 7, 7]);          

tiledlayout(3,2, 'Padding', 'compact', 'TileSpacing', 'tight');

% Professional color scheme
color_septic = [0.851, 0.325, 0.098];   % Orange (original septic)
color_healed = [0.09,0.52,0.40];       % Dark Cyan Green (original healed)


for s = 1:num_states-1
    nexttile;
    hold on;
    box on;
    
    % === Plot min-max ranges instead of std ===
    % Healed range
    fill([tspan; flipud(tspan)], ...
        [max_healed{s}; flipud(min_healed{s})], ... 
        color_healed ,'Facealpha',0.12, 'EdgeColor', color_healed,'EdgeAlpha',0.8,'LineWidth',1,LineStyle='--');%color_healed       

    % Septic range
    fill([tspan; flipud(tspan)], ...
        [max_septic{s}; flipud(min_septic{s})], ...
        color_septic ,'Facealpha',0.08,'EdgeColor',color_septic,'EdgeAlpha',0.8,'LineWidth',1,LineStyle='--');
    % =====================================================
    
    % Plot mean lines (unchanged)
    mean_healed = mean(all_healed{s}, 2); 
    mean_septic = mean(all_septic{s}, 2);
    
    h1 = plot(tspan, mean_healed, 'Color', color_healed , ...
        'LineWidth', 2.5, 'DisplayName', 'Acute healing');
    h2 = plot(tspan, mean_septic, 'Color', color_septic, ...
        'LineWidth', 2.5, 'DisplayName', 'Septic healing');
    
    % Formatting
    set(gca, 'LineWidth', 1.2, 'TickDir', 'in');
    xlim([0 8]);
    grid off;

    % Panel labels
    label_text = [state_names{s}];
    text(0.12, 0.8, label_text, ...
        'Units', 'normalized', ...
        'FontSize', 15, ...
        'FontWeight', 'normal', ...
        'HorizontalAlignment', 'left');
    
    if s == 5
        set(gca, 'YScale', 'log');
        ylabel({'log scale (a.u.)'});
    else
        ylim([0 inf]);
        ylabel('cell counts (\times10^7)', 'FontSize', 15.4);
    end
    xlabel('time (days)', 'FontSize', 15.4);
    
    % Add legend only to first plot
    if s == 1
        legend('show', 'Location','northoutside', 'Box', 'off', 'NumColumns', 4);
    end
end

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
