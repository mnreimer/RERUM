%% Monte Carlo Analysis
% * Filename: monte_carlo_analysis.m
% * Authors: Matt Reimer
% * Created: 02/02/18
% * Updated: 10/24/19
%
%% Description
% The script |monte_carlo_analysis| is the parent script for analyzing the
% Monte Carlo data and evaluating estimation and in-sample performance.
%
%% Notes
% Data must already be generated to use this script. Use |monte_caro_data|
% to generate data.
%
%% Preliminaries

 % Environment
  clc, clear
  close all
  directory = 'Documents/GitHub/RERUM';
  cd(homedir)
  cd(directory)
  addpath(genpath(pwd))
  
%% In-Sample Evaluation

 % Load data
  load('data/estimates random multi_start 1-200 28-Oct-2019.mat','data',...
      'estimates','parameters');
  
 % Calculate in-sample predictive performance
  inresults = evaluate_in(estimates,data,parameters); 
  
 % Calculate table of predictive performance metrics and dgp parameters
  T = performance_table(inresults,estimates,parameters);
  
 % Figures of quantile regressions of performance metrics
  export = 'no';
  h = fig_quantreg(T,export);

 % Figure of in-sample predictive performance
  export = 'no';
  f = fig_insample(inresults,export);
  

 
  
  
  
  
