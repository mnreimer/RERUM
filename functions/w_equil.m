%% Equilibrium Quota Prices
% * Filename: w_equil.m
% * Authors: Matt Reimer
% * Created: 04/11/18
% * Updated: 10/29/18
% * Purpose: Function that returns the expected equilibrium quota-lease
% prices as a function of time period and remaining quota.
%
%% Description
% The function |w_equil| computes the expected equilibrium quota-lease
% prices for a given period $t$ and remaining fleet-wide quota. This is the
% heart of the data generating process and the RERUM estimator. This
% function is used to impute missing quota prices in the RERUM estimator
% (the "inner loop" of the NFXP). At the heart of the function, is the
% |exdem| function, which computes the excess demand for end-of-seasonn
% quota for a given set of quota prices. The function |w_equil| iterates
% over $w$ until it finds a fixed point for |exdem|.
%
%% Notes
% * Called by: |dgpdraw|, |nfxp_loglikelihood|, and |w_pred|.
%
function [w_star,exitflag,prob,x] = w_equil(b,x,z,ec,w0)
%% Input arguments:
% * |b| = a vector of preference parameters;
% * |x| = a matrix of exogenous preference variables;
% * |z| = a $1 \times S$ vector of remaining quota;
% * |ec| = an array of expected catch in remaining periods;
% * |w0| = an initial starting value for finding $w^{*}$.
%
%% Output arguments:
% * |w_star| = a $1 \times S$ vector of expected equilibrium quota-lease
% prices.
% * |prob| = 
%
%% Preliminaries
%     options = optimoptions('fsolve','Display','off');
    options = optimoptions('fsolve','Display','off','FunctionTolerance',1e-8,...
        'OptimalityTolerance',1e-8);
    S = size(w0,2);
    
%% Solve for $\mathbf{w}^{*}$ 
    f = @(w)equil(b,w,z,x,ec);
    maxiter = 100;
    exitflag = 0;
    iter = 0;
    % Include random initial value if no convergence
    while (exitflag <= 0 && iter<=maxiter)
        [w_star,~,exitflag] = fsolve(f,w0,options);
        w0 = 5*iter + 5*(iter+1)*rand(1,S);
        iter = iter + 1;
    end
    if nargout > 2
        [~,prob,x] = exdem(b,w_star,z,x,ec);
    end

%% Functions: 
    %Equilibrium condition
    function F = equil(b,w,z,x,ec) 
        % Expected Excess Demand
            xdem = exdem(b,w,z,x,ec);
        % Equilibrium Condition
            F = psi(xdem(:),-w(:),'plus');
    end

    % Expected end-of-season excess demand and choice probabilities 
    function [y,prob,x] = exdem(b,w,z,x,ec)
    % Parameters
        N = size(x,1);              % Number of individuals
        T = size(x,2);              % Number of remaining periods
        K = size(x,3);              % Number of covariates
        J = size(x,4);              % Number of locations
        S = size(z,2);              % Number of species
        
    % Update Expected Revenue
    % The objective here is to subtract off the shadow cost of quota from
    % expected revenue using the given quota prices w.
    % Note: Expected Revenue is column 1 in x
        % Calculate shadow value using w and expected catch
        shadow = zeros(N*T,1,J);
        ec = reshape(ec,N*T,S,J);
        x = reshape(x,N*T,K,J);
        for j = 1:J
            shadow(:,1,j) = ec(:,:,j)*(w');
        end
        % Update expected revenue to reflect shadow cost
        x(:,1,:) = x(:,1,:) - shadow;
        
    % Calculate location choice probabilities
        x = reshape(x,N,T,K,J);
        prob = choiceprobs(b,x);
        
    % Calculate end-of-season expected catch
        P = repmat(reshape(prob,[N*T 1 J]),[1 S 1]);
        temp = P.*ec;                                   % Expected catch for each individual/time combo                  
        expcatch = squeeze(sum(sum(temp,3),1));         % Sum across all time periods and individuals
        % Calculate expected end-of-season excess demand
        y = expcatch - z;
        
    % Return updated covariates and choice probabilities for current period
        x = squeeze(x(:,1,:,:));
        prob = reshape(prob,N,T,J); prob = prob(:,1,:);
    end

    % Smoothing Function 
    function y = psi(u,v,flag)
        switch flag
            case 'plus'
                y = u + v + (u.^2 + v.^2).^0.5;
            case 'minus'
                y = u + v - (u.^2 + v.^2).^0.5;
        end
    end

end


