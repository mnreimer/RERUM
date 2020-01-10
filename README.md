# The Rational Expectations Random Utility Maximization (RERUM) Model
### Modeling location choice in a multispecies catch-share fishery
***
### Purpose
This project develops a model of spatiotemporal fishing behavior that incorporates the dynamic and general equilibrium elements of catch-share fisheries. We construct an estimation strategy that is able to recover structural behavioral parameters through a nested fixed-point maximum likelihood procedure. The modeling approach is illustrated through a Monte Carlo analysis. We demonstrate its importance for predicting out-of-sample counterfactual policies.

The corresponding paper associated with this project is:  
Reimer, M.N., J.K. Abbott, and A.C. Haynie (2020) "Structural Behavioral Models for Rights-Based Fisheries"
***

### Main scripts

Script Name                                | Description
-------------------------------------------|-----------------------------------------
parent_script.R                            | A guide for how to generate data and estimate the RERUM model.
monte_carlo_data.m                         | Generates data and estimates from the data generating process. Data are either generated with a random draw from the parameter space or using a pre-determined set of parameters.
monte_carlo_analysis.m                     | Analyzes the Monte Carlo data and evaluates estimation and in-sample performance.
policy_simulations.m                       | Generates policy simulations for bycatch TAC reductions and hot-spot closures.

***

### Matlab Toolboxes
- Optimization Toolbox
- Parallel Computing Toolbox  (Monte Carlo draws are computed in parallel)
- Statistics and Machine Learning Toolbox (only for the evrnd() function)
