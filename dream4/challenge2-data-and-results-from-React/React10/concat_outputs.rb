echo "2-5 and 14-21"  > tmp.txt
cat 2-5-13-20/output-only-good_networks-1-edges.txt >> tmp.txt
echo "2-5 and 14-23"  >> tmp.txt
cat 2-5-13-22/output-only-good_networks-1-edges.txt 
echo "2-6 and 14-29"  >> tmp.txt
cat 2-6-13-28/output-only-good_networks-1-edges.txt 

cat tmp.txt
cat 2-5-13-20/output-only-good_networks-1-edges.txt; echo "Hello" 
cat 2-5-13-20/output-only-good_networks-1-edges.txt; echo "Hello"  tmp.txt
cat 2-5-13-20/output-only-good_networks-1-edges.txt && echo "Hello" >> tmp.txt
cat 2-5-13-20/output-only-good_networks-1-edges.txt | echo "Hello" 
> tmp.txt
