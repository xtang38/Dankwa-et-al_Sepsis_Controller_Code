function objective = objective_function(p)


Exp = load('Exp_Data.mat').A;


Patho = 20;

tspan = 0:0.01:8;
options = odeset('RelTol',1e-10,'AbsTol',1e-10);
x0 = [1 1 .8 .2 .01 .01 Patho 0 0 0];
[t,y]=ode23s(@(t,x)Injury_Model_New(t,x,p),tspan,x0,options);


Neutrophil = y(:,1);
M1 = y(:,3);
M2 = y(:,4);

Error_N = (Exp(1,3) - Neutrophil(67))^2 + (Exp(2,3) - Neutrophil(84))^2+...
         (Exp(3,3) - Neutrophil(101))^2 + (Exp(4,3) - Neutrophil(108))^2+...
         (Exp(5,3) - Neutrophil(201))^2 + (Exp(6,3) - Neutrophil(301))^2+...
         (Exp(7,3) - Neutrophil(401))^2 + (Exp(8,3) - Neutrophil(501))^2+...
         (Exp(9,3) - Neutrophil(601))^2 + (Exp(10,3) - Neutrophil(701))^2;

Error_M1 = (Exp(1,4) - M1(67))^2 + (Exp(2,4) - M1(84))^2+...
         (Exp(3,4) - M1(101))^2 + (Exp(4,4) - M1(108))^2+...
         (Exp(5,4) - M1(201))^2 + (Exp(6,4) - M1(301))^2+...
         (Exp(7,4) - M1(401))^2 + (Exp(8,4) - M1(501))^2+...
         (Exp(9,4) - M1(601))^2 + (Exp(10,4) - M1(701))^2;

Error_M2 = (Exp(1,5) - M2(67))^2 + (Exp(2,5) - M2(84))^2+...
         (Exp(3,5) - M2(101))^2 + (Exp(4,5) - M2(108))^2+...
         (Exp(5,5) - M2(201))^2 + (Exp(6,5) - M2(301))^2+...
         (Exp(7,5) - M2(401))^2 + (Exp(8,5) - M2(501))^2+...
         (Exp(9,5) - M2(601))^2 + (Exp(10,5) - M2(701))^2;


objective = Error_M2 + Error_M1 + Error_N;

disp(['SSE Objective: ' num2str(objective)])
%disp(['Updated Parameter: ' num2str(objective)])
%disp(p)
save('OptParameter_Nov2nd.mat','p')



end
