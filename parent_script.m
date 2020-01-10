%% Parent Script
% * Filename: parent_script.m
% * Authors: Matt Reimer
% * Created: 02/02/18
% * Updated: 01/10/20
%
%% Description
% The script |parent_script| is a guide for how to generate data and 
% estimate parameters.
%
%% Notes
% Note that much of the data-generating and analysis for the paper takes 
% place in other scripts, namely |monte_carlo_data|, |monte_carlo_analysis|,
% and |policy_simulations|. 
%
%% PRELIMINARIES
 % Environment
  clc, clear
  close all
  directory = 'Documents/GitHub/RERUM';
  cd(homedir)
  cd(directory)
  addpath(genpath(pwd)) 
  
 % Load default parameters 
  par = parameters;
    
 % Clusters: for parallel computing (none, local, or cloud)
 % NOTE: function will need adapting to local conditions.
  cluster = 'none';
  open = 'no';
  [c,poolsize] = clust(cluster,open);

%% GENERATE DATA: LOCATION CHOICES, CATCH, & QUOTA PRICES
 % A single draw from the DGP (default parameter values)
  b = par.btrue;     % Default structural parameter vector
  D = dgpdraw(b,par); 

 % Multiple draws from the DGP (default parameter values)
  draws = 5; 
  for k = 1:draws
    DD(k) = dgpdraw(b,par,[],k);
  end
  
 % A single draw with non-default parameter values
  par = set(par,{'periods','gridsize'},{45,8});
  D = dgpdraw(b,par); 
 
 % A single draw with 10 closed "hot-spot" areas
  closures = 10;    % Number of closures
  [~,closed] = hotspots(D,closures,par);    % Areas with the most bycatch
  D = dgpdraw(b,par,[],[],closed); 
  
 % Figures
  fig1 = fig_wstar(D,'single'); % Fishery outcomes from a single draw
  fig2 = fig_wstar(DD,'all');   % Quota prices from several draws
  
%% ESTIMATION: Using a single draw from the dgp
 % Draw data from dgp
  data = dgpdraw(b,par); 
  
 % Estimation Options
  display = 'iter';               % Option for displaying iterations
  multi_start = 'off';            % Option for multiple starting values
  b0 = par.btrue;                 % Initial guess
  spec = 'RERUM';                 % Model specification
  options = {'display',display,'b0',b0,'multi_start',multi_start};
 
 % Estimation
  estimate = estimation(data,spec,options);
    



