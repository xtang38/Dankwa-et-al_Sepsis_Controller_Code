clear all
close all
clc

load OptParameter_Nov2nd.mat;  %%% this contains the optimized parameters

%%% defining the parameters
par.threshold = 0.05;
par.alpha1 = 0.5*10; %%40000*0.05;  %%% Neutrophil
par.alpha2 = 2*1.75;  %%%% Fb activation
par.alpha3= 7; %%% Pathogen
%%% hill function coeficients
par.n1 = 1; %%% Neutrophil
par.n2 = 1; %%% Fb 
par.n3 = 1; %%% Injury
par.K1 = 200; %%% neutrophil
par.K2 = 200/10000; %Fb
par.K3 = 200; %%% Injury
par.K4 = 1e-10; %%%  S2
%%%% cell differentiation rates
par.gamma1 = 7; % bound 0.1-1000 %%% induced apoptosis of N via M1 = 0.997407471438622;
par.gamma2 = 5; % bound 0.1 - 100 %%% differentiation rate from M0 to M1 
par.gamma3 = 8.281/5; % bound 0.1 - 100 %%% differentiation rate from M1 to M2 =  8.61724199879709;
par.gamma4 = 2.7; % bound 0.1 - 100 %%% differentiation rate from Fb to mFb
par.gamma5 = 0.3*10; % bound 0.1 - 5 %%% destruction rate of P via N
par.gamma6 = .02*100; %0.02; % bound of 0.01 - 5 %%% activation rate of M0 via N
par.gamma7 = 6; % bound 0.1 - 10 %%% destruction rate P via M1
%%%% cell removal rate
par.mu1 = 4/10;  %% N, 8*0.05
par.mu2 = 5.2/10;  %%% M0, 8*0.05
par.mu3 = 7/10;  %%% M1, 8*0.05
par.mu4 = 8.2/2;  %%% M2, 8*0.05
par.mu5 = 1;  %%% Fb, 8*0.05
%%%%%  chemical production rate
par.beta1= 10*0.05; %%% production of S2
par.beta2 = 120*0.05; %%% Production of S8
%%%%%  the chemical degradation rate 
par.delta1 = 12*0.05; %%% S2 deg
par.delta2 = 12*0.05; %%% S6 deg
par.delta3 = 12*0.05; %%% S8 deg
par.delta8 = 10*0.05; %%% injury deg


Name = fieldnames(par);
for i = 1:length(Name)
    par.(Name{i}) = p(i); %%%%%% This line is to assign the parameter values to the fitted ones.
end

vary= [0.001 0.01 0.1 1 10];
ramp = linspace(0, 0.75 , length(vary));
Col = [ramp; ramp ; ramp]';
Nparameters = length(Name);
All_Results = cell(Nparameters,length(vary));

Patho = 20;
tspan = 0:0.01:8;
options = odeset('RelTol',1e-10,'AbsTol',1e-10);
x0 = [1 1 .8 .3 .01 .01 Patho 0 0 0];


failed = 0;

for iter = 1:Nparameters
    npar = par;
    for ij = 1:length(vary)
        npar.(Name{iter}) = p(iter)*vary(ij);
        [t,y]=ode23s(@(t,x)Injury_Model_New_para(t,x,npar),tspan,x0,options);

        All_point = find(y(:,6) >= y(end,6)*0.95); %%% find all the first time enters to 95% of the final value mFb.
        if isempty(All_point) == 0 
            steadystate = All_point(1);
            [concentration,location]= max(y);
            All_Results{iter,ij}(1,:) = concentration;
            All_Results{iter,ij}(2,:) = t(location);
            All_Results{iter,ij}(3,1) = 0.95*y(end,6);
            All_Results{iter,ij}(4,1) = t(steadystate);
            All_Results{iter,ij}(5,:) = y(end,:);  
        else
            failed = failed + 1;  %%% count how many simulations failed.
        end


    end
end

