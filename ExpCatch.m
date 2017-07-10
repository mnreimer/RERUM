%% EXPECTED CATCH DATA
% * Filename: ExpCatch.m
% * Authors: Matt Reimer
% * Created: 07/07/17
% * Purpose: Generate expected catch data that is used in the fishery choice 
% model. 
% 
% *Description*: This file generates simulated expected catch data to be 
% used in place of the empirical estimates of expected catch that will be used 
% in the final model.
% 
% *Model*: Let $e_{j,s,t}$ denote a normally-distributed random variable 
% associated with fishery $j$, species $s$, and time $t$. Let $\mu_{j,s,t}$ and 
% $\sigma_s$ denote the mean and variance, respectively. We model catch as:
% 
% $$C_{j,s,t} = exp\{ e_{j,s,t} \} $$
% 
% so that catch has a lognormal distribution with mean:
% 
% $$EC_{j,s,t} = exp\{ \mu_{j,s,t} + \sigma_s/2 \} $$
% 
% For simplicity, I assume that the variance $\sigma_s$ is constant over 
% time and across fisheries, while the mean $\mu_{j,s,t}$ for each species and 
% fishery is assumed to evolve exogenously and independently according to a continuous-valued 
% Markov process:
% 
% $$\mu_{j,s,t+1} = \bar{\mu}_{j,s} + \gamma(\mu_{j,s,t} -\bar{\mu}_{j,s}) 
% + \varepsilon_{j,s,t}$$
% 
% where $\bar{\mu}_{j,s}$ is a fishery and species time-invariant mean, $\gamma$ 
% is a parameter that dictates how fast the time series will revert to its overall 
% mean, and $\varepsilon$ is a normally-distributed random variable.

%% Preliminaries
    clc, clear
    close all
    
%% Parameters
    m = parameters;             % Model parameters (see function file: parameters)
    fish = m.space{1};          % Number of fisheries, excluding fishery 1 (port)
    sp = m.space{2};            % Number of species
    T = m.horizon{1};           % time horizon  
    mubar = m.expcatch{1};      % Mean of e in each fishery 
    var = m.expcatch{2};        % Variance of e 
    epspar = m.expcatch{3};     % Mean and std of random shock (epsilon)
    mu0 = m.expcatch{4};        % Initial values for mu
    gamma = m.expcatch{5};      % Mean reversion parameter
    N = m.vessels{1};           % Number of vessels
    
%% Generate random shocks $(\varepsilon_{j,s,t})$
    rng(3,'twister');                   % set seed to reproduce results
    seed = rng;   
    rng(seed);
    eps = epspar(1) + epspar(2)*randn(fish,sp,T);   % vector of random shocks
    
%% Generate means $(\mu_{j,s,t})$
    mu = zeros(fish,sp,T+1);    % Preallocate mu matrix (for speed)
    mu(:,:,1)=mu0;              % initial value of mu            
    for t=1:T
        mu(:,:,t+1) = mubar + gamma*(mu(:,:,t)-mubar) + eps(:,:,t); % mu follows a Markov process
    end
    mu(:,:,1)=[];               % Drop "burn-in" initial values
    
%% Generate expected catch $(EC_{j,s,t})$
    EC = exp(mu + var/2);
    EC = [zeros(1,sp,T) ; EC];  % Zero catch at fishery=1 (port)

%% Generate catchability coeficients, by vessel and species
    rng(1), q = rand(sp,N);             % Catchability coefficient, by species, vessel

%% Save data
    save('data\ExpCatch.mat','EC','q');
    