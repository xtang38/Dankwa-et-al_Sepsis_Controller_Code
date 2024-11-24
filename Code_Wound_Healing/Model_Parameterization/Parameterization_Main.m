clear all
close all
clc


%%%%%

%%% par.Cmax = 1000; %%%% total number of cell; fixed, not to optimize
%%% Production of cells
par.threshold = 0.05;
par.alpha1 = 0.5*10; %%40000*0.05;  %%% Neutrophil
par.alpha3= 7; %%% Pathogen
%%% hill function coeficients
par.n1 = 1; %%% Neutrophil

par.K1 = 200; %%% neutrophil

%%%% cell differentiation rates
par.gamma1 = 7; % bound 0.1-1000 %%% induced apoptosis of N via M1 = 0.997407471438622;
par.gamma2 = 5; % bound 0.1 - 100 %%% differentiation rate from M0 to M1 
par.gamma3 = 8.281/5; % bound 0.1 - 100 %%% differentiation rate from M1 to M2 =  8.61724199879709;
par.gamma5 = 0.3*10; % bound 0.1 - 5 %%% destruction rate of P via N
par.gamma6 = .02*100; %0.02; % bound of 0.01 - 5 %%% activation rate of M0 via N
%%%% cell removal rate
par.mu1 = 0.4;  %% N
par.mu2 = 0.52;  %%%I M0
par.mu3 = 0.7;  %%% M1
par.mu4 = 4.1;  %%% M2
par.beta1= 10*0.05; %%% production of S2
par.delta1 = 12*0.05; %%% S2 deg
par.delta2 = 12*0.05; %%% S6 deg
par.delta8 = 10*0.05; %%% injury deg


Name = fieldnames(par);
lb = zeros(1,length(Name));
ub = zeros(1,length(Name));
p0 = zeros(1,length(Name));

for ij = 1:length(Name)
    p0(ij) = par.(Name{ij});
    lb(1,ij) = p0(ij)*0.01;
    ub(1,ij) = p0(ij)*100;
end

A = [];
b = [];
Aeq = [];
beq = [];
nlcon = [];

options = optimset('OutputFcn',@my_output_function);
[parameter,fval] = fmincon(@objective_function,p0,A,b,Aeq,beq,lb,ub,nlcon);


