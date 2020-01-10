%% Data Generating Process
% * Filename: dgpdraw.m
% * Authors: Matt Reimer
% * Created: 04/11/18
% * Updated: 12/18/19
% * Purpose: Function that generates one draw from dgp.
%
%% Description
% The function |dgpdraw| generates data for a single draw from the dgp. It
% produces data for both exogenous variables (through |dgpdata|) and 
% endogenous variables (using behavioral rules). This script can be used to
% generate data for estimation purposes or for counterfactual policy 
% simulations
%
%% Notes
% * Called by: |dgp_estimation| and |evaluate_out|.
% * The first column of X must be expected revenue.
%
function data = dgpdraw(b,par,scenario,k,closed,w_obs)
%% Input arguments:
% * |b| = vector of preference parameters;
% * |par| = structural array of parameters;
% * |scenario| = utility specification (for prediction only);
% * |k| = seed number for random number generator;
% * |closed| = a set of areas closed to fishing;
% * |w_obs| = a set of observed quota prices (for prediction only);
%
%% Output arguments:
% * |data| = a structural array 
%
%% Preliminaries
    % Observed Quota Prices
    if nargin < 6, w_obs = []; end
    
    % Number of closed areas
    if nargin < 5, closed = []; end
    
    % Seed number
    if (nargin < 4||isempty(k)), k = 1; end
    
    % Utility specification scenario
    if (nargin < 3||isempty(scenario)), scenario = 'TRUE'; end
    
    % Data from the DGP
    [COV,TAC,EC,AB] = dgpdata(par,'static');
    
    % Dimensions 
    N = size(COV,1);                  % Number of individuals
    T = size(COV,2);                  % Number of time periods
    K = size(COV,3);                  % Number of covariates
    J = size(COV,4);                  % Number of alternatives
    Y = size(COV,5);                  % Number of years
    S = size(EC,3);                   % Number of species
    
    % Model Parameters
    sigma = par.sigma;              % Parameter for stochastic catch (log-normal)
    u = par.u;                      % Location parameter for utility shock
    gamma = par.gamma;              % Scale parameter for the utility shock 
    q = par.catchability;           % Catchability coefficient
    
%% Generate Data
    % Pre-allocate storage
    w = zeros(T,S,Y);             
    z = zeros(T+1,S,Y); for i = 1:Y, z(1,:,i) = TAC(i,:); end          
    h = zeros(N,T,S,Y);   
    y = zeros(T,S,Y);            
    a = zeros(N,T,Y);
    rev = zeros(N,T,Y);
    v = zeros(N,T,Y);
    p = zeros(N,T,J,Y);
    exit = NaN(T,Y);
    
    % Loop-specific shocks: Random Utility
    rng(k), e = -evrnd(u,gamma,J,N,T,Y);      
    
    % Loop-specific shocks: Catch
    mu = log(AB) - sigma/2;                             % Implied value of mu for a given expected catch and value of sigma, assuming log normal distribution
    rng(k), C = exp(mu + (sigma^0.5)*randn(N,T,S,J,Y)); % Stochastic catch
    for i = 1:N                                         % Apply individual-specific catchability coefficients
        C(i,:,:,:,:) = q(i)*C(i,:,:,:,:);
    end
    
    % Forward simulate for each year
    for yr = 1:Y
    for t = 1:T

        % Catch exceeds quota (for any species): shut fishery down
        if min(z(t,:,yr)) <= 0                     
            w(t,:,yr) = NaN(1,S);                  % Non-existent quota price
            a(:,t,yr) = NaN(N,1);                  % Non-existent location choice
            y(t,:,yr) = zeros(1,S);                % No catch
            
        % Catch does not exceed quota
        else
            switch scenario
                % True DGP and RERUM: Find equilibrium quota price, given b
                case {'TRUE','RERUM'}
                    % Initial guess for equilibrium w
                    if t==1                                 % "Random" initial guess in first period
                        w0 = zeros(1,S);
                    else
                        w0 = w(t-1,:,yr);                      % Use last period's w for starting value
                    end

                    % Only need to use obs >= t to project end-of-season catch
                    x = COV(:,t:T,:,:,yr);                   % Only need observations >= t
                    ec = EC(:,t:T,:,:,yr);                   % Expected catch in remaining periods
                    
                    % Indicate closed areas for future catch
                    if isempty(closed) == 0
                        x(:,:,1,closed) = -1e8;             % Makes choice prob equal to zero
                    end

                    % Find equil quota prices and "updated" covariates
                        % Note: old x (input) includes periods >= t
                        % Note: new x (output) only includes period t
                    [w(t,:,yr),exit(t,yr),p(:,t,:,yr),x] = w_equil(b,x,z(t,:,yr),ec,w0);    % Expected equilibrium quota price
                    bb = b;     % For consistency below
                    
                % Approximations: reduced-form approximations of quota price
                case {'SRUM','SRUM1','SRUM2'}
                    % Utility specification
                    x = covariates(EC(:,t,:,:,yr),z(t,:,yr),COV(:,t,:,:,yr),TAC(yr,:),w_obs(t,:,yr),scenario,t);
                    
                    % Indicate closed areas for choice probabilities
                    if isempty(closed) == 0
                        x(:,:,1,closed) = -1e8;             % Makes choice prob equal to zero
                    end
                    
                    % Choice Probabilities
                    p(:,t,:,yr) = choiceprobs(b,x);
                    x = squeeze(x);
                    bb = b;     % For consistency below
                    
                case {'ARUM1','ARUM2'}
                    % Approx quota prices and updated revenue (accounting for shadow cost)
                    % Note: returns x for only a single period
                    [w(t,:,yr),x] = w_approx(b,EC(:,t,:,:,yr),z(t,:,yr),COV(:,t,:,:,yr),TAC(yr,:),scenario,t,'no');
                    
                    % Indicate closed areas for choice probabilities
                    if isempty(closed) == 0
                        x(:,:,1,closed) = -1e8;             % Makes choice prob equal to zero
                    end
                    
                    % Choice Probabilities (Using only updated ex rev and distance)
                    bb = b(1:2);        % Only Rev and Dist parameters
                    x = x(:,1,1:2,:,yr); % Only Rev and Dist variables
                    p(:,t,:,yr) = choiceprobs(bb,x);
                    x = squeeze(x);
            end
            
            % Prevent closed areas from being chosen
            if isempty(closed) == 0
                x(:,:,closed) = nan; 
            end
                
            % Optimal choices and harvests in period t
            for i = 1:N
                % Optimal choice (from open areas)
                [v(i,t,yr),a(i,t,yr)] = max((squeeze(x(i,:,:))')*bb + e(:,i,t,yr),[],'omitnan');  
                % Monetized utility of expected net revenue (at location choice)
                rev(i,t,yr) = (1/bb(1))*squeeze(COV(i,t,:,a(i,t,yr)))'*bb;
                % Individual catch
                h(i,t,:,yr) = squeeze(C(i,t,:,a(i,t,yr),yr));
                % Aggregate catch
                y(t,:,yr) = y(t,:,yr) + squeeze(h(i,t,:,yr))'; 
            end 
        end
        
        % Update next period's state variable
        z(t+1,:,yr) = z(t,:,yr) - y(t,:,yr);                     % Next-period's state variable  

    end
    end
    
    % Assign loop-specific outcomes to structure
    data = struct('expectedcatch',EC,'TAC',TAC,'wstar',w,...
        'remainTAC',z,'catch',y,'COV',COV,'choice',a,'harvest',h,...
        'exit',exit,'prob',p,'netrev',rev,'value',v);


end