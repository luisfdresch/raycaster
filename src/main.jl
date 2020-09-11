# Importing packages
using Colors
using Plots

# Defining canvas size
width = 400
height = 300


# Creating canvas array
A = Array{RGB{},2}(undef, height , width)
A = fill!(A,0.0)

# Plotting array
plot(A)


