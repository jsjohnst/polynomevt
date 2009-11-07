
# generate a truth table over F3 for threshold functions
 
## input: 
# number of genes
#  + - signs to indicate whether a gene up or down regulates
# example: [+,-,-] means 


# f is not the correct polynomial over F3
# x1 = 0
# x2 = 1
# x3 = 0 
# it should go to 0 
# but f (0,1,0) = - 1 = 2

# correctly: 
#    0   if f <= 0
#F = 1   if f == 1
#    2   if f >= 2

def evaluate(x, function)
  x = x.clone.unshift(0)
  f = eval(function.gsub(/x(\d+)/, 'x[\1].to_i'))
  f < 1 ? 0 : f > 1 ? 2 : 1
end
function = "x1 - x2 - x3*x1 + x5 - 2*x4"
number_of_genes = 5

for i in 0..3**number_of_genes-1 do 
   # convert integer into array with its binary representation and fill with
   # zeros
   input_data = ("%0#{number_of_genes}d" % i.to_s(3)).split(//)
   output_data = evaluate(input_data, function)
   print input_data.join(" ") + " " + output_data.to_s 
   puts
   # write to file ( input_data.push(output_data) )
end

