

%%%%%% single simulation simplied model.
close all
clear all
clc


load Fitted_Parameter.mat;

Name = fieldnames(par);
vary= [0.001 0.01 0.1 1 10];
ramp = linspace(0, 0.75 , length(vary));
Col = [ramp; ramp ; ramp]';
All_Results = cell(length(Name),length(vary));
All_Simu = cell(length(Name),length(vary));


Patho = 20;
tspan = 0:0.01:8;
options = odeset('RelTol',1e-10,'AbsTol',1e-10);
x0 = [1 1 .8 .2 Patho 0 0];


failed = 0;

for iter = 1:length(Name)
    npar = par;
    for ij = 1:length(vary)
        npar.(Name{iter}) = par.(Name{iter})*vary(ij);
        [t,y]=ode23s(@(t,x)Injury_Model_Final(t,x,npar),tspan,x0,options);

        All_point = find(y(:,6) >= y(end,6)*0.95); %%% find all the first time enters to 95% of the final value mFb.
        if isempty(All_point) == 0 
            steadystate = All_point(1);
            [concentration,location]= max(y);
            All_Results{iter,ij}(1,:) = concentration;
            All_Results{iter,ij}(2,:) = t(location);
            All_Results{iter,ij}(3,1) = 0.95*y(end,6);
            All_Results{iter,ij}(4,1) = t(steadystate);
            All_Results{iter,ij}(5,:) = y(end,:);  
            All_Simu{iter,ij} = y;
        else
            failed = failed + 1;  %%% count how many simulations failed.
        end


    end
end


% % % save('Local_Sens_Analysis_Nov18th.mat','All_Results','failed','All_Simu')

