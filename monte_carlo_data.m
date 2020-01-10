%% Monte Carlo Data
% * Filename: monte_carlo_data.m
% * Authors: Matt Reimer
% * Created: 02/02/18
% * Updated: 10/16/19
%
%% Description
% The script |monte_carlo_data| is the parent script for generating data
% and estimates from the data generating process. Data are either generated
% with a random draw from the parameter space or using a pre-determined set
% of parameters.
%
%% Notes
% Running the script from start to finish can take a VERY LONG TIME! For 
% example, the data generating and estimation process can take several 
% hours (or days) depending on the number of MC draws, parameter scenarios,
% and whether you use multiple starting points to ensure global
% convergence.
%
%% Preliminaries

 % Environment
  clc, clear
  close all
  directory = 'Documents/GitHub/RERUM';
  cd(homedir)
  cd(directory)
  addpath(genpath(pwd)) 

 % Default parameters 
  par = parameters;
    
 % Clusters: for parallel computing (none, local, or cloud)
  cluster = 'cloud';
  open = 'no';
  [c,poolsize] = clust(cluster,open);  

%% Estimation: Random Parameters
% * Uses random draws from the data-generating parameter space. Used
% primarily for evaluating estimation and in-sample performance.

  % Data-generating Scenarios 
  scen.dat_sc.par = {'random'};     % Random draw from parameter-value space
  scen.dat_sc.val = [];             % Parameter values (N/A for random)
  
  % Estimation Specifications
  scen.est_sc = {'SRUM','ARUM1','ARUM2','RERUM'};   
  
  % Options
  draws = 100; start = 100;
  options = {'scen',scen,'draws',draws,'start',start,'multi_start','on',...
      'display','off','est','yes'};
  outputs = 3;
  
  % Estimate using batch processing
  fun = @() dgp_estimation(par,options);
  j = batch(fun,outputs,'Profile',c.Profile,'Pool',poolsize-1);
  job = fetchOutputs(j);
  
  % Save data
  filename = ['data\estimates random multi_start job ',num2str(start+1),...
      '-',num2str(start+draws),' ',date];
  save(filename,'job','-v7.3');
  
  
%% Estimation: Data Scenarios
% * Uses predetermined data-generating parameters. Used primarily for
% evaluating out-of-sample performance.

  % Data-generating Parameters: All Scenarios 
  parnames = {'years','periods','individuals','gridsize','species',...
      'btrue','sigma','tac','price'};   
  parvals = {1,50,20,10,2,[1;-0.4],0.25,[1.3e-2,0.7e-2],[1000;0]}; 
  par = set(par,parnames,parvals);
  
  % Data-generating Parameters: Scenario-specific
  scen.dat_sc.par = {'mu'};                     % Data-generating scenarios
  scen.dat_sc(1).val = {[-2.5,2.5;2.5,-2.5]};   
  scen.dat_sc(2).val = {[1.5,1.5;0,0]};   % Data-generating scenario values
  
  % Estimation Specifications
  scen.est_sc = {'SRUM','SRUM1','SRUM2','ARUM1','ARUM2','RERUM'};   
  
  % Options
  draws = 500; start = 0;
  options = {'scen',scen,'draws',draws,'start',start,'multi_start','off',...
      'display','off','est','yes','b0',par.btrue};
  outputs = 2;
  
  % Estimate using batch processing
  fun = @() dgp_estimation(par,options);
  j = batch(fun,outputs,'Profile',c.Profile,'Pool',poolsize-1);
  job = fetchOutputs(j);
  
  % Save data
  data = job{1,1}; estimates = job{1,2};
  filename = ['data\estimates scenarios ',num2str(start+1),'-',...
      num2str(start+draws),' ','sigma025 ',' ',date];
  save(filename,'data','estimates','-v7.3');
  
  


  
  
  
  
  
  
  