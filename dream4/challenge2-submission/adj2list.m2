--fin = infile
--fout = outfile

a = lines get fin;
a = apply(a, l->separateRegexp(" +",l)/value);
a = rsort flatten for i from 0 to #a-1 list
for j from 0 to #a-1 list
if ((a_i_j!=0) and (i!=j)) then (a_i_j,j+1,i+1) else continue                                          

f = openOut fout;
apply(a, l->f<<toString(l_1)|" "|toString(l_2)|" "|toString(l_0)<<endl)
f << close;
