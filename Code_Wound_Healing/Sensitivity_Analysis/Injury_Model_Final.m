function dx = Injury_Model_Final(t,x,par)

dx = zeros(7,1);


N = x(1); %%% Neutrohpil

M0 = x(2); %%% Monocyte

M1 = x(3); %%% M1

M2 = x(4); %%% M2
 
Pathogen = x(5); %%% Pathogen 

IL6 = x(6); 

TGF_beta = x(7); 

Cmax = 1000;
Capacity = 1-(N+M1+M2+M0)/Cmax;

function y = act(Chemical,n,k)
y = Chemical^n/(k^n+Chemical^n);
end

    function Pathogen_reg = regulation(Species,Threshold)
    if Species >= Threshold
        Pathogen_reg = 1;
    else
        Pathogen_reg = -1;
    end
end



%%% ODE equations
dx(1) = N*par.alpha1*act(Pathogen,par.n1,par.K1)*Capacity - par.gamma1*N*IL6 - par.mu1*N ; %%%N

dx(2) = par.gamma6*N*IL6 - par.gamma2*M0 - M0*par.mu2; %% M0
   
dx(3) = par.gamma2*M0 - par.gamma3*M1*TGF_beta - M1*par.mu3;  %% M1

dx(4) = par.gamma3*M1*TGF_beta - M2*par.mu4;  %% M2

dx(5) = par.alpha3*M1*Pathogen*regulation(M1,par.threshold) - par.gamma5*N*Pathogen - par.delta8*Pathogen; %%% Pathogen %%%no degrdation rate

dx(6) = par.beta1*N - par.delta1*IL6;  %%% IL6

dx(7) = par.gamma1*M1*N - par.delta2*TGF_beta;  %%% TGF_beta 


end
