%% Choice Probabilities
% * Filename: choiceprobs.m
% * Authors: Matt Reimer
% * Created: 02/05/19
% * Updated: 02/05/19
% * Purpose: Function that returns the logit probabilities, given a vector
% of parameters ($\beta$) and alternative-specific covariates ($X$).
%
%% Description
%
%% Notes
% * Called by: |clogit|, |dgpdraw|, |w_equil|.
%
function prob = choiceprobs(b,X)
%% Input arguments:
% * |b| = a K x 1 parameter vector.
% * |X| = an N x T x K x J x Yr array of covariates that are 
% alternative-specific.
%
%% Output arguments:
% * |prob| = a N x T x J x Yr array of choice probabilities.
%
%% Notes:

%% Preliminaries
    % Dimensions
    N = size(X,1);                      % Number of individuals
    T = size(X,2);                      % Number of time periods
    K = size(X,3);                      % Number of covariates
    J = size(X,4);                      % Number of alternatives
    Yr = size(X,5);                     % Number of years

%% Choice Probabilities
    prob = zeros(N,T,J,Yr);
    for yr = 1:Yr
        num = zeros(N*T,J);
        dem = zeros(N*T,1);        
        x = reshape(X(:,:,:,:,yr),N*T,K,J);
        for j = 1:J
            num(:,j) = exp(x(:,:,j)*b);
            dem = num(:,j) + dem;
        end
        temp = num./repmat(dem,1,J);
        prob(:,:,:,yr) = reshape(temp,N,T,J);
    end
    
end