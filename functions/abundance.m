%% Spatial Abundance Data
% * Filename: abundance.m
% * Authors: Matt Reimer
% * Last Updated: 10/26/18
% * Purpose: Generates spatial abundance data that is used in the location 
% choice model.
%
%% Description
% The function |abundance| returns a nXn grid of abundance for each of $S$
% species. Each species is assumed to be distributed over the grid 
% according to a two-dimensional normal distribution, ala Reimer et al. 
% (2017).

function [F,Fg] = abundance(par)
%% Input Arguments
% * |par| = structural array of parameters
%
%% Output Arguments
% * |F| = Abundance (linearized)
% * |Fg| = Abundance (in grid form)
% 
%% Notes
% * Called by: |dgpdata|
%
%% Function Parameters
    n = par.gridsize;           % Grid size (# locations = n^2)
    mu = par.mu;                % Peak (or mode) of the spatial distribution
    Sigma = par.spread;         % Spread (or variance) of the spatial distribution
    abundance = par.abundance;  % Overall abundance of species    
    UB = n/2; LB = -(n/2);      % Normalize boundaries for spatial grid.
    Y0 = 1;                     % Starting location (linear index) 
    species = size(Sigma,3);    % Number of species
    
%% Spatial Distribution of Species

% Generate Grid 
    [x,y] = deal(linspace(LB,UB,n));
    [X,Y] = meshgrid(x,y);

% Mean Relative Distributions 
    F = zeros(n^2,species);
    Fg = zeros(n,n,species);
    for s = 1:species
        F(:,s) = mvnpdf([X(:) Y(:)],mu(s,:),Sigma(:,:,s));
        xx = min(F(:,s)); F(:,s) = F(:,s) - xx;     % Anchor abundance to zero
        F(Y0,s) = 0 ;                               % Port has no abundance
        int = sum(F(:,s));                          % Integral of abundance over all cells
        F(:,s) = abundance(s)*(F(:,s)/int);         % Scale to total abundance
        Fg(:,:,s) = reshape(F(:,s),length(y),length(x));  % In grid form (for plotting)
    end

end

        
    