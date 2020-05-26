function benchNewAlg(benchdir,pres,alg)
% benchNewAlg(benchdir,pres,alg)
%
% benchdir = root directory of benchmark results
% pres = presentation, 'gray' or 'color' 
% alg = algorithm directory containing *.bmp pb files
%
% Things you should do before running this script:
%
% (1) Download and untar BSDS images and human data.
% (2) Download the code (you must have done that if you're
%     reading this!
% (3) Edit Dataset/bsdsRoot.m script to point to your BSDS
%     directory.
% (4) Run 'gmake install' from the code directory.
% (5) Create a benchmark directory e.g. 'bench' and untar the human
%     benchmark data into it.  That should create 'bench/gray'
%     and 'bench/color' sub-directories, each with a 'human'
%     subdirectory.
% (6) Put your algorithm's pb files into the directory under the
%     proper 'gray' or 'color' directory.
% (7) Create the name.txt and about.html files in your algorithm
%     directory.

algdir = fullfile(benchdir,pres,alg);

fprintf(2,'Benchmarking algorithm (takes a while!)...\n');
boundaryBench(algdir,pres);

fprintf(2,'Generating benchmark graphs for this algorithm...\n');
boundaryBenchGraphs(algdir);

fprintf(2,'Generating benchmark graphs to compare algorithms...\n');
boundaryBenchGraphsMulti(benchdir);

fprintf(2,'Generating benchmark web pages...\n');
boundaryBenchHtml(benchdir);
