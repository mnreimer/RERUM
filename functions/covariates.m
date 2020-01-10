%% Covariates for estimation of utility parameters
% * Filename: covariates.m
% * Authors: Matt Reimer
% * Created: 01/22/19
% * Updated: 03/18/19
% * Purpose: Function that generates the covariates that enter the utility
% function for conditional or NFXP logit estimation.
%
%% Description
% 
%% Notes
% * Called by: |dgpdraw|, |estimation|, |w_approx|
%
function [X,ind] = covariates(EC,z,COV,TAC,w,scenario,period)
%% Input arguments:
% * |data| = structural array of data for manipulation
% * |scenario| = indicator of scenario, which determines covariates
%
%% Output arguments:
% * |X| = a covariate array 
%
%% Notes:
%

%% Preliminaries    
    % Dimensions
    N = size(EC,1);                     % Number of individuals
    T = size(EC,2);                     % Number of time periods
    S = size(EC,3);                     % Number of species
    J = size(EC,4);                     % Number of alternatives
    Y = size(EC,5);                     % Number of years
    
    % Remaining TAC (Reshape for data manipulation)
    z = z(1:T,:,:);     % Discard period T+1
    Z = zeros(N,T,S,1,Y);
    for i = 1:N
        Z(i,:,:,1,:) = z;                   % Same across all N
    end
    Z = repmat(Z,[1,1,1,J,1]);              % Same across all J
    for s = 1:S
        for yr = 1:Y
            Z(:,:,s,:,yr) = Z(:,:,s,:,yr)/TAC(yr,s);               % Transform to cumulative catch
        end
    end                                                     
       
    if nargin < 7, period = []; end
    
    % Time Period (Reshape for data manipulation)
    if T == 1       % Indicator for manipuluating only one period
        assert(isempty(period)==0,'Time period must be a scalar')
        t = repmat(period,[N,1,1,J,Y]);
    else            % Indicator for manipulating all periods in data
        period = 1:1:T;
        t = repmat(period,[N,1,1,J,Y]);
    end
    
switch scenario
    % Static Rum (SRUM):
     % Uses the true contemp utility, but does not include shadow values.
    case 'SRUM'
        
        % Pre-shadow-value Exrev and Distance 
        X = COV;   
    
    % Static Rum1 (SRUM1):
     % Uses the true contemp utility, and DOES include observed shadow values.
    case 'SRUM1'
        
        % Shadow-value adjusted Exrev  
        for tt = 1:T
            for y = 1:Y
                shadow = zeros(N,1,1,J,1);
                for s = 1:S
                    % Adjust if w = NAN (season over)
                    if isnan(w(tt,s,y))
                        w(tt,s,y) = 0;
                    end
                    shadow = w(tt,s,y)*EC(:,tt,s,:,y) + shadow;
                end
                COV(:,tt,1,:,y) = COV(:,tt,1,:,y) - shadow;
            end
        end
        X = COV;
    
    % Static Rum2 (SRUM2):
     % Uses the true contemp utility, and DOES include observed AVERAGE shadow values.
    case 'SRUM2'
        
        % Shadow-value (AVERAGE) adjusted Exrev  
        for y = 1:Y
            shadow = zeros(N,T,1,J,1);
            for s = 1:S
                qprice = mean(w(:,s,y),'omitnan');
                shadow = qprice*EC(:,:,s,:,y) + shadow;
            end
            COV(:,:,1,:,y) = COV(:,:,1,:,y) - shadow;
        end
        X = COV;
        
    case 'RERUM'
        
        % Pre-shadow-value Exrev annd Distance 
        X = COV;          
        
    % Approximate RE RUM 1 (ARUM1):
        % Interacts Exrev with cumulative catch and time quadratically.
    case 'ARUM1'
       
        % Pre-shadow-value Exrev annd Distance
        X = COV;
        
        % Shadow Approximation
        num = 5;        % Number of covariates (per species) in shadow approx
        for s = 1:S
            % Linear Interactions
            X1 = EC(:,:,s,:,:).*t;
            X2 = EC(:,:,s,:,:).*Z(:,:,s,:,:);
        
            % Quadratic Interactions
            X3 = EC(:,:,s,:,:).*(t.^2);
            X4 = EC(:,:,s,:,:).*(Z(:,:,s,:,:).^2);
        
            % Cross-term Interactions
            X5 = EC(:,:,s,:,:).*Z(:,:,s,:,:).*t;
            
            % Add to covariate matrix
            X = cat(3,X,X1,X2,X3,X4,X5);
            
            % Index for extracting species-specific covariates
            ind(s,:) = ((s-1)*num + 1):1:((s-1)*num + num);
        end

        
    % Approximate RE RUM 2 (ARUM2):
        % Interacts Exrev with cumulative catch (all species) and time quadratically.
    case 'ARUM2'
       
        % Pre-shadow-value Exrev annd Distance
        X = COV;
        
        % Shadow Approximation: Linear Interactions
        num = 8;        % Number of covariates (per species) in shadow approx
        X3 = []; 
        for s = 1:S
            % Linear and Quadratic time variables
            X1 = EC(:,:,s,:,:).*t;
            X2 = EC(:,:,s,:,:).*(t.^2);
            for ss = 1:S
                % Cross-term and Quadratic interactions
                temp1 = EC(:,:,s,:,:).*Z(:,:,ss,:,:);
                temp2 = EC(:,:,s,:,:).*Z(:,:,ss,:,:).*t;
                temp3 = EC(:,:,s,:,:).*Z(:,:,s,:,:).*Z(:,:,ss,:,:);
                X3 = cat(3,X3,temp1,temp2,temp3);   % Store variables
            end
            % Add to covariate matrix
            X = cat(3,X,X1,X2,X3);
            % Index for extracting species-specific covariates
            ind(s,:) = ((s-1)*num + 1):1:((s-1)*num + num);
            % Reset storage matrix
            X3 = [];
        end
        
        
end

end

            
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        