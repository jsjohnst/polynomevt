--*********************
--File Name: incons.m2
--Author: Elena S. Dimitrova
--Original Date: 3/10/2009
--Descritpion: Removes inconsistencies from input data by splitting time series at the point of inconsistency. ereadMat is a modification of readMat from the PolynomialDynamicalSystems package.
--Input: Number of variables; DISCRETIZED time series files
--Output: Files named "transition-i.txt", each containing a single transition, all consistent
--********************* 

--load "PolynomialDynamicalSystems.m2"
--load "Points.m2"
n = 3; --Number of variables (MUST come as nput)
--WT={"toy.txt","toy2.txt","toy4.txt"}; --(MUST come as input)
--WT={"Bool-toy.txt","Bool-toy2.txt"}; --(MUST come as input)
WT={"Bool-toy.txt"}; --(MUST come as input)


-- Given a data file and a coefficient ring, ereadMat returns the (txn)-matrix of the data (t=time, n=vars). 

ereadMat = method(TypicalValue => Matrix)
ereadMat(String,Ring) := (filename,R) -> (
     ss := select(lines get filename, s -> length s > 0);
     matrix(R, apply(ss, s -> (t := separateRegexp(" +", s); 
                 t = apply(t,value);
                     select(t, x -> class x =!= Nothing))))
)

transitions={}; --Contains every pair of transitions
m={};
trouble={};


apply(#WT, i-> (mt = apply({WT#i}, s -> ereadMat(s,ZZ)); --mt is a hash table of points from one input file
apply(#mt, s -> (m = append(m, entries mt#s))); m=flatten m; --m is a list of points from one input file
for j from 0 to #m-2 do ( transitions=append(transitions, {m#j, m#(j+1)}) );-- Record them as transitions
m={}; )  );

--Identify transitions that are inconsistent
select(transitions, i->(
t=select (transitions, j->(i#0==j#0 and i#1!=j#1));
if t != {} then trouble=append(trouble, t);
));
trouble=flatten trouble;

--Keep only the consistent transitions
consistent_transitions=set transitions-set trouble;
consistent_transitions=toList consistent_transitions;

--Print each transitions in a separate file
for i from 0 to #consistent_transitions-1 do ( fl="transition-"|i+1|".txt"; file=openOut fl;
for j from 0 to n-1 do (file << consistent_transitions#i#0#j << " "; );
file << endl;
for j from 0 to n-1 do (file << consistent_transitions#i#1#j << " "; );
file<<close;);


end
----------------------------------------------------- end of file---------------------------------------------------
