%% Nested Fixed-Point (NFXP) Log Likelihood
% * Filename: nfxp_loglikelihood.m
% * Authors: Matt Reimer
% * Created: 10/29/18
% * Updated: 10/09/19
% * Purpose: Function that returns the value of the NFP log likelihood 
% function and the equilibrium quota price evaluated at the parameter 
% vector b.
%
%% Description
% * The function |nfxp_loglikelihood| computes the log likelihood value of
% the NFXP MLE by first solving for the REE quota prices, given a vector 
% of structural parameters, and then evaluating the conditional logit log 
% likelihood, given the REE quota prices.
%
%% Notes:
% * The first column of X must be expected revenue.
% * Called by: |estimation| and |nfxp_mle|.
% * The function |nfxp_loglikelihood| does not solve for maximized
% parameter values. See |nfxp_mle|.
%
function [logL,w,exitflag,Xnew] = nfxp_loglikelihood(b,data,w0,baseAlt)
%% Input arguments:
% * |b| = a K x 1 parameter vector.
% * |data| = a structural array of data.
% * |w0| = a 1 x S initial guess for the equilibirium quota prices in
% period 1.
% * |baseAlt| = the integer number of the category in Y that will be used
%   as the reference alternative. Alternative 1 is the default.
%
%% Output arguments:
% * |logL| = the value of the log likelihood.
% * |w| = a T x 1 vector of equilibrium quota prices, given b.
%
%% Error Checking
    %disp('Make sure that the first column in X is expected revenue!');

%% Preliminaries
% * |Y| = an N x T matrix of integers 1 through J indicating which
%   alternative was chosen.
% * |X| = an N x T x K x J x Yrs array of utility covariates that are alternative-specific.
    X = data.COV;
% * |Z| = a T x S x yrs matrix of fleet-wide remaining TAC (state variable).
    Z = data.remainTAC;
% * |EC| = a N x T x S x J x yrs array of expected catch.
    EC = data.expectedcatch;

    % Dimensions
    N = size(X,1);                      % Number of individuals
    T = size(X,2);                      % Number of time periods
    K = size(X,3);                      % Number of covariates
    J = size(X,4);                      % Number of alternatives
    S = size(Z,2);                      % Number of species
    Y = size(X,5);                      % Number of years
    
    % Defaults
    if (nargin < 4 || isempty(baseAlt)), baseAlt = 1; end
    if (nargin < 3 || isempty(w0)), w0 = zeros(1,S); end
     
%% Determine equilibrium quota lease price, given b
    w = zeros(T,S,Y);                                   % Storage for equilibrium w
    exitflag = zeros(T,Y);                              % Storage for fixed-point solver exitflag
    Xnew = zeros(N,T,K,J,Y);                            % Storage for updated covariates (using w*)
    for yr = 1:Y
        for t = 1:T
            % If quota is exhausted, season was over
            if min(Z(t,:,yr)) > 0
            if t>1
                w0 = w(t-1,:,yr);                           % Use last period's w for starting value
            end
            x = X(:,t:T,:,:,yr);                            % Only use observations >= t
            z = Z(t,:,yr);                                  % Remaining TAC in period t
            ec = EC(:,t:T,:,:,yr);                          % Expected catch in remaining periods
            [w(t,:,yr),exitflag(t),~,xnew] = ...
                w_equil(b,x,z,ec,w0);                       % Expected equilibrium quota price
            Xnew(:,t,:,:,yr) = xnew(:,:,:);                 % Update X with current period's w                       
            end
        end
    end
    data.X = Xnew;
    
%% Evaluate log likelihood, given b and w
    logL = clogit(b,data,baseAlt);
    
end


        
    
    
        
        