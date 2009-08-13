newPackage(
    "PolynomialDynamicalSystems",
        Version => "0.1", 
        Date => "November 21, 2005",
        Authors => {
         {Name => "Brandy Stigler", Email => "bstigler@mbi.osu.edu", HomePage => "http://users.mbi.ohio-state.edu/bstigler"},
         {Name => "Mike Stillman", Email => "mike@math.cornell.edu", HomePage => "http://www.math.cornell.edu/~mike"}
         },
        Headline => "Utilities for polynomial dynamical systems",
        DebuggingMode => true
        )

needs "Points.m2"

export{getVars,
       makeVars,
       see,
       TimeSeriesData, 
       FunctionData, 
       readMat,
       readRealMat,
       readTSData,
       readRealTSData,
       functionData,
       subFunctionData,
       minRep,
       findFunction,
       checkFunction,
	WildType
}


---------------------------------------------------------------------------------------------------
-- Declaration of new data types
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- TimeSeriesData: This hashtable stores time series data with values in a set k.
-- The data is (txn)-dimensional, where t=#timepoints-1, n=#variables.
-- keys   = time series labels
-- values = time series
--    key = Wildtype:    value = list of (txn)-matrices of wildtype time series
--    key = (i, file_i): value = list of (txn)-matrices of time series for ith knockout 

TimeSeriesData = new Type of HashTable
 
---------------------------------------------------------------------------------------------------
-- FunctionData: This hashtable defines a function f:k^n->k, where k is a finite field.
-- keys   = points in k^n (in domain of f)
-- values = points in k (in codomain of f)

FunctionData = new Type of HashTable


---------------------------------------------------------------------------------------------------
-- Utilities for working with polynomial dynamical systems
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Given an integer n, makeVars returns a list of n variables of type xi.

makeVars = method(TypicalValue => List)
makeVars(ZZ) := (n) -> apply(1..n, i -> value ("x"|i))

---------------------------------------------------------------------------------------------------
-- Given an element of a polynomial ring, getVars returns the list of variables in the polynomial.

getVars = method(TypicalValue => List)
getVars(ZZ) := (n) -> ({})
getVars(RingElement) := (f) -> (
    -- standard form of the monomials of f, i.e., no coefficients
    SF := apply(terms f, m -> first keys standardForm m);
    Vars := {};
    select(SF, h->if keys h!={} then Vars=append(Vars, keys h));
    Vars = sort unique flatten Vars;
    apply(Vars, e->e+1)
)

---------------------------------------------------------------------------------------------------
-- Given a list of elements, see prints out each element on a single line, followed by a hard return.

see = method()
see(List) := (fs) -> scan(fs, (g -> (print g; print "")))


---------------------------------------------------------------------------------------------------
-- Utilities for data processing
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Internal to "readTSData"
-- Given a data file and a coefficient ring, readMat returns the (txn)-matrix of the data (t=time, n=vars). 

readMat = method(TypicalValue => Matrix)
readMat(String,Ring) := (filename,R) -> (
     ss := select(lines get filename, s -> length s > 0);
     matrix(R, apply(ss, s -> (
--		t := separateRegexp(" +", s); 
		t := select(separateRegexp(" +", s), c->c!=""); 
                t = apply(t,value);
                select(t, x -> class x =!= Nothing)
     )))
)

readRealMat = method(TypicalValue => Matrix)
readRealMat(String,InexactFieldFamily) := (filename,R) -> (
     ss := select(lines get filename, s -> length s > 0);
     matrix(R, apply(ss, s -> (
--		t := separateRegexp(" +", s);
		t := select(separateRegexp(" +", s), c->c!="");
                t = apply(t,value);
                select(t, x -> class x =!= Nothing))
     ))
)



---------------------------------------------------------------------------------------------------
-- Given a list of wildtype and a list of knockout time series data files, as well as a coefficient ring,
-- readTSData returns a TimeSeriesData hashtable of the data.
-- Uses "readMat", except for the last version

