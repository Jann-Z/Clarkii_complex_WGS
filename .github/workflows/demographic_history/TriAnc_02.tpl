//Parameters for the coalescence simulation program : fastsimcoal.exe
4 samples to simulate :
//Population effective sizes (number of genes)
MEL
CEN
GUA
TRI
//Samples sizes and samples age
28
92
6
6
//Growth rates : negative growth implies population expansion
0
0
0
0
//Number of migration matrices : 0 implies no migration between demes
4
//Migration matrix 0
0 T0Mig10 T0Mig20 T0Mig30
T0Mig01 0 T0Mig21 T0Mig31
T0Mig02 T0Mig12 0 T0Mig32
T0Mig03 T0Mig13 T0Mig23 0
//Migration matrix 1
0 T1Mig10 T1Mig20 0
T1Mig01 0 T1Mig21 0
T1Mig02 T1Mig12 0 T1Mig32
0 0 T1Mig23 0
//Migration matrix 2
0 T2Mig10 0 0
T2Mig01 0 0 0
0 0 0 0
0 0 0 0
//Migration matrix 3
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
//historical event: time, source, sink, migrants, new deme size, new growth rate, migration matrix index
4 historical event
TDIV0 2 2 0 1 0 1
TDIV1 2 0 1 1 0 2
60060 0 1 1 1 0 3
TDIV3 3 1 1 NANC 0 3 absoluteResize
//Number of independent loci [chromosome]
1 0
//Per chromosome: Number of contiguous linkage Block: a block is a set of contiguous loci
1
//per Block:data type, no of loci, per gen recomb. and mut. rates and opt. params
FREQ 1 0 MUTRATE OUTFREQ
