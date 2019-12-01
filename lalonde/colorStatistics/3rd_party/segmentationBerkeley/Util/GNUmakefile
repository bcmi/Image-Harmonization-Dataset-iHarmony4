# use gmake!

srcs  := Exception.cc String.cc Random.cc Timer.cc Matrix.cc kofn.cc
hdrs := Exception.hh String.hh Random.hh Timer.hh Matrix.hh \
	Sort.hh Point.hh Array.hh kofn.hh
matlab := isum.m kmeansML.m distSqr.m fftconv2.m padReflect.m \
	Lab2RGB.m RGB2Lab.m logist2.m progbar.m
mex := isum.c
mexLibs := -lutil

lib	:= libutil.a
cxxFlags := -O3 -DNOBLAS

include ./GNUmakefile-library

# test of Matrix module
test: 
#	g++ -g -Wall -o test test.cc build/ix86_linux/libutil.a -lgsl -lgslcblas -lm
#	g++ -g -Wall -o test test.cc build/ix86_linux/libutil.a -L/usr/mill/lib -lblas -lpgf90 -lpgf90_rpm1 -lpgf902 -lpgf90rtl -lpgftnrtl -lpgc -lm
#	g++ -g -Wall -o test test.cc build/ix86_linux/libutil.a -lblas -lg2c -lm
	g++ -g -Wall -o test test.cc -L./build/ix86_linux -L/home/cs/dmartin/lib/$(hostType) -lutil -lf77blas -latlas -lg2c -lm

# eof
