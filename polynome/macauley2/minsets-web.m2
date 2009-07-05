load "RevEng.m2"

minsetsWD = method();
minsetsWD(List,String,ZZ,ZZ) := (WT, outfile, p, n) -> (
--minsetsWD(List,ZZ,ZZ) := (WT, p, n) -> (

k=ZZ/p;
R = k[makeVars n];
TS = readTSData(WT,{},k);
MS = apply(gens R, x->last minSetScoring(TS,x));
--apply((gens R)/index, i->minSets(TS,i+1,R))

--filename = "data.dot";
--filename = concatenate("graph-",first WT, ".dot");
file = openOut outfile;
file << "digraph { \n";

L = apply(MS, p->(keys first last p => first p))/toString;
L = apply(L, s->replace("=>","->",s));
L = apply(L, s->replace(",",";",s));
L = apply(L, s->replace("=>","->",s));

apply(L, l->(file << l << ";" << endl));
file << "}" << endl << close;

)


minsets = method();
minsets(List,String,ZZ,ZZ) := (WT, outfile, p, n) -> (

k=ZZ/p;
R = k[makeVars n];
TS = readTSData(WT,{},k);
MS = apply(n, i->first minSets(TS,i,R));
FD = apply(n, i->functionData(TS,i+1));
FS = apply(n, i->findFunction(FD_i,MS_i)); 

--file = openOut concatenate(last separate("l-", first separate(".", first WT)), ".functionfile.txt");
file = openOut outfile;
apply(n, i->(file << "f" << i+1 << " = " << toString FS_i << endl));
file << close;

)



