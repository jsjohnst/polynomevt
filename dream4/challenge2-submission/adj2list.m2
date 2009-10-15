--DREAM4_TeamName_SubChallenge_Network.txt

adj2list = method();
adj2list(String, String) := (fin, fout) -> (
	a = lines get fin;
	a = apply(a, l->separateRegexp(" +",l)/value);
	a = rsort flatten for i from 0 to #a-1 list
	for j from 0 to #a-1 list
	if ((a_i_j!=0) and (i!=j)) then 
		(if a_i_j<=1 then (a_i_j,j+1,i+1) else (a_i_j/100.0,j+1,i+1))
	else continue;

	f = openOut fout;
	apply(a, l->f<<toString(l_1)|" "|toString(l_2)|" "|toString(l_0)<<endl);
	f << close;
)

end
--Alan's data
A = select(readDirectory ".", s->match("eye",s));
A10 = sort select(A, s->match("10-",s)); 
A100 = sort select(A, s->match("100-",s));
apply(#A10, i->(
	infile = A10_i;
	outfile = "DREAM4_1_eyeballer_InSilico_Size10_"|toString(i+1)|".txt";
	adj2list(infile, outfile);
))
apply(#A100, i->(
	infile = A100_i;
	outfile = "DREAM4_1_eyeballer_InSilico_Size100_"|toString(i+1)|".txt";
	adj2list(infile, outfile);
))

--Franzi's data
A = select(readDirectory ".", s->match("react",s));
A10 = sort select(A, s->match("10-",s)); 
A100 = sort select(A, s->match("100-",s));
apply(#A10, i->(
	infile = A10_i;
	outfile = "DREAM4_React_0n_InSilico_Size10_"|toString(i+1)|".txt";
	adj2list(infile, outfile);
))
apply(#A100, i->(
	infile = A100_i;
	outfile = "DREAM4_React_0n_InSilico_Size100_"|toString(i+1)|".txt";
	adj2list(infile, outfile);
))

--getting rid of rows and cols 101..110
L = select(readDirectory ".", s->match("React",s));
apply(L, f->(
a=lines get f;
a=apply(a, l->separate(" ",l)/value);
a=select(a, l->l_0<=100 and l_1<=100);
f1=openOut (f|".out");
apply(a, l->f1<<toString(l_0)|" "|toString(l_1)|" "|toString(l_2)<<endl);
f1<<close;
))

--run "rm *React*txt"
--now rename .txt.out to txt


--Elena's data
A = select(readDirectory ".", s->match("deps",s));
A10 = sort select(A, s->match("10-",s)); 
--A100 = sort select(A, s->match("100-",s));
apply(#A10, i->(
	infile = A10_i;
	outfile = "DREAM4_Fanning_5_InSilico_Size10_"|toString(i+1)|".txt";
	adj2list(infile, outfile);
))
--apply(#A100, i->(
--	infile = A100_i;
--	outfile = "DREAM4_Fanning_5_InSilico_Size100_"|toString(i+1)|".txt";
--	adj2list(infile, outfile);
--))

--Brandy's data 
A = select(readDirectory ".", s->match("ms",s));
A10 = sort select(A, s->match("10-",s));
A100 = sort select(A, s->match("100-",s));
apply(#A10, i->(
        infile = A10_i;
        outfile = "DREAM4_MS_0_InSilico_Size10_"|toString(i+1)|".txt";
        adj2list(infile, outfile);
))
apply(#A100, i->(
        infile = A100_i;
        outfile = "DREAM4_MS_0_InSilico_Size100_"|toString(i+1)|".txt";
        adj2list(infile, outfile);
))

--Consensus data
--A = select(readDirectory ".", s->match("react",s));
A10 = sort select(A, s->match("10-",s));
A100 = sort select(A, s->match("100-",s));
apply(#A10, i->(
        infile = A10_i;
        outfile = "DREAM4_Consensus_builders_6_InSilico_Size10_"|toString(i+1)|".txt";
        adj2list(infile, outfile);
))      
apply(#A100, i->(
        infile = A100_i;
        outfile = "DREAM4_Consensus_builders_6_InSilico_Size100_"|toString(i+1)|".txt";
        adj2list(infile, outfile);
))      


