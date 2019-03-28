using CSV
using DataFrames

#IO
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
df = CSV.read(dataFolder * "cementDec2009.csv")

df[1:5,:]

df[:region] = [df[:region][i] == "IANBSD" ? "IANESD" : df[:region][i] for i in 1:size(df,1)]

#Data cleaning
df[:constant] = ones(length(df[:region]))

df[:mcat] = categorical(df[:region])
df[:ycat] = categorical(df[:year])

df[:lq] = log.(df[:shipped])
df[:lp] = log.(df[:price])
df[:lpop] = log.(df[:population])
df[:lpermits] = log.(df[:totalpermits])


unique(df.region)
