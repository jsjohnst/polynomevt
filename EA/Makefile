#
# Makefile for Project EA_Two
#   VBI  18-July-2007
#
#  primary target goes first
#
EA1_Two: BitString.o DynSysModel.o NTuple.o Monomial.o Polynomial.o GAParams.o FileManager.o GAModelNew.o EA1_Two.o
	g++ BitString.o DynSysModel.o NTuple.o Monomial.o Polynomial.o GAParams.o FileManager.o GAModelNew.o EA1_Two.o -O3 -o EA1_Two

BitString.o: BitString.cpp
	gcc BitString.cpp -O3 -c

DynSysModel.o: DynSysModel.cpp
	gcc DynSysModel.cpp -O3 -c

NTuple.o: NTuple.cpp
	gcc NTuple.cpp -O3 -c

Monomial.o: Monomial.cpp
	gcc Monomial.cpp -O3 -c

Polynomial.o: Polynomial.cpp
	gcc Polynomial.cpp -O3 -c

GAParams.o: GAParams.cpp
	gcc GAParams.cpp -O3 -c

FileManager.o: FileManager.cpp
	gcc FileManager.cpp -O3 -c

GAModelNew.o: GAModelNew.cpp
	gcc GAModelNew.cpp -O3 -c

EA1_Two.o: EA1_Two.cpp
	gcc EA1_Two.cpp -O3 -c


clean:
	rm -rf *.o EA1_Two

