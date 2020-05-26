# use gmake!

srcs := csa.cc
hdrs := csa.hh csa_types.h csa_defs.h
matlab := csaAssign.m sparsify.m
mex := csaAssign.cc
lib := libcsa.a

cxxFlags := -O3
mexFlags :=

include ../Util/GNUmakefile-library

runtest:
	$(cxx) $(cxxFlags) -o test $(srcs) test.cc
	./test

clean::
	-rm -f test
