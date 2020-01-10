%% Nested Fixed-Point (NFXP) Maximum Likelihood Estimate
% * Filename: nfxp_mle.m
% * Authors: Matt Reimer
% * Created: 10/29/18
% * Updated: 10/09/19
% * Purpose: Function that finds the NFXP MLE. 
%
%% Description
%
function [b,logL,exit,est_time,ms_out] = nfxp_mle(data,varargin)
%% Input arguments:
% * |data| = a structural array of data.
% * |varargin| = otional arguments.
%
%% Output arguments:
% * |b| = a K x 1 vector of MLE estimates.
% * |logL| = the value of the log likelihood at b_MLE.
% * |exit| = exit flag describing exit condition.
% * |est_time| = estimation time.
% * |ms_out| = additional outputs for multi_start.
%
%% Notes:
% * The first column of X must be expected revenue.
%
%% Default Values
    display = 'off';            % Option for displaying iterations
    multi_start = 'off';        % Option for multiple starting values
    basealt = 1;                % Choice of base alternative for logit prob
    b0 = [2*rand(1);-2*rand(1)];% Random initial guess for b_MLE
    w0 = [];                    % Initial guess for RE quota prices
    ms_out = [];                % Initialize storage for multi_start output
    
    % Multi_start Only
    lb = [0,-2];                % Lower bound 
    ub = [2,0];                 % Upper bound 
    gridsize = 3;              % Grid size of initial values 
    
%% Optional Arguments
    options = varargin{:};
    
    % Loading optional arguments
    while ~isempty(options)
        switch lower(options{1})
            case 'display'
                display = options{2};
            case 'multi_start'
                multi_start = options{2};
            case 'bounds'
                lb = options{2}(1,:);
                ub = options{2}(2,:);
            case 'prices'
                w0 = options{2};
            case 'basealt'
                basealt = options{2};  
            case 'b0'
                b0 = options{2};  
            otherwise
                error(['Unexpected option: ' options{1}])
         end
          options(1:2) = [];
    end

%% Preliminaries
    % Function handle for log likelihood
     f = @(b) nfxp_loglikelihood(b,data,w0,basealt); 
     
    % Optimization options
     opt = optimset('Display',display);
     
%% Estimation
    switch multi_start
        
        % Single initial guess
        case 'off'
            tic;
            [b,logL,exit] = fminsearch(f,b0,opt);
            est_time = toc;
            
        % Multiple initial guesses (grid search)    
        case 'on'
            % Notify multi_start settings
%             disp(['Multi-start chosen with grid dimensions of ',...
%                 num2str(gridsize),' with lb = [',num2str(lb),...
%                 '], and ub = [',num2str(ub),']']);
            
            % Starting point grid
            eps = 0.1;              % Starting distance from boundary
            b0 = gridmake(linspace(lb(1)+eps,ub(1)-eps,gridsize)',...
                linspace(lb(2)+eps,ub(2)-eps,gridsize)')';
    
            % Search across all starting points
            out = zeros(2,size(b0,2));
            [fval,ex,est_t] = deal(zeros(1,size(b0,2)));
            for i = 1:size(b0,2)
                tic;
                [out(:,i),fval(i),ex(i)] = fminsearch(f,b0(:,i),opt);
                est_t(i) = toc;
            end
            
            % Identify "true" MLE
            [logL,ind] = min(fval);     % Smallest minimized value
            b = out(:,ind);               % Corresponding MLE estimate
            exit = ex(ind); est_time = est_t(ind);
            
            % Identify "incorrect" estimates
            delta = 0.01;             % Tolerance for numerical precision
            is_out = any(abs(out - repmat(b,1,size(out,2)))>delta,1);
            num_out = sum(is_out);
            pct_corr = 1 - (num_out/size(b0,2));
            
            % Output
            ms_out = struct('pct_corr',pct_corr,'manymins',out,...
                'manyfmins',fval);
    end
    

end