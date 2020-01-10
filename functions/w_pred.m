%% Quota Price Predictions
% * Filename: w_pred.m
% * Authors: Matt Reimer
% * Created: 06/26/19
% * Updated: 06/26/19
% * Purpose: Predicts quota prices for various models given a set of state 
% variables.
%
%% Description
% The function |w_pred| computes and returns the predicted quota prices for
% several different behaviorla models. The main reason for this function
% was to be able to have quota-price predictions from the various models
% that could be eventually evaluated against the true model. However, in 
% the end, they aren't of much value for the non-RERUM models since they 
% are not identified separately from the structural parameters. So, while
% this function is still used in the |estimation| function, it is not of
% much interest or value.
% 
function [w,exit] = w_pred(b,data,scenario)
%% Input arguments:
% * |b| = vector of preference parameters;
% * |data| = structural array of data;
% * |state| = the state space (all combos) to be evaluated;
% * |scenario| = the estimation scenario (e.g., RERUM);
%
%% Output arguments:
% * |w| = quota prices (true or predicted) 
%
%% Notes:
% * The first column of X must be expected revenue.
% * Called by: |estimation|
%
%% Preliminaries
    % Utility specification scenario
    if nargin < 3, scenario = 'TRUE'; end
    
    % Data from the DGP
    COV = data.COV;
    TAC = data.TAC;
    EC = data.expectedcatch;
    remainTAC = data.remainTAC;
    
    % Dimensions 
    T = size(COV,2);                  % Number of time periods
    Yr = size(COV,5);                 % Number of years
    S = size(EC,3);                   % Number of species
    
%     % State Space
%     periods = state(:,1);
%     remainTAC = state(:,2:end);
    
%% Generate Data
    % Pre-allocate storage
    w = NaN(T,S,Yr);   
    exit = zeros(T,Yr);             
    
    % Loop through state-variable combos
    for yr = 1:Yr
%     for st = 1:size(state,1)
    for t = 1:T
            % Remaining TAC
            z = remainTAC(t,:,yr);
%             t = periods(st);

            switch scenario
                % True DGP and RERUM: Find equilibrium quota price, given b
                case {'TRUE','RERUM'}
                    % Initial guess for equilibrium w
                    w0 = zeros(1,S);
                    % Only need to use obs >= t to project end-of-season catch
                    x = COV(:,t:T,:,:,yr);                   % Only need observations >= t
                    ec = EC(:,t:T,:,:,yr);                   % Expected catch in remaining periods
                    
                    % Find equil quota prices and "updated" covariates
                        % Note: old x (input) includes periods >= t
                        % Note: new x (output) only includes period t
                    [w(t,:,yr),exit(t,yr)] = w_equil(b,x,z,ec,w0);    % Expected equilibrium quota price
                    
                case 'SRUM'
                    w(t,:,yr) = 0;
                    
                case 'SRUM1'
                    w(t,:,yr) = data.wstar(t,:,yr);

                case {'ARUM1','ARUM2'}
                    % Approx quota prices and updated revenue (accounting for shadow cost)
                    % Note: returns x for only a single period
                    w(t,:,yr) = w_approx(b,EC(:,t,:,:,yr),z,COV(:,t,:,:,yr),TAC,scenario,t,'no');
            end
            
    end
    end

end