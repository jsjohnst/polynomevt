#!/usr/bin/env ruby
# generate a truth table over F2 for conways game of life
 
# This is a fake Conway's Game of Life - we work on an n x n grid, so the
# corners only have three neighbors, and agents at the boundary have 5
# neighbors.  

if ARGV.length != 1
	puts "Usage: #{$0} <neighbors>"
	exit(1)
end

# if you change pvalue, make sure you change evaluate below
pvalue = 3

def evaluate(x, function)
  x = x.clone.unshift(0)
  f = eval(function)
  f < 1 ? 0 : f > 1 ? 2 : 1
end

number_of_genes = ARGV[0].to_i
function = ARGV[1].gsub(/x(\d+)/, 'x[\1].to_i') 

for i in 0..pvalue**number_of_genes-1 do 
   # convert integer into array with its binary representation and fill with
   # zeros
   input_data = ("%0#{number_of_genes}d" % i.to_s(pvalue)).split(//)
   output_data = evaluate(input_data, function)
   puts input_data.join(" ") + " " + output_data.to_s 
end

