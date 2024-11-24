This folder includes MATLAB codes for the Dankwa et al Wound Healing Regulation paper. 
The following sets of files are included:
1. Model_Parameterization: this folder contains the experimental data retreaved from previously published work, names as "Exp_data.mat";
   the wound healing model developed in this study, named as "Injury_Model_Final_Fitting.m" (used for parameterization);
   the obejctive function of the parameterization, named as "objective_function.m";
   and the main parameterization script, named as "Parameterization_Main.m".
2. Sensitivity_Analysis: this folder contains the scripts for the local sensitivity analysis presented in the study. Specifically, it contains:
   the optimized set of parameters from model parameterization, named as "Fitted_Parameter.mat";
   the main local sensitivity analysis file for all the parameters, named as "Local_Sensitivity_Main.m";
   and the local sensitivity analysis script for parameter beta1 specifically, named as "Beta1_Local_Sensitivity_Main.m".
3. Controller: this folder contains the proposed biological controller scripts, and the simulation scripts to generate the controlled results. Specifically, it contains:
   the wound healing model that is modified with the controller, named as "Injury_Model_Final_Control.m";
   the main script to conduct the controlled simulations for the wound healing process, named as "Control_Simulation_Main.m";
   the controlled results, named as "Controlled_Results.mat";
   and the script used to generate the plots, named as "Con_Uncon_Statistical_Plot_Main".
