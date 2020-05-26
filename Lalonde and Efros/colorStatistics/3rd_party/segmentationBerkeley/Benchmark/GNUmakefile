# use gmake!

srcs := match.cc
matlab := boundaryBench.m boundaryBenchGraphs.m boundaryBenchHtml.m \
	boundaryBenchGraphsMulti.m boundaryBenchHuman.m \
	boundaryBenchGraphsHuman.m \
	correspondPixels.m plotMatch.m \
	boundaryPR.m boundaryPRfast.m \
	affinityPRMI.m calcMI.m
mex := correspondPixels.cc

cxxFlags := -O3
mexLibs := -lcsa -lutil

include ../Util/GNUmakefile-library

clean::
	-rm -f test
