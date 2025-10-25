%% Combined Controller Analysis 
close all; clear; clc

%% ----------------- Load Experimental / Simulation Data -----------------
% Load septic parameters
load('Robust_GSA_Results.mat'); % Healed_Params and Septic_Params

num_cases = length(Septic_Params);
tspan = Healed_Params{1}.t;
floor_val = 1e-6;   % Avoid complex/log(0) issues
required = 2;       % Clearance threshold

% Initial conditions
data = load('peritonitis_data.mat').A;
exp_time = data(:, 1); % Hours column
exp_time_days = exp_time/24; % Convert to days
x0 = [data(1,3) 1 data(1,4) data(1,5) 20 0 0];
options = odeset('RelTol',1e-6,'AbsTol',1e-8);

%% ----------------- Define Controllers -----------------
controllers = {
    struct('name', 'M_1 cont.', 'var_idx', 3, 'var_name', 'M_1 mp.', 'cp', struct('n',1,'Kd',0.2,'alpha',10), 'ode', @m1_controlled_ode), 
    struct('name', 'M_2 cont.', 'var_idx', 4, 'var_name', 'M_2 mp.', 'cp', struct('n',1,'Kd',0.2,'alpha',1), 'ode', @m2_controlled_ode),
    struct('name', 'M_o cont.', 'var_idx', 2, 'var_name', 'M_o mo.',  'cp', struct('n',2,'Kd',0.2,'alpha',5), 'ode', @m0_controlled_ode),
    struct('name', 'P cont.',  'var_idx', 5, 'var_name', 'Pathogen', 'cp', struct('n',1,'Kd',0.2,'alpha',10), 'ode', @P_controlled_ode),
    struct('name', 'M_1+M_2', 'var_idx', [3,4], 'var_name', 'M_1 & M_2 mp.', 'cp', struct('n',2,'Kd',0.2,'alpha_M1',10,'alpha_M2',10), 'ode', @m1_m2_controlled_ode)
};

num_ctrl = numel(controllers);

%% ----------------- Run Simulations -----------------
all_outcomes = cell(num_ctrl,1);

for c_idx = 1:num_ctrl
    ctrl = controllers{c_idx};
    fprintf('Running %s controller (%d/%d)...\n', ctrl.name, c_idx, num_ctrl);
    
    healed_trajs = {};
    
    for i = 1:num_cases
        p = Septic_Params{i}.parameters;
        try
            [~, y] = ode15s(@(t,x) ctrl.ode(t,x,p,ctrl.cp), tspan, x0, options);
            
            final_pathogen = y(end,5);
            if final_pathogen < required
                healed_trajs{end+1} = y;
            end
            
        catch ME
            fprintf('Case %d failed: %s\n', i, ME.message);
        end
    end
    
    % Compute mean trajectory for healed cases
    healed_mean = [];
    if ~isempty(healed_trajs)
        healed_data = cat(3, healed_trajs{:});
        healed_mean = mean(healed_data,3);
    end
    
    % Store outcomes
    all_outcomes{c_idx} = struct(...
        'healed_trajs',{healed_trajs}, ...
        'healed_mean', healed_mean, ...
        'conversion_rate', 100*numel(healed_trajs)/num_cases);
end

%% ----------------- Original Septic Mean -----------------
original_trajs = cellfun(@(s) s.y, Septic_Params, 'UniformOutput', false);
original_data = cat(3, original_trajs{:});
original_mean = mean(original_data,3);

%% ----------------- Sort Controllers by Healing Rate -----------------
healing_rates = cellfun(@(x) x.conversion_rate, all_outcomes);
[sorted_rates, sort_idx] = sort(healing_rates, 'descend');
sorted_names = cellfun(@(c) c.name, controllers(sort_idx), 'UniformOutput', false);
sorted_indices = sort_idx;

%% ----------------- Define Colors -----------------
bar_colors = [
    0.10, 0.35, 0.22;  % GREEN - M1+M2
    0.87, 0.29, 0.48;  % PINK - M1
    0.40, 0.34, 0.74;  % PURPLE - P
    0.43, 0.28, 0.17;  % BROWN - M0
    0.15, 0.57, 0.70;  % BLUE - M2
];

