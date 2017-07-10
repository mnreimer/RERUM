function [m,fspace] = parameters()
%% Parameters
% This function contains the default parameter values that are used in the 
% fishery choice simulation.

% Model Parameters %
    N = 15;                              % Number of vessels
    sp = 2;                             % Number of species
    fish = 15;                           % Number of fisheries, excluding "no fishing" (i.e., port)
    p = ones(sp,1);                      % Exvessel Price vector, by species
    c = [0; 5*ones(fish,1)];            % Cost of fishing, by fishery (fish=1 is no fishing, no cost)
    T = 40;                             % Model horizon
    shocks = 1;                        % Number of shock realizations to average over in forward simulation
    
% Signalling errors %
    % For the extreme value distribution (e): Mean(e) = u + sigma*Euler's constant; Var(e) = sigma^2*(pi^2/6) %
    u = 0;                          % u is the location parameter
    sigma = 5;                      % sigma is the scale parameter
    rng(1), signal = evrnd(u,sigma,fish+1,T,N,shocks);

% State and action space %
    rng(1), qmax = 500 + 50*rand(N,sp); % Initial quota (multidimensional if sp>1)
    wmax = 2*ones(1,sp);                    % Initial quota (multidimensional if sp>1)
    wmin = zeros(1,sp);                       % Lower bound for quota for each species
    n = 5*ones(1,sp);                   % Number of interpolation nodes (for each species-specific quota)                   
    fspace = fundefn('spli',n,wmin,wmax); % Function approximation structure
    scoord = funnode(fspace);           % Collocation nodes (structure)
    s = gridmake(scoord);               % Collocation nodes in grid form (matrix)

% Expected Catch %
    mubar = ones(fish,sp);              % Mean of e in each fishery (manually adjust based on # of fisheries & species)
    var = 3;                            % variance of e 
    epspar = [0 1];                     % Mean and std of random shock (epsilon)--assumed to be the same for all species
    mu0 = mubar;                        % Initial values for mu
    gamma = 0.7;                        % Mean reversion parameter
    
% Pack parameter structure %
%--------------------------%
    m.actions = (1:1:fish+1)';          % Action space
    m.state = {scoord s qmax};          % State space          
    m.space = {fish sp};                % Spatial/species parameters 
    m.params = {p c signal};            % Reward parameters
    m.horizon = {T};                    % Time/Error horizon parameters
    m.vessels = {N};
    m.expcatch = {mubar var epspar mu0 gamma shocks};   % Expected catch parameters
end