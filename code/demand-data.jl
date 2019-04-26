using CSV
using DataFrames
using Statistics

# Input file
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
df = CSV.read(dataFolder * "cementDec2009.csv")

#df = by(df, [:region, :year], shipped = :shipped => sum, price = :price => mean, wage96 = :wage96 => mean, coal96 = :coal96 => mean, elec96 = :elec96 => mean, gas96 = :gas96 => mean, population = :population => sum, totalpermits = :totalpermits => sum )

# Correct name for Nebraska
df[:region] = [df[:region][i] == "IANBSD" ? "IANESD" : df[:region][i] for i in 1:size(df,1)]

# Data treatment
df[:mcat] = categorical(df[:region]) # for region fixed-effects
df[:lq] = log.(df[:shipped])
df[:lp] = log.(df[:price])
df[:lpop] = log.(df[:population])
df[:lpermits] = log.(df[:totalpermits])
