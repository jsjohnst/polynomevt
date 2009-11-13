--*********************
--File Name:	Discretize-quantile.m2
--Author: 	Elena S. Dimitrova
--Original 	Date:9/22/2009
--Description: Discretizes the input data using quantile discretization. 
--Input: 	Number of variables; time series files; prime number of intervals; output file name(s)
--Output: 	File(s) with the discretized data:
--		If a single file is input/output, then multiple time series are separated by hash marks (#)
--Usage:      discretize(infile, num_nodes, num_intervals, outfile)
--********************* 

needs "PolynomialDynamicalSystems.m2"

discretize = method()

discretize(String, ZZ, ZZ, String) := (infile, n, p, outfile) -> (
    if not isPrime p then error "Expected a prime integer";
    
    m:={};
    discrm:={};
    count:={};
    mat := flatten values readRealTSData(infile,RR);
    
    apply(#mat, s -> (
        m = append(m, entries mat#s); 
        count=append(count, #(entries mat#s))
    ));
    
    m=transpose flatten m;
    --quant = floor(n/p);
    
    for j from 0 to #m-1 do (
        dis:={}; 
 	 thr:={};
	 msort=m#j;
        mst=set msort;
	 quant=floor(#mst/p);
	 msort=toList mst;
	 msort= sort msort;
	 print msort;
	 if #msort < p then error "Insufficient number of distinct value for a variable.";
	 for k from 0 to p-2 do (
	 thr=append(thr, msort#(k*quant)););
	print thr;
       
	apply(#(m#j), i->(discrval=0; apply(#thr, s->(if m#j#i > thr#s then discrval=s+1)); dis=append(dis, discrval);));	     
       discrm=append(discrm, dis);
    );
    c:=0;
    file:=openOut outfile;
    for f from 0 to #mat-1 do (
	file << "#TS" << toString(f+1) << endl;
        for i from 0 to count#f-1 do (
            for j from 0  to #((transpose discrm)#(c+i))-1 do (
                file<<(transpose discrm)#(c+i)#j<<" ";
            );
            file << endl; 
        );
        c=c+count#f;
    );
    file<<close;
)

end
----------------------------------------------------- end of file---------------------------------------------------
