--*********************
--File Name: remove-repeat.m2
--Author: Elena S. Dimitrova
--Original Date: 3/6/2009
--Descritpion: Merges consecutively repeated states (in the middle as well as at the end of a time series) into one. e2functionData is a modification of functionData from PolynomialDynamicalSystems package.
--Input: Field characteristic; number of variables; time series files
--Output: FD, a list of hashtables, where each contains the input-vectors/output pairs for each node; IN, a matrix of input vectors
--********************* 

load "PolynomialDynamicalSystems.m2"
load "Points.m2"
p = 5; --Field characteristic (MUST come as input)
k = ZZ/p; --Field
n = 4; --Number of variables (MUST come as input)
WT={"toy.txt"}; --Input data files (MUST come as input)

     TS = readTSData(WT, {}, k);
-- make the list of matrices
     mats = TS.WildType;
     scan(keys TS, x -> if class x === ZZ and x =!= v then mats = join(mats,TS#x));

 scan(mats, m -> (
           e = entries m;
           --Merge consecutively repeated states into one state
           ee = {e#0};
           for i from 0 to #e-2 do (if e#i!=e#(i+1) then ee=append(ee,e#(i+1)));
));


end
----------------------------------------------------- end of file---------------------------------------------------