readTSData = method(TypicalValue => TimeSeriesData)
readTSData(List,List,Ring) := (wtfiles, knockouts, R) -> (
     -- wtfiles: list of file names for wild type data series
     -- knockouts: list of pairs (i,filename), where
     --  i is an integer with which node gets knocked out (first variable has index 1).
     --  filename is the corresponding time series data
     -- output: TimeSeriesData

     wtmats := apply(wtfiles, s -> readMat(s,R));
     H := new MutableHashTable;
     scan(knockouts, x -> (
           m := readMat(x#1,R);
           i := x#0;
           if H#?i then H#i = append(H#i,m)
           else H#i = {m}));
     H.WildType = wtmats;
     new TimeSeriesData from H
)

readTSData(String,Ring) := (filename, R) -> (
    --filename contains several time series with a header of # preceding each one
    WT := lines get filename;
    WT = select(WT, l->#l>0);

    i := 0; l := WT_i;
    if match("#",l) then {i=i+1; l=WT_i;};
    T := {};
    while i < #(WT)-1 do
    {
        temp := {};
        while not match("#",l) do
        {
                temp = append(temp,l);
                if i == #(WT)-1 then break else
                {i=i+1; l=WT_i;};
        };
        T = append(T,temp);
        if i == #(WT)-1 then break else
        {i=i+1; l=WT_i;};
    };
--    T = apply(T, l->matrix(R,apply(l, s->separateRegexp(" +",s)/value)));
    T = apply(T, l->matrix(R,apply(l, s->select(separateRegexp(" +",s), c->c!="")/value)));
    H := new MutableHashTable;
    H.WildType = T;
    new TimeSeriesData from H
)

readRealTSData = method(TypicalValue => TimeSeriesData)
readRealTSData(String,InexactFieldFamily) := (filename, R) -> (
    --filename contains several time series with a header of # preceding each one
    WT := lines get filename;
    WT = select(WT, l->#l>0);

    i := 0; l := WT_i;
    if match("#",l) then {i=i+1; l=WT_i;};
    T := {};
    while i < #(WT)-1 do
    {
        temp := {};
        while not match("#",l) do
        {
                temp = append(temp,l);
                if i == #(WT)-1 then break else
                {i=i+1; l=WT_i;};
        };
        T = append(T,temp);
        if i == #(WT)-1 then break else
        {i=i+1; l=WT_i;};
    };
--    T = apply(T, l->matrix(R,apply(l, s->separateRegexp(" +",s)/value)));
    T = apply(T, l->matrix(R,apply(l, s->select(separateRegexp(" +",s), c->c!="")/value)));
    H := new MutableHashTable;
    H.WildType = T;
    new TimeSeriesData from H
)




---------------------------------------------------------------------------------------------------
-- Given time series data and an integer i, functionData returns the FunctionData hashtable for function i,
-- that is the input-output (vector-scalar) data pairs corresponding to node i, if consistent; 
-- else it returns an error statement.

functionData = method(TypicalValue => FunctionData)
functionData(TimeSeriesData, ZZ) := (tsdata,v) -> (
     H := new MutableHashTable;

     -- first make the list of matrices
     mats := tsdata.WildType;
     scan(keys tsdata, x -> if class x === ZZ and x =!= v then mats = join(mats,tsdata#x));

     -- now make the hash table
     scan(mats, m -> (
           e := entries m;
           for j from 0 to #e-2 do (
            tj := e#j;
            val := e#(j+1)#(v-1);
            if H#?tj and H#tj != val then
              error ("function inconsistent: point " | 
                   toString tj| " has images "|toString H#tj|
                   " and "|toString val);           
            H#tj = val;
            )));
     new FunctionData from H
)

---------------------------------------------------------------------------------------------------
-- Given function data (data for a function) and a list L of integers between 1 and n(=dim pds), 
-- corresponding to a subset of the set of variables, 
-- subFunctionData returns the function data projected to the variables in L, if consistent; 
-- else it returns an error statement.

subFunctionData = method(TypicalValue => FunctionData)
subFunctionData(FunctionData, List) := (fcndata,L) -> (
     H := new MutableHashTable;
     L = apply(L, j -> j-1);
     scan(keys fcndata, p -> (
           q := p_L;
           val := fcndata#p;
           if H#?q and H#q != val
           then error ("sub function inconsistent: point " | 
            toString q| " has images "|toString H#q|
            " and "|toString val);
           H#q = val;
           ));
     new FunctionData from H
)

---------------------------------------------------------------------------------------------------
-- Internal to getdiffs
-- Given 2 lists of points in k^n and a polynomial ring, getdiffs1 returns a monomial

getdiffs1 = method(TypicalValue => RingElement)
getdiffs1(List, List, Ring) := (p,q,R) -> ( 
     m := 1_R;
     scan(#p, i -> if p#i =!= q#i then m = m*R_i);
     m)

---------------------------------------------------------------------------------------------------
-- Internal to minRep; uses getdiffs1
-- Given 2 lists of lists of points in k^n, getdiffs returns a monomial ideal

getdiffs = method(TypicalValue => MonomialIdeal)
getdiffs(List, List, Ring) := (P,Q,R) -> ( 
     L := flatten apply(P, p -> apply(Q, q -> getdiffs1(p,q,R)));
     monomialIdeal L)

---------------------------------------------------------------------------------------------------
-- Previously called "sparseSets"

-- Given function data D for f_i, and a polynomial ring, minRep returns a monomial ideal.
-- Purpose of ideal: set of variables, one from each gen of the ideal, is the smallest #vars 
-- required for a consistent function; that is, the sets of vars needed for a minimal representation 
-- of the polynomial function defined by D.
-- If ideal is gen by m monomials, then sets have at most m elements

minRep = method(TypicalValue => MonomialIdeal)
minRep(FunctionData, Ring) := (fcndata,R) -> (
     Ps := apply(unique values fcndata, j -> select(keys fcndata, k -> fcndata#k === j));

     -- the next 2 commented lines were used for testing purposes
    -- print apply(Ps, a-> #a);
    -- time Ls := apply(subsets(Ps,2), x -> getdiffs(x#0,x#1,R));

     --the last 2 lines were replaced with
     apply(Ps, a-> #a);
     Ls := apply(subsets(Ps,2), x -> getdiffs(x#0,x#1,R));

     sum Ls
)

---------------------------------------------------------------------------------------------------
-- Uses subFunctionData
-- Given function data D for f_i and a list L of variables xi, i=1..n, (returned from minRep)
-- findFunction computes a polynomial in the vars in L that fit D.

findFunction = method(TypicalValue => RingElement, Options => {MonomialOrder=>null})
findFunction(FunctionData, List) := o -> (fcndata,L) -> (

-- need to let user specify a term order. may have to remove "monoid"
-- if L=={}, then perhaps default should be the whole ring;
-- in this case, perhaps "findFunction" should be redefined to accept only one input (FunctionData) 
-- need to check if the order of variables given matters.

     if #L === 0 then error "expected positive number of variables";
     R := ring L#0;
     Lindices := apply(L, x -> index x + 1);
     F := subFunctionData(fcndata,Lindices);
     S := (coefficientRing R)(monoid [L]);
     pts := transpose matrix keys F;
     vals := transpose matrix {values F};
     (A,stds) := pointsMat(pts,S);
     f := ((transpose stds) * (vals // A))_(0,0);
     substitute(f,R)
)

---------------------------------------------------------------------------------------------------
-- Given function data D for f_i and a polynomial g, check evaluates g on D and 
-- returns true if g fits D and false otherwise; in this case, it returns an error statement.
-- Used to check the results of findFunction

checkFunction = method(TypicalValue => Boolean)
checkFunction(FunctionData, RingElement) := (fcndata,f) -> (
     pts := transpose matrix keys fcndata;
     Fs := makeRingMaps(pts,ring f);
     k := keys fcndata;
     s := select(0..#k-1, i -> Fs#i(f) != fcndata#(k#i));
     sp := apply(s, i -> k#i);
     if #s === 0 then true
     else (print ("function FAILS on points "|toString sp); false)
)

     
---------------------------------------------------------------------------------------------------
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
---------------------------------------------------------------------------------------------------

beginDocumentation()

document { Key => PolynomialDynamicalSystems,
     Headline => "Utilities for polynomial dynamical systems",
     EM "PDS", " is a package for the algebraic manipulation of polynomial dynamical systems.",
     PARA,
     "This package defines the following types:",
     UL {
      TO ""
      },
     "This package includes the following functions:",
     UL {
      TO ""
      }
}

document {
    Key => (checkFunction, FunctionData, RingElement),
    Headline => "given function data D and a polynomial g, evaluates g on D and returns true if g fits D and false otherwise; in this case, it returns an error statement"
}

document {
    Key => (functionData,TimeSeriesData, ZZ),
    Headline => "given time series data and an integer i, returns a hashtable of type FunctionData for function i, that is the input-output (vector-scalar) data pairs corresponding to node i, if consistent; else returns an error statement"
}

document {
    Key => (getVars, RingElement),
    Headline => "returns the variables in a given polynomial"
}

document {
    Key => (makeVars, ZZ),
    Headline => "given an integer n, returns a list of variables {x1..xn}"
}

document {
    Key => (minRep, FunctionData, Ring),
    Headline => "given function data D and a polynomial ring, returns a monomial ideal, where the set of variables, one from each generator of the ideal, is the smallest # variables required for a consistent function; that is, the sets of variables needed for a minimal representation of the polynomial function defined by D; to be used with primaryDecomposition"
}

document {
    Key => (readTSData,List,List,Ring),
    Headline => "given a list of wildtype data filenames, a list of knockout data filenames, and a coefficient ring, returns a hashtable of type TimeSeriesData"
}

document {
    Key => (see, List),
    Headline => "prints each element of a given list on a single line"
}

document {
    Key => (subFunctionData,FunctionData, List),
    Headline => "given function data and a list L of integers between 1 and n(=dim pds), corresponding to a subset of the set of variables, returns the function data projected to the variables in L, if consistent; else it returns an error statement"
}

end

document {
    Key => (findFunction, FunctionData, List),
    Headline => "given function data D and a list L of variables xi, i=1..n, computes a polynomial in the variables in L that fit D"
}

