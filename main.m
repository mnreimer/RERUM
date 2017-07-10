%% MAIN FILE
% * Filename: main.m
% * Authors: Matt Reimer
% * Created: 07/07/17
% * Purpose: Execute code to solve the rational expectations fishery choice
% model.


%% Preliminaries
    clc, clear
    close all
    
%% Parameters and Data 
    [m,fspace] = parameters;                    % Model parameters (see function file: parameters)
    load('data/ExpCatch.mat','EC','q')          % Expected catch and catchability data   
    [fish,sp,T] = size(EC);                     % Number of fisheries (including port), species, and periods
