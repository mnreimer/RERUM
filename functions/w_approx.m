%% Approximate quota price
% * Filename: w_approx.m
% * Authors: Matt Reimer
% * Created: 03/18/19
% * Updated: 03/18/19
% * Purpose: Generate the approximate quota prices from the ARUM models.
% 
%% Description
% * The function |w_approx| is used to determine the approximated state-
% contingnet quota prices from the ARUM models. The functino is used 
% primarily for out-of-sample predictions when evaluating the endogenous
% quota prices using the ARUM's approximation rule. 
%
function [w,x] = w_approx(b,EC,z,COV,TAC,scenario,period,truncate)
%% Input arguments:
% * |b| = a K x 1 parameter vector.
%
%% Output arguments:
% * |w| = an array of approximate quota prices.
% * |x| = an array of updated ExRev with the shadow price deducted.
%
%% Notes:
% * Called by: |dgpdraw| and |w_pred|
%
%% Preliminaries
 % Default values
 if nargin < 8, truncate = 'no'; end
 if nargin < 7, period = []; end
 
 % Dimensions
 N = size(EC,1);                     % Number of individuals
 T = size(EC,2);                     % Number of time periods
 S = size(EC,3);                     % Number of species
 J = size(EC,4);                     % Number of alternatives
 Yr = size(EC,5);                    % Number of years 

%% Extract un-interacted variables from matrix of covariates
 % Replace expected catch with ones
  sz = size(EC);
  E = ones(sz);
  
 % Un-interacted variables and index for parameter extraction
  [x,ind] = covariates(E,z,COV,TAC,scenario,period);
  
 % Use only those variables associated with quota price approximation
 % Note: first two covariates are exrevenue and distance
 % Note: prices are constant across i and j, use first observations
  i = 1; j = 1;
  xx = x(i,:,3:end,j,:);
  
 % Extract parameters associated with quota price approximation
  bb = b(3:end);
 
%% Compute Approximated quota prices
  w = zeros(T,S,Yr);
  for s = 1:S
      % Back-out quota price parameter values (exrev is first parameter)
      gamma = -(1/b(1))*bb(ind(s,:));
      
      % Extract species-specific state variables
      X = squeeze(xx(1,:,ind(s,:),1,:));
      
      % Calculate approx quota prices 
      % Loop through years
      for yr = 1:Yr
          
          % Quota prices (dimensions need fixing if T = 1)
          if T > 1
            W = X(:,:,yr)*gamma;
          else
            W = (X(:,:,yr)')*gamma;
          end
              
          % Restrict prices to be non-negative
          switch truncate
              case 'yes'
                  % Replace negative values with zero
                 W(W<0) = 0;
          end 
              
          % Store prices
          w(:,s,yr) = W;
      end
  end
  
%% Update parameters with shadow value
if nargout > 1
    
    for yr = 1:Yr
        for t = 1:T
            ec = squeeze(EC(:,t,:,:,yr));
            ww = squeeze(w(t,:,yr));
            for j = 1:J
                x(:,t,1,j,yr) = x(:,t,1,j,yr) - ec(:,:,j)*(ww');
            end
        end
    end
          
end


end


     
     
  





















 
 
