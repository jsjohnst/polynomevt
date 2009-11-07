#!/usr/bin/env ruby
# generate a truth table over F3 for threshold functions
 
# function is not the correct polynomial over F3
# x1 = 0
# x2 = 1
# x3 = 0 
# it should go to 0 
# but f (0,1,0) = - 1 = 2

# correctly: 
#    0   if f <= 0
#F = 1   if f == 1
#    2   if f >= 2

if ARGV.length != 2
	puts "Usage: #{$0} <nodes> <function>"
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

