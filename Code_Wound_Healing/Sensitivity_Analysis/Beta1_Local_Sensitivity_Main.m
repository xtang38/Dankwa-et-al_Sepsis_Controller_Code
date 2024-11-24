
%%%%%% single simulation simplied model.
close all
clear all
clc


load Fitted_Parameter.mat;

Name = fieldnames(par);

All_Results = cell(1,100);
All_Simu = cell(1,100);


Patho = 20;
tspan = 0:0.01:8;

options = odeset('RelTol',1e-4,'AbsTol',1e-6);

x0 = [1 1 .8 .2 Patho 0 0];


failed = 0;
success = 0;
seed = zeros(100,1);

npar = par;
while success < 100
    vary_factor = rand(1)*10; %%% higher than 1 change this for lower than 1
   
    npar.beta1 = par.beta1*vary_factor;
     [t,y]=ode23s(@(t,x)Injury_Model_New_para(t,x,npar),tspan,x0,options);
    
    All_point = find(y(:,6) >= y(end,6)*0.95); %%% find all the first time enters to 95% of the final value mFb.
    if isempty(All_point) == 0 
        steadystate = All_point(1);
        [concentration,location]= max(y);
        success = success + 1;
        ij = success;
        All_Results{1,ij}(1,:) = concentration;
        All_Results{1,ij}(2,:) = t(location);
        All_Results{1,ij}(3,1) = 0.95*y(end,6);
        All_Results{1,ij}(4,1) = t(steadystate);
        All_Results{1,ij}(5,:) = y(end,:);  
        All_Simu{1,ij} = y;
        
        seed(success,1) = vary_factor;
    else
        failed = failed + 1;  %%% count how many simulations failed.
    end


end



% % save('Beta1_Local_Sens_Analysis_Sep19_2024_High.mat','All_Results','failed','All_Simu','success','seed')