edge_colors = [
    0.10, 0.35, 0.22;  % GREEN
    0.82, 0.26, 0.44;  % PINK
    0.25, 0.18, 0.67;  % PURPLE
    0.40, 0.21, 0.07;  % BROWN
    0.02, 0.41, 0.53;  % BLUE
];

% Define markers for each controller
marker_types = {'s', 'o', 'd', '^', 'v'}; % Different markers

%% ----------------- Create Figure -----------------
fig = figure(1); clf;
set(fig, ...
    'PaperUnits','inches', ...
    'PaperType','usletter', ...
    'PaperOrientation','portrait', ...
    'PaperPositionMode','manual', ...
    'PaperPosition',[1,1,7,5], ...
    'Units','inches', ...
    'Position',[1,1,7,5]);

tl = tiledlayout(2,2,'Padding','compact','TileSpacing','compact');

%% ----------------- LEFT PANEL: Pathogen Clearance -----------------
nexttile(tl, 1, [2,1]); hold on; box on;

% Plot original septic mean
orig_mean_pathogen = max(original_mean(:,5), floor_val);
h_orig = plot(tspan, orig_mean_pathogen,'k--','LineWidth',2.5,'DisplayName','original septic');

% Find indices for experimental time points
marker_idx = arrayfun(@(t) find(abs(tspan - t) == min(abs(tspan - t)), 1), exp_time_days);

controller_handles = [];
for i = 1:num_ctrl
    idx = sorted_indices(i);
    healed_mean = all_outcomes{idx}.healed_mean;
    if ~isempty(healed_mean)
        adj_healed = max(healed_mean(:,5), floor_val);
        
        % Plot with markers included in the main plot command for legend
        h = plot(tspan, adj_healed,'-','Color',bar_colors(i,:),...
            'LineWidth',2.5,'Marker',marker_types{i},'MarkerIndices',marker_idx,...
            'MarkerFaceColor',edge_colors(i,:),'MarkerEdgeColor',edge_colors(i,:),...
            'MarkerSize',5,'DisplayName',sorted_names{i});
        controller_handles = [controller_handles,h];
    end
end

set(gca,'YScale','log');
xlabel('time (days)' ,'FontSize', 15.4);
ylabel('log scale (a.u.)' ,'FontSize', 15.4);
ylim([1e-2, 1e200]); % Fixed unrealistic upper limit
legend([h_orig, controller_handles],'Location','best');

%% ----------------- TOP RIGHT: Healing Rate -----------------
nexttile; hold on; box on;

% Draw bars one by one
for i = 1:num_ctrl
    barh(i, sorted_rates(i), ...
        'FaceColor', bar_colors(i,:), ...
        'EdgeColor', edge_colors(i,:), ...
        'LineWidth', 1.5, ...
        'BarWidth', 0.9);
end

set(gca,'YTick',1:num_ctrl,'YTickLabel',sorted_names, 'FontSize', 15.4);
xlabel('Healing Rate (%)', 'FontSize', 15.4);
xlim([0 max(sorted_rates)*1.15]);

% Value labels
for i = 1:num_ctrl
    text(sorted_rates(i)+1, i, sprintf('%.1f%%', sorted_rates(i)),...
        'VerticalAlignment', 'middle',  'FontSize', 12);
end


%% ----------------- BOTTOM RIGHT: IL-6 Dynamics -----------------
nexttile; hold on; box on; 

% Plot original IL-6 first
il6_orig = original_mean(:,6); %/max(original_mean(:,6))
plot(tspan, il6_orig,'k--','LineWidth',2,'DisplayName','Dysregulated');

for i = 1:num_ctrl
    idx = sorted_indices(i);
    healed_mean = all_outcomes{idx}.healed_mean;
    if ~isempty(healed_mean)
        il6 = healed_mean(:,6);
        il6_norm = il6 / max(il6);
        plot(tspan, il6_norm,'-','Color',bar_colors(i,:),'LineWidth',2.5,'DisplayName',sorted_names{i});
    end
