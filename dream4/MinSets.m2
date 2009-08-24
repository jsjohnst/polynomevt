newPackage(  "MinSets" ,
        Version => "0.1", 
        Date => "August 23, 2009")

needs "PolynomialDynamicalSystems.m2"

export{AvoidL,
	IncludeL,
minsetsWD,
minsetsPDS,Ssublist
}


minsetsWD = method(Options => {AvoidL => null, IncludeL => null})
minsetsWD(List,String,ZZ,ZZ) :=opts-> (WT, outfile, p, n) -> (
    k := ZZ/p;
    R := k[makeVars n];
    TS := readTSData(WT,{},k);

AL:=opts.AvoidL;
IL:=opts.IncludeL;
VAL:={};VIL:={};

    if AL=!=null then (for i to n-1 do (if AL_i=={} then VAL=append(VAL,{}) else VAL=append(VAL,flatten {(gens R)_(AL_i-(for j to #AL_i-1 list 1))}));) else VAL=(for j to n-1 list null);

    if IL=!=null then (for i to n-1 do (if IL_i=={} then VIL=append(VIL,{}) else VIL=append(VIL,flatten {(gens R)_(IL_i-(for j to #IL_i-1 list 1))}));) else VIL=(for j to n-1 list null);

    MS := apply(n, i->last minSetScoring(TS,R_i,PolynomialDynamicalSystems$Avoid=>VAL_i,PolynomialDynamicalSystems$Include=>VIL_i));

    file := openOut outfile;
    file << "digraph { \n";

rMS:={};for i to n-1 do (if last MS_i=={} then (file << toString R_i;file << "; \n") else rMS=append(rMS,MS_i));
    
    L := apply(MS, x->(keys first last x => first x))/toString;
    L = apply(L, s->replace("=>","->",s));
    L = apply(L, s->replace(",",";",s));
    L = apply(L, s->replace("=>","->",s));
    
    apply(L, l->(file << l << ";" << endl));
    file << "}" << endl << close;
)

minsetsWD(String,String,ZZ,ZZ) :=opts-> (infile, outfile, p, n) -> (
    k := ZZ/p;
    R := k[makeVars n];
    TS := readTSData(infile,k);

AL:=opts.AvoidL;
IL:=opts.IncludeL;
VAL:={};VIL:={};

    if AL=!=null then (for i to n-1 do (if AL_i=={} then VAL=append(VAL,{}) else VAL=append(VAL,flatten {(gens R)_(AL_i-(for j to #AL_i-1 list 1))}));) else VAL=(for j to n-1 list null);

    if IL=!=null then (for i to n-1 do (if IL_i=={} then VIL=append(VIL,{}) else VIL=append(VIL,flatten {(gens R)_(IL_i-(for j to #IL_i-1 list 1))}));) else VIL=(for j to n-1 list null);

    MS := apply(n, i->last minSetScoring(TS,R_i,PolynomialDynamicalSystems$Avoid=>VAL_i,PolynomialDynamicalSystems$Include=>VIL_i));

    file := openOut outfile;
    file << "digraph { \n";

rMS:={};for i to n-1 do (if last MS_i=={} then (file << toString R_i;file << "; \n") else rMS=append(rMS,MS_i));
    
    L := apply(rMS, x->(keys first last x => first x))/toString;
    L = apply(L, s->replace("=>","->",s));
    L = apply(L, s->replace(",",";",s));
    L = apply(L, s->replace("=>","->",s));
    
    apply(L, l->(file << l << ";" << endl));
    file << "}" << endl << close;
)

Ssublist :=(ll,L)->(T:=false;for i to #L-1 do (l:=L_i;t:=true; for j to #l-1 do (if not member(l_j,ll) then t=false);if t==true then T=true);T);



minsetsPDS = method(Options => {AvoidL => null, IncludeL => null});
minsetsPDS(List,String,ZZ,ZZ) :=opts->(WT, outfile, p, n) -> (
    k := ZZ/p;
    R := k[makeVars n];
    TS := readTSData(WT,{},k);

AL:=opts.AvoidL;
IL:=opts.IncludeL;
VAL:={};VIL:={};

    if AL=!=null then (for i to n-1 do (if AL_i=={} then VAL=append(VAL,{}) else VAL=append(VAL,flatten {(gens R)_(AL_i-(for j to #AL_i-1 list 1))}));) else VAL=(for j to n-1 list null);

    if IL=!=null then (for i to n-1 do (if IL_i=={} then VIL=append(VIL,{}) else VIL=append(VIL,flatten {(gens R)_(IL_i-(for j to #IL_i-1 list 1))}));) else VIL=(for j to n-1 list null);

    FullMS := apply(n, i->minSets(TS,i+1,R));
    MS := apply(n, i->keys first last last minSetScoring(TS,R_i,PolynomialDynamicalSystems$Avoid=>VAL_i,PolynomialDynamicalSystems$Include=>VIL_i));

    FD := apply(n, i->functionData(TS,i+1));

    FS:={};for i to n-1 do (if Ssublist(MS_i,FullMS_i) then FS=append(FS,findFunction(FD_i,MS_i)) else FS=append(FS,"?"));

    file := openOut outfile;
    apply(n, i->(file << "f" << i+1 << " = " << toString FS_i << endl));
    file << endl << close;
)

minsetsPDS(String,String,ZZ,ZZ) := opts->(infile, outfile, p, n) -> (
    k := ZZ/p;
    R := k[makeVars n];
    TS = readTSData(infile,k);
AL:=opts.AvoidL;
IL:=opts.IncludeL;
VAL:={};VIL:={};

    if AL=!=null then (for i to n-1 do (if AL_i=={} then VAL=append(VAL,{}) else VAL=append(VAL,flatten {(gens R)_(AL_i-(for j to #AL_i-1 list 1))}));) else VAL=(for j to n-1 list null);

    if IL=!=null then (for i to n-1 do (if IL_i=={} then VIL=append(VIL,{}) else VIL=append(VIL,flatten {(gens R)_(IL_i-(for j to #IL_i-1 list 1))}));) else VIL=(for j to n-1 list null);

    FullMS := apply(n, i->minSets(TS,i+1,R));
    MS := apply(n, i->keys first last last minSetScoring(TS,R_i,PolynomialDynamicalSystems$Avoid=>VAL_i,PolynomialDynamicalSystems$Include=>VIL_i));

    FD := apply(n, i->functionData(TS,i+1));

    FS:={};for i to n-1 do (if Ssublist(MS_i,FullMS_i) then FS=append(FS,findFunction(FD_i,MS_i)) else FS=append(FS,"?"));
    file := openOut outfile;
    apply(n, i->(file << "f" << i+1 << " = " << toString FS_i << endl));
    file << endl << close;
)


