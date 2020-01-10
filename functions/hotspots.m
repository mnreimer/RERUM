%% Bycatch hot-spots
% * Filename: hotspots.m
% * Authors: Matt Reimer
% * Created: 9/17/18
% * Updated: 10/24/19
%
%% Description
% The function |hotspots| is used to find bycatch hotspots based
% on baseline fishing data. Used extensively for generating data under
% counterfactual hotspot closure policies.
%
%% Notes
% * Called by: |evaluate_out|
%
function [C,closed] = hotspots(D,closures,par)
%% Input arguments
% * |D| = a structural array of data of locations choices and harvests;
% * |closures| = a scalar indicating the number of closures
% * |par| = a structural array of parameters.
%
%% Output arguments
% * |C| = a vector of cumulative bycatch, by location
% * |closed| = a vector of closed areas, given a number of closures
%
%% Cumulative bycatch (from baseline data)
 % Preallocate catch vector
 C = zeros(par.locations,1);    
 
 % Loop through n and t to determine cumulative catch, by area j
 for n = 1:par.individuals
     for t = 1:par.periods
         j = D.choice(n,t);
         if isnan(j), break, end   % Indicates a season ended early
         C(j) = D.harvest(n,t,2) + C(j); % Harvest by location
     end
 end
 
%% Hotspots: Find largest bycatch areas
if nargout > 1
 [~,closed] = maxk(C,closures,1);
end
 
end

