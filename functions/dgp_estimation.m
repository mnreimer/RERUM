%% Estimation Function
% * Filename: dgp_estimation.m
% * Authors: Matt Reimer
% * Created: 03/02/19
% * Updated: 10/10/19
% * Purpose: Function that generates data and estimates preference 
% parameters for different specifications of the utility function and data 
% generating process scenarios.
%
%% Description
% The function |dgp_estimation| is the parent function for generating data
% and estimating preference parameters. Note that the main purpose of this
% function is to take advantage of parallel processing. For each loop, it
% generates a single draw from the dgp and then estimates parameters using
% that data. It also loops through multiple estimation scenarios (e.g.,
% SRUM, ARUM, RERUM, etc.) and data-generating scenarios (e.g., biological
% scenarios or random draws from the parameter space). IT IS NOT NECESSARY
% TO USE THIS FUNCTION IF THE USER ONLY WANTS TO GENERATE A SINGLE DRAW
% FROM THE DGP OR ESTIMATE PARAMETERS WITH PRE-GENERATED DATA. TO do so,
% use the scripts |dgpdraw| and |estimation| scripts directly.
%
function [data,estimates,params] = dgp_estimation(par,varargin)
%% Input arguments
% * |par| = an object of class "parameters"; contain default parameters.
% * |varargin| = a cell array of optional arguments
%
%% Optional arguments
% * |est| = indicator for estimating parameters ('yes') or only generating
% data ('no');
% * |scen| = a structural array of scenarios and values used for generating
% data and estimating parameters (see Notes below)
% * |draws| = number of Monte Carlo draws.
% * |b0| = starting value for RERUM model.
% * |display| = indicator for displaying algorithm iterations.
% * |start| = starting position for seed number.
% * |multi_start| = an indicator for whether mulitple starting values are
% used to estimate RERUM model.
% * |closed| = a set of closed areas to fishing (for data generating only)
%
%% Output arguments
% * |data| = a structural array of data used for estimation;
% * |estimates| = a structural array of estimation results
% * |params| = a structural array of parameters used for data generation
% (only applicable if the random scenarios option is chosen)
%
%% Notes:
% * Called by: |monte_carlo_data|.
%
% * This function loops through all possible combinations of |scenarios| 
% and can therefore take a VERY long time (depending on the number of 
% scenarios and the number of Monte Carlo draws. The code below is designed
% for speed using Amazon AWS cloud computing.
% 
% * The variable |scenarios| must be a structural array that contains two
% fields: |dat_sc| =  a vector indicating the biological scenarios to be 
% considered; and |est_sc| = a cell array of the different specifications 
% for the utility function.
%
%% DEFAULT SETTINGS
    est = 'no';                         % Estimate? Or just generate data?
    start = 0;                          % Starting seed number
    display = 'off';                    % Display options
    b0 = [2*rand(1);-2*rand(1)];        % Initial guess for B_rev and B_dist
    draws = 1;                          % Number of draws from dgp
    multi_start = 'off';                % Option for multiple starting values (RERUM only)
    closed = cell(draws,1);             % Set of closed areas (must be cell array of vectors)
    
    % Data and Estimation Scenarios
    scen.est_sc = {'SRUM','ARUM1','ARUM2','RERUM'};
    scen.dat_sc.par = {'sigma'};          % Arbitrary parameter
    scen.dat_sc.val = {par.sigma};        % Default parameter value
    
%% OPTIONAL ARGUMENTS
    options = varargin{:};    
    % Loading optional arguments
    while ~isempty(options)
        switch lower(options{1})
            case 'est'
                est = options{2};
            case 'start'
                start = options{2};
            case 'display'
                display = options{2};
            case 'draws'
                draws = options{2};  
                closed = cell(draws,1); 
            case 'b0'
                b0 = options{2};
            case 'scen'
                scen = options{2};
            case 'multi_start'
                multi_start = options{2};
            case 'closed'
                closed = options{2};
            otherwise
                error(['Unexpected option: ' options{1}])
         end
          options(1:2) = [];
    end
  
%% PRELIMINARIES
    % Predetermined or Random Scenarios
    switch scen.dat_sc(1).par{1}
        case 'random'
            dim = 1;     % Number of scenarios to loop through
        otherwise
            dim = numel(scen.dat_sc);
    end

    % Parallel computing constants (values are constant across workers)
    b = parallel.pool.Constant(b0);     
    c = parallel.pool.Constant(scen);   
    d = parallel.pool.Constant(par);    % Default parameter values
    e = parallel.pool.Constant(dim);    
    
    % Track Progress
    fprintf('\nEstimation using %d draws from the dgp.\n',draws);
    fprintf('Progress:\n');                     
    fprintf([repmat('.',1,draws) '\n\n'])
    tic;  

%% ESTIMATION
  % Loop over draws from dgp
   results = cell(1,draws);     % Pre-allocate storage in cell array
   parfor k = 1:draws
       % Retrieve parameters that are constant across workers
       dat_sc = c.Value.dat_sc;
       est_sc = c.Value.est_sc;
       par = d.Value;
       dim = e.Value;
       b0 = b.Value;
       
       % Preallocate within-parfor-loop storage
       s = struct;

       % Loop over data scenarios
       for ds = 1:dim
           dstr = ['sc' num2str(ds)]
           
           switch dat_sc(1).par{1}
               case 'random'
               % Randomly choose parameters
               p = parameters(k+start);
               s.params = p;                % Store parameters
               otherwise
               % Update default parameters to reflect data scenario
               p = set(par,dat_sc(1).par,dat_sc(ds).val);
           end
               
           % Generate data
           D = dgpdraw(p.btrue,p,'TRUE',k+start,closed{k});
           s.D.(dstr) = D;                  % Store data
               
           % Loop over estimation scenarios
           switch est
               case 'yes'
               % Estimation Options
               opt_est = {'display',display,'b0',b0,'multi_start',...
                   multi_start};
               for es = 1:numel(est_sc)
                   esc = est_sc{es};
                   % Estimate  
                   E = estimation(D,esc,opt_est);
                   s.E.(dstr).(esc) = E;        % Store estimates

               end
           end
               
       end
       
       % Store data, estimates, and parameters in cell array
       results{k} = s;
           
       % Track Progress  
       fprintf('\b|\n'); 
      
   end
   
   % Notify Completion
   time = toc;
   fprintf('Finished: Total Time = %d seconds.\n\n',time);
   
%% Reorganize Results
 % parfor only allows indexing at the first level for structures for the
 % sake of speed (uses sliced variables). Reorganize for easier
 % post-estimation evaluation
 
    for k = 1:draws
        
        for ds = 1:dim
           dstr = ['sc' num2str(ds)];   
           
           % Assign data
           data(k,ds) = results{k}.D.(dstr);
           
           % Assign parameters
           if nargout > 2
               params(k,ds) = results{k}.params;
           end
           
           % Assign Estimates
           switch est
               case 'yes'
               for es = 1:numel(scen.est_sc)
                   esc = scen.est_sc{es};   
                   estimates(ds).(esc)(k) = results{k}.E.(dstr).(esc);
               end
           end
           
        end    
    end

end
    
    
    
    
    
    
    
    
    
    
    
    