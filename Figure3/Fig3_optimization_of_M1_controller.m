%% for M1 CytoKontroller1 
%% Optimization vaying 
% control strength (\alpha), 
% Hill coefficient (n) &
% activation threshold (Kd)

clc; clear;

load M1_sweep_results.mat

fig = figure(1); clf;
main_layout = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

set(fig, ...
    'PaperUnits', 'inches', ...
    'PaperType', 'usletter', ...           % MATLAB Built-in
    'PaperOrientation', 'portrait', ...    % or 'landscape'
    'PaperPositionMode', 'manual', ...     % by default it is also manual
    'PaperPosition', [0.75, 1, 7, 5], ...  %[distance_from_left distance_from_bottom width height] %default is [0.25 2.5 8.0 6.0]
    'Units', 'inches', ...
    'Position', [1, 1, 7, 5]);             % On-screen size matches print size


%% 1: Control strength effect
nexttile(1);
hold on;
legend_entries = {};
kd_unique = unique([results_table.Kd]);
num_kd = length(kd_unique);
kd_colors = [ones(num_kd,1), linspace(0.8, 0, num_kd)', linspace(0.8, 0, num_kd)'];

% Plot for n=1 (moderate cooperativity)
n_target = 1;
for i = 1:length(kd_unique)
    kd_val = kd_unique(i);
    
    % Filter data for this n and Kd
    idx = ([results_table.n] == n_target) & ([results_table.Kd] == kd_val);
    alpha_vals = [results_table(idx).alpha];
    conv_rates = [results_table(idx).conversion_rate];
    
    % Sort by alpha for clean line
    [alpha_vals, sort_idx] = sort(alpha_vals);
    conv_rates = conv_rates(sort_idx);
    
    plot(alpha_vals, conv_rates, 'o-', 'Color', kd_colors(i,:), ...
         'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', kd_colors(i,:));
    legend_entries{end+1} = sprintf('K_d = %.1f', kd_val);
end

xlabel('control strength (\alpha)');
ylabel('success rate (%)');
xlim([0.5, 10.5]);
ylim([0, 100]);

%% 2: Hill coefficient effect
nexttile(2);
hold on;
legend_entries = {};
num_kd = length(kd_unique);
kd_colors_orange = [linspace(0.7, 0, num_kd)', linspace(0.9, 0.3, num_kd)', ones(num_kd,1)];

% Plot for alpha = 5 (moderate control strength)
alpha_target = 5;
for i = 1:length(kd_unique)
    kd_val = kd_unique(i);
    
    % Filter data for this alpha and Kd
    idx = ([results_table.alpha] == alpha_target) & ([results_table.Kd] == kd_val);
    n_vals = [results_table(idx).n];
    conv_rates = [results_table(idx).conversion_rate];
    
    % Sort by n for clean line
    [n_vals, sort_idx] = sort(n_vals);
    conv_rates = conv_rates(sort_idx);
    
    plot(n_vals, conv_rates, 's-', 'Color', kd_colors_orange(i,:), ...
        'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', kd_colors_orange(i,:));
    legend_entries{end+1} = sprintf('K_d = %.1f', kd_val);
end

ylabel('success rate (%)');
xlabel('hill co-efficient (n)');
xlim([0.5, 4.5]);
ylim([0, 100]);

%% 3: Heatmap visualization
nexttile(3, [1 2]);

% Find the n value that gives the highest conversion rate overall
[~, best_n_idx] = max([results_table(idx).conversion_rate]); % max(best_rates);
n_unique = unique([results_table.n]);
n_val = n_unique(best_n_idx);
idx = [results_table.n] == n_val;
filtered = results_table(idx);

alpha_grid = unique([filtered.alpha]);
kd_grid = unique([filtered.Kd]);
heat_data = nan(length(kd_grid), length(alpha_grid));

for i = 1:length(filtered)
    a_idx = find(alpha_grid == filtered(i).alpha);
    k_idx = find(kd_grid == filtered(i).Kd);
    heat_data(k_idx, a_idx) = filtered(i).conversion_rate;
end

hmap = heatmap(alpha_grid, kd_grid, heat_data, 'CellLabelColor', 'none');

% hmap.Colormap = viridis;
hmap.XLabel = '\alpha';
hmap.YLabel = 'K_d';
hmap.Title = sprintf('Parameter Map (n=%d)', n_val);


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

% Create textarrow
annotation(fig,'textarrow',[0.197916666666666 0.197916666666665],...
    [0.897916666666666 0.647916666666666],'LineWidth',1.5);

% Create textbox
annotation(fig,'textbox',...
    [0.809523809523807 0.0437499999999993 0.068452380952383 0.0541666666666666],...
    'String','Low',...
    'FontSize',13.2,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(fig,'textbox',...
    [0.51 0.62 0.12 0.05],...
    'String','for \alpha = 5',...
    'FontSize',12,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(fig,'textbox',...
    [0.158738095238092 0.5895833350718 0.113095234813435 0.0624999982615312],...
    'String','K_d = 1.5',...
    'Margin',1,...
    'FontSize',12,...
    'EdgeColor','none');

% Create textbox
annotation(fig,'textbox',...
    [0.155761904761903 0.875000001614285 0.107886901635322 0.0583333317190409],...
    'String','K_d = 0.2',...
    'Margin',1,...
    'FontSize',11.5,...
    'EdgeColor','none');

% Create textarrow
annotation(fig,'textarrow',[0.742559523809524 0.742559523809524],...
    [0.875 0.625],'LineWidth',1.5);

% Create textbox
annotation(fig,'textbox',...
    [0.700404761904758 0.575000001614289 0.107886901635322 0.0583333317190409],...
    'String','K_d = 1.5',...
    'Margin',1,...
    'FontSize',11.5,...
    'EdgeColor','none');

% Create textbox
annotation(fig,'textbox',...
    [0.70040476190476 0.852083334947617 0.107886901635322 0.0583333317190409],...
    'String','K_d = 0.2',...
    'Margin',1,...
    'FontSize',11.5,...
    'EdgeColor','none');

% Create textbox
annotation(fig,'textbox',...
    [0.803571428571426 0.474999999999999 0.068452380952383 0.0541666666666666],...
    'String','High',...
    'FontSize',13.2,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(fig,'textbox',...
    [0.29 0.722916666666666 0.102678571428572 0.0541666666666667],...
    'String','for n =1',...
    'FontSize',12,...
    'FitBoxToText','off',...
    'EdgeColor','none');


% print(fig, 'M1_sweep_figure', '-dsvg');



