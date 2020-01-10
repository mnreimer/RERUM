%% Conditional Logit Log Likelihood
% * Filename: clogit.m
% * Authors: Matt Reimer
% * Created: 12/23/18
% * Updated: 02/06/19
% * Purpose: Function that returns the value of the conditional log 
% likelihood function evaluated at the parameter vector b.
%
%% Description
%
%% Notes
% * Called by: |estimation| and |nfxp_loglikelihood|.
%
function [logL,grad,cov,prob] = clogit(b,data,baseAlt)
%% Input arguments:
% * |b| = a K x 1 parameter vector.
% * |data| = a structural array of data.
% * |baseAlt| = the integer number of the category in Y that will be used
%   as the reference alternative. Alternative 1 is the default.
%
%% Output arguments:
% * |logL| = the value of the log likelihood.
%
%% Notes:
% * Missing data may exist if a season is shut down from exhausting quota. 
% Location choices after shut down are not informative and are indicated by
% NaN in the choice vector. The algorithm below assigns all NaN values in
% Y as zero and do not provide information in the log likelihood function.

%% Error Checking

%% Preliminaries
% * |Y| = an N x T x yrs matrix of integers 1 through J indicating which
%   alternative was chosen.
    Y = data.choice;
% * |X| = an N x T x K x J x yrs array of covariates that are alternative-specific.
    X = data.X;

    % Dimensions
    N = size(X,1);                      % Number of individuals
    T = size(X,2);                      % Number of time periods
    K = size(X,3);                      % Number of covariates
    J = size(X,4);                      % Number of alternatives
    Yr = size(X,5);                     % Number of years

%% Normalize using base alternative
% Note: the default is to use location one as the base alternative, which 
% can be designated as the port where there is no catch, revenues, etc., so
% that the covariates in X for location one will all be zero. In this case,
% normalizing does not make a difference. However, this code allows for
% different normalizations, if wanted.
    if nargin < 3
        baseAlt = 1;
    end
    for j = 1:J
        X(:,:,:,j,:) = X(:,:,:,j,:)-X(:,:,:,baseAlt,:);
    end
    
%% Evaluate log likelihood
% Note: this evaluates the following negative log likelihood function:
% $$-ln(L_{itj}) = ln(\sum_{j=1}^{J}e^{x_{itj}'\beta}) - y_{itj}x_{itj}'\beta $$
    logL = 0; dem = zeros(N*T,Yr);
    for yr = 1:Yr
        num = 0; 
        x = reshape(X(:,:,:,:,yr),N*T,K,J);
        y = reshape(Y(:,:,yr),N*T,1);
        for j = setdiff(1:J,baseAlt)
            temp = x(:,:,j)*b;
            num = (y==j).*temp + num;
            dem(:,yr) = exp(temp) + dem(:,yr);
        end
        dem(:,yr) = dem(:,yr) + 1;
        logL = sum(log(dem(:,yr))-num) + logL;
    end
    
%% Analytical Gradient
if nargout > 1
	grad = zeros(size(b));
    for yr = 1:Yr
        numg = zeros(size(b,1),1);
        demg = zeros(size(b,1),1);        
        x = reshape(X(:,:,:,:,yr),N*T,K,J);
        y = reshape(Y(:,:,yr),N*T,1);
        for j = setdiff(1:J,baseAlt)
            temp = x(:,:,j)*b;
            numg = -(x(:,:,j))'*(y==j)+numg;
            demg = -(x(:,:,j))'*(exp(temp)./dem(:,yr))+demg;
        end
        grad = numg - demg + grad;
    end
end

%% Estimated Covariance Matrix
if nargout > 2
	cov = zeros(size(b,1),size(b,1));
    for yr = 1:Yr
        x = reshape(X(:,:,:,:,yr),N*T,K,J);
        xbar = zeros(N*T,K);
        p = zeros(N*T,J);
        for j = 1:J
            p(:,j) = exp(x(:,:,j)*b)./dem(:,yr);
            xbar = x(:,:,j).*repmat(p(:,j),1,K) + xbar;
        end
        for it = 1:N*T
            for j = 1:J
                cov = p(it,j)*(x(it,:,j)-xbar(it,:))'*(x(it,:,j)-xbar(it,:)) + cov;
            end
        end
    end
    cov = inv(cov);
end

%% Estimated Probabilities
if nargout > 3
    prob = choiceprobs(b,X);
end

end


        
    
    
        
        