%% ==================== Figure5 ROBUSTNESS ANALYSIS FIGURE ====================
clc; clear; close all;

fig = figure(1); clf;

set(fig, ...
    'PaperUnits', 'inches', ...
    'PaperType', 'usletter', ...           % MATLAB Built-in
    'PaperOrientation', 'portrait', ...    % or 'landscape'
    'PaperPositionMode', 'manual', ...     % by default it is also manual
    'PaperPosition', [0.75, 1, 7, 9.167], ...  %[distance_from_left distance_from_bottom width height] %default is [0.25 2.5 8.0 6.0]
    'Units', 'inches', ...
    'Position', [1, 1, 7, 5]);             % On-screen size matches print size
    %'PaperSize', [7, 5], ...              % Width x Height in PaperUnits(for custom dim)


% Create main layout with proper spacing
main_layout = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

% Define disturbance rejection colormap 
rgb_disturbance = [
    31, 19, 45;
    59, 26, 65;
    88, 30, 79;
    121, 31, 89;
    182, 23, 87;
    237, 76, 68;
    241, 102, 71;
    244, 133, 93;
    246, 154, 113;
    245, 157, 97;
    248, 221, 202
] / 255;

% Smooth colormap interpolation
xOriginal = linspace(0, 1, size(rgb_disturbance,1));
xInterp = linspace(0, 1, 256);
rInterp = interp1(xOriginal, rgb_disturbance(:,1), xInterp, 'pchip');
gInterp = interp1(xOriginal, rgb_disturbance(:,2), xInterp, 'pchip');
bInterp = interp1(xOriginal, rgb_disturbance(:,3), xInterp, 'pchip');
cmap_disturbance = [rInterp', gInterp', bInterp'];

%% ==================== PANEL A: PARAMETER UNCERTAINTY ====================
% Healing fraction distribution
load('Robustness_Results_Final.mat');
nexttile([2 1]);
% Data setup
edges = linspace(0, 1, 11); % 10 bins from 0 to 1
[N, bin_edges] = histcounts(param_healed_fractions, edges);
bin_centers = bin_edges(1:end-1) + diff(bin_edges)/2;

% Plot setup
hold on;
bar_handle = bar(bin_centers, N, ...
    'FaceColor', [0, 0.53, 0.53], ... 
    'EdgeColor', [0.10, 0.07, 0.07], ...
    'BarWidth', 1.0, ...
    'FaceAlpha', 0.8 ...
     ); 
set(bar_handle, 'LineWidth', 1.5);  % Adjust value as needed

% Labels and styling
ylabel('histogram distribution')
xlim([-0.02,1.02])
ylim([0,30])

xlabel('success rate (%)');
% (0 = Never worked, 1 = Always worked)

% Format the text box content
txt_str = {
    sprintf('original success rate: \\rm%.0f%%', conversion_rate), ...
    sprintf('success rate under variations: \\rm%.0f%%', param_mean_healed*100)
};


% Add textbox annotation
annotation('textbox', [0.078,0.85,0.22,0.08], ... % [x y w h] in normalized figure units%0.04 0.86 0.13 0.05
    'String', txt_str, ...
    'HorizontalAlignment','left', ...
    'VerticalAlignment','top',...
    'FitBoxToText', 'on', ...
    'BackgroundColor', 'none', ... %[1 1 1 0.8]
    'EdgeColor', 'none', ... %'k'
    'FontSize', 13, ...
    'Interpreter', 'tex');

%% ==================== PANEL B: PARAMETER SENSITIVITY ====================
% Parameter sensitivity analysis
nexttile;
bar_data = performance_by_range';

bar_colors = [
    0.10, 0.35, 0.22;  % GREEN
    0.87, 0.29, 0.48;  % PINK
    0.40, 0.34, 0.74;  % PURPLE
    0.43, 0.28, 0.17;  % BROWN
    0.15, 0.57, 0.70;  % BLUE
    0.84, 0.37, 0.37;  % SALMON
];

edge_colors = [
    0.10, 0.35, 0.22;  % GREEN
    0.82, 0.26, 0.44;  % PINK
    0.25, 0.18, 0.67;  % PURPLE
    0.40, 0.21, 0.07;  % BROWN
    0.02, 0.41, 0.53;  % BLUE
    0.79, 0.24, 0.24;  % SALMON
];

b = bar(bar_data, 'grouped');
disp(length(b));  % to see how many bar series
for i = 1:length(b)
    b(i).FaceColor = bar_colors(i,:);
    b(i).EdgeColor = edge_colors(i,:);
    b(i).FaceAlpha = 0.9;
    b(i).EdgeAlpha = 1.0;
    b(i).LineWidth = 2.0;
    b(i).BarWidth  = 1.0;
end

% set(gca, 'XTickLabel', range_categories);
range_categories = {
    'Low',... %(0.5–0.8)
    'Nominal',... %(0.8–1.2)
    'High'%(1.2–2.0)
};

set(gca, ...
    'XTick', 1:3, ...
    'XTickLabel', range_categories, ...
    'TickLabelInterpreter', 'tex');

% set(gca, 'XTickLabel', range_categories, 'TickLabelInterpreter', 'tex');
% xlabel('Parameter Range');
yline(0.85, '--k', 'LineWidth', 1.5);
ylabel('success rate (%)');
set(gca, 'Box', 'on');
ylim([0 1])
param_symbols = {'\mu_3','\gamma_3','\mu_4','\beta_1','\delta_1','\delta_3'};
legend(param_symbols, 'Location', 'best');


%% ==================== PANEL C: DISTURBANCE REJECTION ====================
nexttile;
load('disturbance_results.mat');

% Create contour plot with your preferred colormap
[X, Y] = meshgrid(disturbance_times, disturbance_magnitudes*100);
[C, h] = contourf(X, Y, mean_clearance', 20, 'LineStyle', 'none');

% Apply the disturbance colormap
colormap(gca, flipud(cmap_disturbance));
c = colorbar;
c.Label.String = 'mean clearance(days)';


% Add contour lines for better readability
hold on;
contour(X, Y, mean_clearance', [2, 4, 6, 8]);

xlabel('secondary onset time (days)');
ylabel('magnitude (% initial)');
% title('C');%(C) Disturbance Rejection
set(gca,'Box', 'on')
clim([0 8]);


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
