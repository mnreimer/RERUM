%% Policy Numerical Simulations
% * Filename: policy_simulations.m
% * Authors: Matt Reimer
% * Created: 10/17/19
% * Updated: 11/04/19
%
%% Description
% The script |policy_simulations| is the parent script for generating 
% policy simulations for bycatch TAC reductions and hot-spot closures.
%
%% Notes
% * This script generates numerical simulations of policies for the true
% model, and if desired, using the parameter estimates of other models
% (i.e., for out-of-sample polciy predictions). The parameter estimates
% must already exist---this script will load previously estimated
% parameters.
%
%% PRELIMINARIES
 % Environment
  clc, clear
  close all
  directory = 'Documents/GitHub/RERUM';
  cd(homedir)
  cd(directory)
  addpath(genpath(pwd))
  
 % Default parameters 
  par = parameters;
  
 % Generate or load data (no, yes)?
  gen = 'no';
  
 % Use parameter estimates from previous estimation?
  est = 'yes';
  file = 'data\estimates scenarios 1-500 01-Nov-2019.mat';
  scenarios = {'SRUM','SRUM1','SRUM2','ARUM1','ARUM2','RERUM'};
  
 % Cloud computing (cloud or local)?
  parallel = 'cloud';
 
%% Simulation Data
switch gen
    % Generate simulations
    case 'yes'
  
     % Closure Scenarios (include zero for baseline)
     closed = 0:5:75;                   % Closures (% of area)
  
     % TAC Scenarios (include zero for baseline)
     tac_pol = 0:5:75;                   % TAC reduction (% of baseline)
     
     % Number (and start) of draws from dgp
     draws = 200;
     start = 0;
     
     % Using parameter estimates
     switch est
         case 'yes'
             % Import parameter estimates
             load(file);
             
             % Extract parameters
             for i = 1:numel(estimates)
                for es = 1:numel(scenarios)
                    esc = scenarios{es};
                    b(i).(esc) = horzcat(estimates(i).(esc)(:).b);
                end
             end
             
             % Scenarios
             est_sc = ['TRUE',scenarios];
             
         case 'no'
             est_sc = {'TRUE'};
             b = [];
     end

     % Parallel processing 
     cluster = parallel;
     open = 'yes'; 
     [c,poolsize] = clust(cluster,open);
     btstrp = 'yes';
     [out,policies] = evaluate_out(b,par,est_sc,closed,tac_pol,draws,...
         start,btstrp);

     % Save
%      filename = ['data\numerical policy simulations ',num2str(start+1),...
%          '-',num2str(draws+start),' ',date];
%      save(filename,'out','policies','-v7.3');
     
    case 'no'
        filename = 'data\numerical policy simulations 1-200 04-Nov-2019';
        load(filename,'out','policies');
end
  
%% FIGURES
 % Numerical simulations of TRUE model
 export = 'no';
 h1 = fig_num_sims(out.TRUE,policies,export);

 % Out-of-sample prediction errors
 export = 'no';
 h2 = fig_outsample(out,policies,export);
 
 
 

 






 


