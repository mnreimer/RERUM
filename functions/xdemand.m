function [out1,out2] = sdp(w,i,k)

%% Parameters/Exogenous Variables
% w = a vector of quota prices
% i = the vessel for which the sdp is for
%
% This function imports exogenous information/data from other functions:
% 
% * The function |parameters.m| contains all parameter values and returns them 
% in a structure that is easy to pass into susbequent functions. Use this function 
% to change parameter values or approximation spaces.
% * The function |Expcatch.m| computes the expected values for species-specific 
% catch in each time period and time period.
% * The function |err.m| returns the shocks to catch, which are used to compute 
% expectations of the value function.

   [m] = parameters;                % Model parameters (see function file: parameters)
   EC = ExpCatch(m);                % Expected Catch
   T = m.horizon{1};                % Number of periods
   sig = m.params{3};               % Signalling errors
   
   %% SDP
% This sections solves the SDP recursively. A couple of comments:
% 
% * The array |c| stores the basis coefficients associated with each time period. 
% The basis coefficients are equal to zero in period _T_+1 since there is no scrap 
% value in this problem.
% * The function |funbasx| computes the tensor product of the interpolation 
% matrices evaluated at the interpolation nodes. Note that since the interpolation 
% nodes are the same in each period, this tensor product can be evaluted outside 
% of the loop.
% * The function |vmax| solves for the _max_ and _argmax_ for the per period 
% value function. Note that the function uses the next period's basis coefficients 
% |c(:,t+1)| and the interpolation matrix |B.vals| to approximate the next period's 
% value function. Also note that |vmax| can handle multiple interpolation nodes 
% at once (i.e., it takes a vector of states |s| as an input).
% * The function |ckronxi| uses the vector of maximum values |v| to solve for 
% the basis coefficients for the current period |c(:,t)|, which are used in the 
% subsequent iteration.

    f = zeros(N,T);     % Optimal fishery
    v = zeros(N,T);     % Maximum value
    c = zeros(S,N,T);   % Catch
    Z = zeros(S,1);     % Cumulative catch
    w = zeros(S,T);     % Forecasted quota prices
    
    for t=1:T
        % Forecast of quota prices $w$
        w(:,t) = qlease(t,Z,eta);
        for i=1:N
            % Find expected maximum value and optimal fishery
            [f(i,t),v(i,t)] = vmax(t,i,m,EC,w(:,t),sig(:,:,:,k));           
            % Obtain catch associated with optimal fishery choice
            c(:,i,t) = func('g',f(i,t),t,i,e,[],m,EC);
        end
        % Fleet-wide cumulative catch in period $t$
        Z = sum(c(:,:,t),2) + Z;
    end
end


