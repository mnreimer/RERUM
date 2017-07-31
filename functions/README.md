# Fishery Choice Model Functions
### Contains functions used in simulation model.

***

Script Name     | Description
----------------|-------------
func.m          | Returns the expected reward and the catch for a single fishery, at time t for individual i
vmax.m          | Returns the fishery that maximizes the reward, at time for individual i
xdemand.m       | Returns the fleet-wide annual excess demand for quota, for species s
equil.m         | Returns the difference between quota demand and supply. Used for finding the quota prices that clear the market.
qlease.m        | Returns the expected end-of-season quota prices, given information state variables.

## Credit:
### CompEcon Toolbox
Some of the functions for the collocation methods contained in qlease.m were originally developed by Miranda and Fackler, Applied Computational Economics and Finance, MIT Press: Cambridge, MA, 2002, p 510.