end

xlabel('time (days)');
ylabel('Normalized IL-6');
legend('Location','best');

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
fprintf('Publication-quality figure created!\n');
fprintf('Controllers ranked by healing rate:\n');
for i = 1:num_ctrl
    fprintf('  %s: %.1f%%\n', sorted_names{i}, sorted_rates(i));
end


%% ====================== ODE FUNCTIONS ======================
function dx = m1_controlled_ode(t, x, p, cp)
    N = x(1); M0 = x(2); M1 = x(3); M2 = x(4);
    P = x(5); IL6 = x(6); TGFb = x(7);

    function y = hill(Chem, n, k)
        y = Chem^n / (k^n + Chem^n);
    end

    function reg = smooth_effector(Species, k, slope)
        reg = 2 / (1 + exp(-slope * (Species - k))) - 1;
    end

    % Controlled M1 clearance
    controlled_clearance = p(13) * (1 + cp.alpha * hill(IL6, cp.n, cp.Kd));

    % Capacity constraint
    Cmax = 1000;
    Capacity = 1 - (N + M0 + M1 + M2) / Cmax;

    % Differential equations
    dx = zeros(7,1);
    dx(1) = p(2)*hill(P, p(4), p(5))*Capacity - p(10)*N*IL6 - p(11)*N;
    dx(2) = p(10)*N*IL6 - p(7)*M0 - p(12)*M0;
    dx(3) = p(7)*M0 - p(8)*M1*TGFb - controlled_clearance * M1;
    dx(4) = p(8)*M1*TGFb - p(14)*M2;
    reg = smooth_effector(M1, p(1), p(19));
    dx(5) = p(3)*M1*P*reg  - p(9)*N*P - p(18)*P;
    dx(6) = p(15)*N - p(16)*IL6;
    dx(7) = p(16)*M1*N - p(17)*TGFb;
end

function dx = m2_controlled_ode(t, x, p, cp)
    N = x(1); M0 = x(2); M1 = x(3); M2 = x(4);
    P = x(5); IL6 = x(6); TGFb = x(7);

    function y = hill(Chem, n, k)
        y = Chem^n / (k^n + Chem^n);
    end

    function reg = smooth_effector(Species, k, slope)
        reg = 2 / (1 + exp(-slope * (Species - k))) - 1;
    end

    % Capacity constraint
    Cmax = 1000;
    Capacity = 1 - (N + M1 + M2 + M0) / Cmax;

    % IL6 control
    hill_term = hill(IL6, cp.n, cp.Kd);
    controlled_rate = p(8) * (1 + cp.alpha * hill_term);

    % Differential equations
    dx = zeros(7,1);
    dx(1) = p(2)*hill(P, p(4), p(5))*Capacity - p(10)*N*IL6 - p(11)*N;
    dx(2) = p(10)*N*IL6 - p(7)*M0 - p(12)*M0;
    dx(3) = p(7)*M0 - p(8)*M1*TGFb - p(13)*M1;
    dx(4) = controlled_rate*M1*TGFb - p(14)*M2;
    reg = smooth_effector(M1, p(1), p(19));
    dx(5) = p(3)*M1*P*reg - p(9)*N*P - p(18)*P;
    dx(6) = p(15)*N - p(16)*IL6;
    dx(7) = p(16)*M1*N - p(17)*TGFb;
end

