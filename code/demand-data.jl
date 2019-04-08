# Input file
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
df = CSV.read(dataFolder * "cementDec2009.csv")

# Correct name for Nebraska
df[:region] = [df[:region][i] == "IANBSD" ? "IANESD" : df[:region][i] for i in 1:size(df,1)]

# Data treatment
df[:mcat] = categorical(df[:region]) # for region fixed-effects
df[:lq] = log.(df[:shipped])
df[:lp] = log.(df[:price])
df[:lpop] = log.(df[:population])
df[:lpermits] = log.(df[:totalpermits])
