--*********************
--File Name:	Discretize-interval.m2
--Author: 	Elena S. Dimitrova
--Original 	Date: 11/2/2009
--Description: Discretizes the input data using user provided thresholds. 
--Input: 	Number of variables; time series files; threshlds (number must be prime-1); output file name(s)
--Output: 	File(s) with the discretized data:
--		If a single file is input/output, then multiple time series are separated by hash marks (#)
--Usage:      discretize(infile, num_nodes, thresholds, outfile)
--********************* 

needs "PolynomialDynamicalSystems.m2"

discretize = method()

discretize(String, ZZ, List, String) := (infile, n, thresholds, outfile) -> (
    if not isPrime (#thresholds+1) then error "Expected a prime number of discretization intervals";
	
    m:={};
    discrm:={};
    count:={};
    mat := flatten values readRealTSData(infile,RR);
    
    apply(#mat, s -> (
        m = append(m, entries mat#s); 
        count=append(count, #(entries mat#s))
    ));
    
    m=transpose flatten m;
    thr := sort thresholds;	
    
    for j from 0 to #m-1 do (
        dis={}; 
        apply(#(m#j), i->(discrval=0; apply(#thr, s->(if m#j#i >= thr#s then discrval=s+1)); dis=append(dis, discrval);));	     
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
