//Parameters for the coalescence simulation program : fastsimcoal.exe
3 samples to simulate :
//Population effective sizes (number of genes)
OGA
MEL
CEN
//Samples sizes and samples age
20
22
108
//Growth rates : negative growth implies population expansion
0
0
0
//Number of migration matrices : 0 implies no migration between demes
3
//Migration matrix 0
0 T1Mig10 T1Mig20
T1Mig01 0 T1Mig21
T1Mig02 T1Mig12 0
//Migration matrix 1
0 0 0
0 0 T2Mig21
0 T2Mig12 0
//Migration matrix 2
0 0 0
0 0 0
0 0 0
//historical event: time, source, sink, migrants, new deme size, new growth rate, migration matrix index
2 historical event
TDIV2 0 2 1 1 0 1
60060 1 2 1 1 0 2
//Number of independent loci [chromosome]
1 0
//Per chromosome: Number of contiguous linkage Block: a block is a set of contiguous loci
1
//per Block:data type, no of loci, per gen recomb. and mut. rates and opt. params
FREQ 1 0 MUTRATE OUTFREQ
