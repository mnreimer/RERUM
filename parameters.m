%% Parameters
% * Filename: parameters.m
% * Authors: Matt Reimer
% * Created: 06/11/19
% * Updated: 12/08/19
% * Purpose: This function contains the default parameter values that are 
% used in the fishery choice simulation. 
%
%% Description
% The file |parameters| is a class definition file, which returns objects
% that contain the default parameters that govern the data generating
% process considered in the main paper. Using a class definition for
% setting parameters creates a lot of flexibility for changing a single (or
% set of) parameter values. This file is the main file for setting default
% parameter values.
%
%% Notes
% * There are several ways to change parameter values from their default
% values. To change a single parameter, the easiest way is to use dot
% indexing---e.g., to change the TAC in the object |par|, use
% |par.TAC=[1,2]|. To change several values all at once, use 
% |par = set(par,{TAC,btrue},{[1,2],[1,-1]})|.
%
classdef parameters
    
  %% PROPERTIES
    % Default Values
    properties
        years = 1           % Number of years
        periods = 50        % Number of periods in a year
        individuals = 20    % Number of indviduals (or fishers)
        gridsize = 10       % Grid size (locations = gridsize^2)
        species = 2         % Number of species
        btrue = [1;-0.4]    % True preference params [Rev ; Dist];
        u = 0               % Location parameter (for Extreme Value distribution)
        gamma = 1           % Scale parameter (for Extreme Value distribution)
        sigma = 3           % Variance of harvesting shock (log normal distribution)
        Y0 = [1,1];         % Starting Location (Port)
        tac = ...           % TAC (as a porportion of abundance)
          [1.3e-2,0.7e-2];  
        random = 'no';      % Indicator of random draws from parameter space
        price = [1000;0];   % Ex-vessel price
        mu = [-2.5,2.5 ...
            ; 2.5,-2.5];    % Mean of Spatial distribution
    end
    
    % Dependent Parameters
    properties (Dependent)
        TAC                 % Total Allowable Catch (absolute)
        abundance           % Abundance
        locations           % Number of locations (including port)
        catchability        % Catchability Coefficient
        spread              % Variance (or spread) of Spatial Distribution
    end
  
  %% METHODS     
    methods
         
        % Stochastic Parameters
        function obj = parameters(val)
            if nargin > 0
                rng(val)                         % Seed number
                obj.years = randi([1,4]);        % Number of years
                obj.periods = randi([25,50]);    % Number of periods in a year
                obj.individuals = randi([30,70]);% Number of indviduals (or fishers)
                obj.gridsize = randi([6,10]);    % Grid size (locations = gridsize^2)
                obj.species = randi([1,4]);      % Number of species
                obj.btrue = [0.5 + 1*rand ; ...
                    -0.1 + -0.4*rand];           % True preference params [Rev ; Dist];
                obj.sigma = 0.1 + 4.9*rand;      % Variance of harvesting shock (log normal distribution)
                obj.tac = 0.8e-2 + 0.7e-2*rand(1,4); % TAC (proportion): UB = max # species
                obj.random = 'yes';
            end
        end
        
        % Abundance: Function of # Species
        function val = get.abundance(obj)
            S = obj.species;
            val = 1e3*ones(1,S);
        end
        
        % TAC: Function of # Species (Up to 10 max)
        function val = get.TAC(obj)
            S = obj.species;
            A = obj.abundance;
            x = obj.tac;
            % TAC in absolute terms
            for s = 1:S
                val(s) = x(s)*A(s);
            end
        end
        
        function val = get.price(obj)
            S = obj.species;
            r = obj.random;
            p = obj.price;
            switch r
                case 'yes'
                    val = 500 + 1000*rand(S,1);
                case 'no'
                    val = p;
            end
        end
        
        % Locations
        function val = get.locations(obj)
            val = obj.gridsize^2;
        end
        
        % Catchability: scaled by locations, periods, and individuals
        function val = get.catchability(obj)
            J = obj.locations;
            T = obj.periods;
            N = obj.individuals;
            val = (J/100)*(1/(T*N))*ones(1,N);
        end
        
        % mu: "Peak" (or center) of spatial distribution
        function val = get.mu(obj)
            S = obj.species;
            r = obj.random;
            m = obj.mu;
            switch r
                case 'yes'
                    val = 0.5 + randi([0,5],S,2);
                case 'no'
                    val = m;
            end
        end
        
        
        % Spread: Spatial distribution spread
        function val = get.spread(obj)
            S = obj.species;
            n = obj.gridsize;
            r = obj.random;
            % Upper and lower bounds
            UB = n/2; LB = -(n/2);      % normalize boundaries for spatial grid.
            L = (UB - LB);              % Length of y- and x-axis   
            % Spread
            switch r
                case 'yes'
                    V = 7 + 2*rand;             % Variance Scalar
                case 'no'
                    V = 8;
            end
            for s = 1:S
              val(:,:,s) = [V*L,0;0,V*L];        % Variance matrix proportional to grid length
            end
        end
        
        % Manually set property values
        function obj = set(obj,property,val)
            for i = 1:numel(property)
                if isprop(obj,property{i})
                    obj.(property{i}) = val{i};
                end
            end
                
        end
    end
    
end

        