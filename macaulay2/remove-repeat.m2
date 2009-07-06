--*********************
--File Name: remove-repeat.m2
--Author: Elena S. Dimitrova
--Original Date: 3/6/2009
--Descritpion: Merges consecutively repeated states (in the middle as well as at the end of a time series) into one. e2functionData is a modification of functionData from PolynomialDynamicalSystems package.
--Input: Field characteristic; number of variables; time series files
--Output: FD, a list of hashtables, where each contains the input-vectors/output pairs for each node; IN, a matrix of input vectors
--Usage: removeRepeatedStates(discretizedDataList, p, n)
--********************* 

needs "PolynomialDynamicalSystems.m2"
needs "Points.m2"

e2functionData = method(TypicalValue => FunctionData)
e2functionData(TimeSeriesData, ZZ) := (tsdata,v) -> (
     H = new MutableHashTable;

     -- first make the list of matrices
     mats = tsdata.WildType;
     scan(keys tsdata, x -> if class x === ZZ and x =!= v then mats = join(mats,tsdata#x));

     -- now make the hash table
     --c = 0;	
     scan(mats, m -> (
           e = entries m;
           --Merge consecutively repeated states into one state
           ee = {e#0};
           for i from 0 to #e-2 do (if e#i!=e#(i+1) then ee=append(ee,e#(i+1)));

           for j from 0 to #ee-2 do (
            tj = ee#j;
            val = ee#(j+1)#(v-1);

            --if H#?tj and H#tj != val then (c=c+1; return c);
              --error ("function silly: point " | 
                  -- toString tj| " has images "|toString H#tj|
                  -- " and "|toString val);           
            H#tj = val;
            )));

    new FunctionData from H
)


removeRepeatedStates = method();
removeRepeatedStates(List, ZZ, ZZ) := (WT, p, n) -> (

	k = ZZ/p; --Field

	--TS is a hashtable of time series data WITH NO KO DATA
	TS = readTSData(WT, {}, k);

	--FD is a list of hashtables, where each contains the input-vectors/output pairs for each node
	FD = apply(n, II->e2functionData(TS, II+1));

	--IN is a matrix of input vectors
	IN = matrix keys first FD;
)

end
----------------------------------------------------- end of file---------------------------------------------------
