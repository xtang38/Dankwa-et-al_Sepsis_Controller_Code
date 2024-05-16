

%%%%%% single simulation simplied model.
close all
clear all
clc

load OptParameter_Nov2nd.mat;

par.threshold = p(1);
par.alpha1 = p(2); %%40000*0.05;  %%% Neutrophil
par.alpha3= p(4); %%% Pathogen
par.n1 = p(5); %%% Neutrophil
par.K1 = p(8); %%% neutrophil
par.gamma1 = p(12); % bound 0.1-1000 %%% induced apoptosis of N via M1 = 0.997407471438622;
par.gamma2 = p(13); % bound 0.1 - 100 %%% differentiation rate from M0 to M1 
par.gamma3 = p(14); % bound 0.1 - 100 %%% differentiation rate from M1 to M2 =  8.61724199879709;
par.gamma5 = p(16); % bound 0.1 - 5 %%% destruction rate of P via N
par.gamma6 = p(17); %0.02; % bound of 0.01 - 5 %%% activation rate of M0 via N
par.mu1 = p(19);  %% N, 8*0.05
par.mu2 = p(20);  %%% M0, 8*0.05
par.mu3 = p(21);  %%% M1, 8*0.05
par.mu4 = p(22);  %%% M2, 8*0.05
par.beta1= p(24); %%% production of S2
par.delta1 = p(26); %%% S2 deg
par.delta2 = p(27); %%% S6 deg
par.delta8 = p(29); %%% injury deg

Name = fieldnames(par);
vary= 0.01:0.1:1;
ramp = linspace(0, 0.75 , length(vary));
Col = [ramp; ramp ; ramp]';
All_Results = cell(1,length(vary));
All_Simu = cell(1,length(vary));


Patho = 20;
tspan = 0:0.01:8;
options = odeset('RelTol',1e-10,'AbsTol',1e-10);
x0 = [1 1 .8 .2 Patho 0 0];


failed = 0;

npar = par;
for ij = 1:length(vary)
    npar.beta1 = par.beta1*vary(ij);
    [t,y]=ode23s(@(t,x)Injury_Model_New_para(t,x,npar),tspan,x0,options);
    
    All_point = find(y(:,6) >= y(end,6)*0.95); %%% find all the first time enters to 95% of the final value mFb.
    if isempty(All_point) == 0 
        steadystate = All_point(1);
        [concentration,location]= max(y);
        All_Results{1,ij}(1,:) = concentration;
        All_Results{1,ij}(2,:) = t(location);
        All_Results{1,ij}(3,1) = 0.95*y(end,6);
        All_Results{1,ij}(4,1) = t(steadystate);
        All_Results{1,ij}(5,:) = y(end,:);  
        All_Simu{1,ij} = y;
    else
        failed = failed + 1;  %%% count how many simulations failed.
    end


end


