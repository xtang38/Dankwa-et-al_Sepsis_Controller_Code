function dx = Injury_Model_New(t,x,p)

dx = zeros(10,1);


N = x(1); %%% Neutrohpil

M0 = x(2); %%% Monocyte

M1 = x(3); %%% M1

M2 = x(4); %%% M2

Fb = x(5); %%% Fibroblast

mFb = x(6); %%% Myofibroblast
 
Injury = x(7); %%% Injury 

S2 = x(8); 

S6 = x(9); 

S8 = x(10);  

Cmax = 1000;
Capacity = 1-(N+M1+M2+M0+Fb+mFb)/Cmax;

function y = act(Chemical,n,k)
y = Chemical^n/(k^n+Chemical^n);
end

function injury_reg = regulation(Species,Threshold)
    if Species >= Threshold
        injury_reg = 1;
    else
        injury_reg = -1;
    end
end


%%% Production of cells
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
for ij = 1:length(Name)
    par.(Name{ij}) = p(ij);
end



%%% ODE equations
dx(1) = N*par.alpha1*act(Injury,par.n1,par.K1)*Capacity - par.gamma1*N*S2 - par.mu1*N ; %%%N
%% reduced the deg term of N from [- par.gamma1*N*M1 - par.gamma6*N*S2 - par.mu1*N ] to [- par.gamma1*N*S2 - par.mu1*N ]
dx(2) = par.gamma6*N*S2 - par.gamma2*M0 - M0*par.mu2; %% M0
   
dx(3) = par.gamma2*M0 - par.gamma3*M1*S6 - M1*par.mu3;  %% M1

dx(4) = par.gamma3*M1*S6 - M2*par.mu4;  %% M2

dx(5) = Fb*par.alpha2*act(S8,par.n2,par.K2)*Capacity - par.gamma4*Fb;%%%- Fb*par.mu5;  %%% Fb %%no degradtion
 
dx(6) = par.gamma4*Fb;  %%% mFb %%% no degrdation

dx(7) = par.alpha3*M1*Injury*regulation(M1,par.threshold) - par.gamma5*N*Injury - par.delta8*Injury; %%% injury %%%no degrdation rate

dx(8) = par.beta1*N - par.delta1*S2;  %%% S2

dx(9) = par.gamma1*M1*N - par.delta2*S6;  %%% S6 

dx(10) = par.beta2*M2 - par.delta3*S8;  %%% S8

end
