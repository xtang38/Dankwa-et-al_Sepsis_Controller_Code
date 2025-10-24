%% Sepsis Model ODE System
function dx = ODEModel(t, x, p)
    dx = zeros(7, 1);
    
    % State variables
    N = x(1);     % Neutrophil
    M0 = x(2);    % Monocyte
    M1 = x(3);    % M1 macrophage
    M2 = x(4);    % M2 macrophage
    Pathogen = x(5);     % Pathogen
    IL6 = x(6);        % Signal 2 (IL-6)
    TGFbeta = x(7);    % Signal 6 (TGF-beta)
    
    % Capacity constraint
    Cmax = 1000;
    Capacity = 1 - (N + M1 + M2 + M0) / Cmax;
    
    % Helper functions
    function y = hill(Chemical, n, k)
        y = Chemical^n / (k^n + Chemical^n);
    end
    
    function reg = smooth_effector(Species, k, slope)
        reg = 2/ (1 + exp(-slope * (Species - k))) - 1;
    end

    
    % ODE system
    dx(1) = p(2)*hill(Pathogen,p(4),p(5))*Capacity - p(10)*N*IL6 - p(11)*N ; %%%N
    dx(2) = p(10)*N*IL6 - p(7)*M0 - p(12)*M0; %% M0
    dx(3) = p(7)*M0 - p(8)*M1*TGFbeta - p(13)*M1;  %% M1
    dx(4) = p(8)*M1*TGFbeta - p(14)*M2;  %% M2
    reg = smooth_effector(M1, p(1), p(19));  % p(19) = slope for effector
    dx(5) = p(3)*M1*Pathogen*reg - p(9)*N*Pathogen - p(18)*Pathogen; %%% Pathogen
    dx(6) = p(15)*N - p(16)*IL6;         %%% IL6
    dx(7) = p(16)*M1*N - p(17)*TGFbeta;  %%% TGF-beta
end
