%% Quota lease price function
% * Filename: qlease.m
% * Authors: Matt Reimer
% * Created: 07/08/17
% * Purpose: Function that returns the expected lease price for a given set
% of state variables.
%
%% Description
% The function |qlease| returns the expected end-of-season quota lease
% price given a common set of exogenous state variables.
%
% In any period $t$, fishers are assumed to form a common forecast of the 
% end-of-season quota prices, and based on that forecast, the fishery that 
% is optimal is chosen. We assume that forecasts are based on fleet-wide 
% information that is observed at the beginning of the period prior to 
% making a fishery decision. In this sense, fishers observe the aggregate 
% state of the world and update their expectations over future quota 
% prices. Let $I_{t,s}$ represent a $K\times 1$ vector of aggregate state 
% variables. Then the period $t$ forecast of end-of-season quota lease 
% prices $w_{t,s}$ can be represented by the following parametric 
% function:
%
% $$ w_{t,s}=w \left( I_t ;\eta \right) $$
%
% where $\eta$ is a matrix of parameters whose values are determined in 
% equilibrium.
%
% To start, we assume that: 
%
% # $I_t = [Z_t, t]$, where $Z_t$ denotes fleet-wide cumulative catch up to 
% period $t$;
% # The forecast function is quadratic: $w_t=I_t' \eta I_t$.
%
function w = qlease(I,eta)
%% Input arguments:
% * |I| = an Sxvector of state variables, one for each species;
% * |eta| = matrix of parameters;
%
%% Output arguments:
% * |out1| = expected quota lease price;
%
%% Notes:
%
%% Calculate price for each species




