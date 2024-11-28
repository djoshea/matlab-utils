function x = center(x, dims)

x = x - mean(x, dims, "omitmissing");

end