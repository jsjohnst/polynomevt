--*********************
--File Name:	Discretize-interval.m2
--Author: 	Elena S. Dimitrova
--Original Date:9/22/2009
--Description: 	Discretizes the input data using interval discretization. 
--Input: 	Number of variables; time series files; prime number of intervals; output file name(s)
--Output: 	File(s) with the booleanized data:
--		If a single file is input/output, then multiple time series are separated by hash marks (#)
--Usage:        discretize(infile, num_nodes, num_intervals, outfile)
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
    
    for j from 0 to #m-1 do (
        dis:={}; 
        msort=sort m#j;
        minval=msort#0;
        maxval=msort#(#msort-1);
	 intwidth=(maxval - minval)/p;

        apply(#(m#j), i->(apply(p, s->(if m#j#i >= minval+s*intwidth then discrval=s)); dis=append(dis, discrval);));
	     
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
