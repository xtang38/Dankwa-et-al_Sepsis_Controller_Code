


close all
clear all
clc

load Fitted_Parameter.mat;

Origin_beta1 = par.beta1;

load Merged_local_sensitivity_results.mat;

Hvary = Fail_seed; %%% flipped
Unvary = Success_seed; %%% flipped


All_Simu_Health = cell(1,length(Success_Simu));
All_Simu_UnHealth = cell(1,length(Fail_Simu));

par.S2Ref = 0.5;
par.Kp = 100;

Patho = 20;
tspan = 0:0.01:8;
options = odeset('RelTol',1e-10,'AbsTol',1e-10);
x0 = [1 1 .8 .2 Patho 0 0];

for ij = 1:length(Hvary)
    par.beta1 = Origin_beta1*Hvary(ij);
    [t0,y0]=ode23s(@(t,x)Injury_Model_Final_Control(t,x,par),tspan,x0,options);
    All_Simu_Health{1,ij} = y0;
end

for ji = 1:length(Unvary)
    par.beta1 = Origin_beta1*Unvary(ji);
    [t1,y1]=ode23s(@(t,x)Injury_Model_Final_Control(t,x,par),tspan,x0,options);
    All_Simu_UnHealth{1,ji} = y1;
end

%%%%% All_Simu_Health is actually the unhealthy simulation; vise versa

%%% save('Controlled_Results.mat','All_Simu_UnHealth','All_Simu_Health')