function dx = P_controlled_ode(t, x, p, cp)
    N = x(1); M0 = x(2); M1 = x(3); M2 = x(4);
    P = x(5); IL6 = x(6); TGFb = x(7);

    function y = hill(Chem, n, k)
        y = Chem^n / (k^n + Chem^n);
    end

    function reg = smooth_effector(Species, k, slope)
        reg = 2 / (1 + exp(-slope * (Species - k))) - 1;
    end

    % Capacity constraint
    Cmax = 1000;
    Capacity = 1 - (N + M1 + M2 + M0) / Cmax;

    % IL6 control
    hill_term = hill(IL6, cp.n, cp.Kd);
    controlled_rate = p(18) * (1 + cp.alpha * hill_term);

    % Differential equations
    dx = zeros(7,1);
    dx(1) = p(2)*hill(P, p(4), p(5))*Capacity - p(10)*N*IL6 - p(11)*N;
    dx(2) = p(10)*N*IL6 - p(7)*M0 - p(12)*M0;
    dx(3) = p(7)*M0 - p(8)*M1*TGFb - p(13)*M1;
    dx(4) = p(8)*M1*TGFb - p(14)*M2;
    reg = smooth_effector(M1, p(1), p(19));
    dx(5) = p(3)*M1*P*reg - p(9)*N*P - controlled_rate*P;
    dx(6) = p(15)*N - p(16)*IL6;
    dx(7) = p(16)*M1*N - p(17)*TGFb;
end

function dx = m0_controlled_ode(t, x, p, cp)
    N = x(1); M0 = x(2); M1 = x(3); M2 = x(4);
    P = x(5); IL6 = x(6); TGFb = x(7);

    function y = hill(Chem, n, k)
        y = Chem^n / (k^n + Chem^n);
    end

    function reg = smooth_effector(Species, k, slope)
        reg = 2 / (1 + exp(-slope * (Species - k))) - 1;
    end

    % Capacity constraint
    Cmax = 1000;
    Capacity = 1 - (N + M1 + M2 + M0) / Cmax;

    % IL6 control
    hill_term = hill(IL6, cp.n, cp.Kd);
    controlled_rate = p(12) * (1 + cp.alpha * hill_term);

    % Differential equations
    dx = zeros(7,1);
    dx(1) = p(2)*hill(P, p(4), p(5))*Capacity - p(10)*N*IL6 - p(11)*N;
    dx(2) = p(10)*N*IL6 - p(7)*M0 - controlled_rate*M0;
    dx(3) = p(7)*M0 - p(8)*M1*TGFb - p(13)*M1;
    dx(4) = p(8)*M1*TGFb - p(14)*M2;
    reg = smooth_effector(M1, p(1), p(19));
    dx(5) = p(3)*M1*P*reg - p(9)*N*P - p(18)*P;
    dx(6) = p(15)*N - p(16)*IL6;
    dx(7) = p(16)*M1*N - p(17)*TGFb;
end

function dx = m1_m2_controlled_ode(t, x, p, cp)
    N = x(1); M0 = x(2); M1 = x(3); M2 = x(4);
    P = x(5); IL6 = x(6); TGFb = x(7);

    function y = hill(Chem, n, k)
        y = Chem^n / (k^n + Chem^n);
    end

    function reg = smooth_effector(Species, k, slope)
        reg = 2 / (1 + exp(-slope * (Species - k))) - 1;
    end

    % Controlled M1 clearance
    controlled_M1_clearance = p(13) * (1 + cp.alpha_M1 * hill(IL6, cp.n, cp.Kd));
    controlled_M2_conversion = p(8) * (1 + cp.alpha_M2 * hill(IL6, cp.n, cp.Kd));

    % Capacity constraint
    Cmax = 1000;
    Capacity = 1 - (N + M0 + M1 + M2) / Cmax;

    % Differential equations
    dx = zeros(7,1);
    dx(1) = p(2)*hill(P, p(4), p(5))*Capacity - p(10)*N*IL6 - p(11)*N;
    dx(2) = p(10)*N*IL6 - p(7)*M0 - p(12)*M0;
    dx(3) = p(7)*M0 - controlled_M2_conversion*M1*TGFb - controlled_M1_clearance * M1;
    dx(4) = controlled_M2_conversion*M1*TGFb - p(14)*M2;
    reg = smooth_effector(M1, p(1), p(19));
    dx(5) = p(3)*M1*P*reg  - p(9)*N*P - p(18)*P;
    dx(6) = p(15)*N - p(16)*IL6;
    dx(7) = p(16)*M1*N - p(17)*TGFb;
end