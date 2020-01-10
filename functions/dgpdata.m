%% Data Generating Process: Monte Carlo Data
% * Filename: dgpdata.m
% * Authors: Matt Reimer
% * Created: 04/11/18
% * Updated: 06/26/19
% * Purpose: Function that generates one draw from dgp
%
%% Description
% * Generates data for use in the Monte Carlo exercise. 
%
%% Notes
% * Called by: |dgpdraw|.
% * This function only produces data for exogenous variables. Endogenous
% variables are determined in |dgpdraw|.
%
function [COV,TAC,EC,AB] = dgpdata(par,tac)
%
%% Inputs
% * |par| = a structural array of parameter values;
% * |tac| = an indicator of whether TAC is the same across years ('static')
% or varies across years ('vary').
%
%% Outputs
% * |COV| = array of covariates (ExRev and Distance);
% * |TAC| = array of total allowable catch;
% * |EC| = array of expected catch;
% * |AB| = array of location-specific abundance;

 % PARAMETERS
    T = par.periods;            % Number of periods
    S = par.species;            % Number of species
    N = par.individuals;        % Number of individuals
    J = par.locations;          % Number of locations
    Y = par.years;              % Number of years
    q = par.catchability;       % Catchability coefficient
     
 % ABUNDANCE
    ab = abundance(par);    
    % Assume abundance is the same across all periods in a year
    ab = repmat(reshape(ab',[1 1 S J]),[N T 1 1]);      % Reshape abundance to be consistent with data
    % Concatenate across years
    AB = ab;
    for j = 1:(Y-1)
        AB = cat(5,AB,ab);
    end
    
 % EXPECTED CATCH
    EC = AB; 
    % Apply individual-specific catchability coefficients
    for j = 1:N
        EC(j,:,:,:,:) = q(j)*EC(j,:,:,:,:);
    end
    
 % OTHER SYSTEM_WIDE DATA
    TAC0 = par.TAC;
    TAC = repmat(TAC0,Y,1);
    % Year-varying TAC2
    if nargin<2, tac='static'; end
    switch tac
        case 'vary'
            a = linspace(-0.3,0,Y); % Note: if Y=1, linspace returns the second number.
            for j = 1:Y
                TAC(j,2) = TAC(j,2)*(1+a(j));
            end
    end
            
    
 % ALTERNATIVE-VARYING DATA (X)
  % Expected Revenue
    ExRev = zeros(N,T,1,J,Y);
    for s = 1:S
        ExRev = EC(:,:,s,:,:)*par.price(s) + ExRev;
    end
    
  % Distance from port (assuming port = location 1)
    n = par.gridsize;  % grid size
    [temp1,temp2] = meshgrid(0:n-1,0:n-1);
    dist = (temp1.^2 + temp2.^2).^0.5;
    dist = reshape(repmat(dist(:)',[N*T 1]),N,T,1,J);
    % Concatenate across years
    Dist = dist;
    for j = 1:(Y-1)
        Dist = cat(5,Dist,dist);
    end
    
  % Alternative-varying data matrix
    COV = cat(3,ExRev,Dist);
    
        
end