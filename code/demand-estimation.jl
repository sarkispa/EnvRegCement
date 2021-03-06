using CSV
using DataFrames
using Statistics
using Impute
using FixedEffectModels

codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"
include(codeFolder * "demand-data.jl")

# describe(df)
# aggregate(df[:, 3:10], std)

# Demand curve estimation

## Specification I
## No covariates, no fixed effects
reg(df, @model(lq ~ (lp ~ wage96 + gas96 + elec96 + coal96)))

## Specification II
## Log-pop., no fixed effects
reg(df, @model(lq ~ lpop + (lp ~ wage96 + gas96 + elec96 + coal96)))

## Specification III
## No covariates, fixed effects
specIII = reg(df, @model(lq ~ (lp ~ wage96 + gas96 + elec96 + coal96), fe=mcat), save=true)
### Save results
df[:mconst] = fes(specIII).mcat
α_1 = specIII.coef[1]
## Specification IV
## Log-pop., fixed effects
reg(df, @model(lq ~ lpop + (lp ~ wage96 + gas96 + elec96 + coal96), fe=mcat))

## Specification V
## Log-pop. + log permits, no fixed effects
reg(df, @model(lq ~ lpop + lpermits + (lp ~ wage96 + gas96 + elec96 + coal96)))

## Specification VI
## Log-pop. + log permits, fixed effects
reg(df, @model(lq ~ lpop + lpermits + (lp ~ wage96 + gas96 + elec96 + coal96), fe=mcat))


# Store results for future purposes
vMkts = string.(unique(df[:region]))
dα_0 = Dict()

dfDemandParams = by(df, :region, α_0 = :mconst => mean)

for i in 1:length(vMkts)
    dα_0[dfDemandParams[:region][i]] = dfDemandParams[:α_0][i]
end
dα_0
regiontoconst(region) = dα_0[region]
