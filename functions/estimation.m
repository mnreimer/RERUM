%% Data Generating and Estimation Function
% * Filename: estimation.m
% * Authors: Matt Reimer
% * Created: 03/10/19
% * Updated: 10/10/19
%
%% Description
% The function |estimation| estimates the preference parameter vector 
% $\beta$ given data and a specification of the utility function.
% 
%% Notes
% * Called by: |dgp_estimation|
%
function estimates = estimation(D,scenario,varargin)
%% Input arguments
% * |D| = a structural array of data used for estimation;
% * |scenario| = estimation scenario (SRUM, ARUM, RERUM, etc.)
% * |varargin| = optional arguments.
%
%% Optional arguments
% * |multi_start| = indicator for whether RERUM is estimated using multiple
% initial values;
% * |display| = indicator for whether iteration output is displayed;
% * |b0| = inivitial value for preference parameter.
%
%% Output arguments
% * |estimates| = a structural array of estimation results
% 
%% DEFAULT SETTINGS
    display = 'off';                % Option for displaying iterations
    multi_start = 'off';            % Option for multiple starting values
    b0 = [2*rand(1);-2*rand(1)];    % Random initial guess for Erev and Dist
    ms_out = [];                    % Initialize storage for multi_start output
    
    % Estimation scenario
    if isempty(scenario), error('Estimation scenario must be provided'), end
    
    % Fix ARUM2 when S = 1 (i.e., it's the same as ARUM1) 
    if (size(D.TAC,2)==1 && strcmp(scenario,'ARUM2')), scenario='ARUM1'; end
    
%% OPTIONAL ARGUMENTS
    options = varargin{:};
    
    % Loading optional arguments
    while ~isempty(options)
        switch lower(options{1})
            case 'display'
                display = options{2};
            case 'multi_start'
                multi_start = options{2};  
            case 'b0'
                b0 = options{2};  
            otherwise
                error(['Unexpected option: ' options{1}])
         end
          options(1:2) = [];
    end
  
%% ESTIMATE PARAMETERS
   % Utility Specification
    D.X = covariates(D.expectedcatch,D.remainTAC,D.COV,D.TAC,D.wstar,scenario);
    
   % Loglikelihood specification and initial values
    switch scenario
        case 'RERUM'
        % RERUM Options
         opt_RERUM = {'display',display,'multi_start',multi_start};

        % RERUM estimation    
         [b,logL,exit,est_time,ms_out] = nfxp_mle(D,opt_RERUM);

        % Predicted Probabilities
         [~,~,~,X] = nfxp_loglikelihood(b,D);    % Updated covariates 
         P = choiceprobs(b,X);

        otherwise    
        % Anonymous function definition
         f = @(b) clogit(b,D);

        % Initial value of b
         b0 = [b0 ; zeros(size(D.X,3)-2,1)];

        % Log Likelihood Maximization
         opt = optimoptions('fminunc','OptimalityTolerance',1e-8,...
                  'StepTolerance',1e-8,'SpecifyObjectiveGradient',true,...
                  'Display',display);
         tic;
         [b,logL,exit] = fminunc(f,b0,opt);
         est_time = toc;

        % Predicted Probabilities
         P = choiceprobs(b,D.X);
    end

    % Predicted Quota Prices
     w = w_pred(b,D,scenario);            % Predicted quota prices

    % Storage
     estimates = struct('b',b,'logL',logL,'prob',P,'exit',exit,...
        'est_time',est_time,'w',w,'ms_out',ms_out);  
 
end
