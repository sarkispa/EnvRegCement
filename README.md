# EnvRegCement

Replication of Stephen Ryan's ECMA 2012 article for the Empirical Methods in
Applied Micro Class.

## Code

Scripts for replication can be found in the code folder. I chose to write do the
replication using Julia instead of Stephen Ryan's choice of Java.

### Using the scripts

Each file in the code folder is designed to be run separately (for easier correction).
Following the structure of Stephen Ryan's paper:
   1. Demand estimation uses ```demand-estimation.jl```
   2. Cost function estimation uses ```costfun-estimation.jl```
   3. Investment estimation uses ```investment-estimation.jl```
   4. Entry estimation uses ```entry-estimation.jl```
   5. Exit estimation uses ```exit-estimation.jl```

All other scripts are not supposed to be run directly but are called by one of the previously cited script.

## Results

The results folder contains estimation results, optimization results (for all different
round of brute force/Powell), and graphs to show the difference between my results
and the ones in Stephen Ryan's paper. These graphs are based on the shared dataset
which is NOT the same as Ryan's dataset, thus it is perfectly normal to get different
results: I AM NOT QUESTIONING THE PAPER'S RESULTS.

## Data and original code

The data and original scripts are available through the article's website. For
the code in this repo to work, one needs to download them and add them to a folder
named "data", without changing the names of the files. Note however that the data
shared with the paper is not the actual data used in the paper. Some market definitions
are scrambled with others, and PA, TX, and CA are not separated correctly. Have a
look at the Mineral's Yearbooks to get a better sense of what has been modified.
