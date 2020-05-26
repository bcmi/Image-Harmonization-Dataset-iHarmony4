clear mex;

%%%CONSTRUCTOR%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist('BallTree.cpp'))
  mex BallTree.cpp cpp/BallTreeClass.cc
  movefile(['BallTree.',mexext],'../private/');
end;

if (exist('BallTreeDensity.cpp'))
  mex BallTreeDensity.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['BallTreeDensity.',mexext],'../private/');
end;

if (exist('adjustPoints.cpp'))
  mex adjustPoints.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['adjustPoints.',mexext],'../');
end;

if (exist('adjustWeights.cpp'))
  mex adjustWeights.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['adjustWeights.',mexext],'../');
end;

if (exist('adjustBW.cpp'))
  mex adjustBW.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['adjustBW.',mexext],'../');
end;

%%%EVALUATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist('evalDirect.cpp'))
  mex evalDirect.c
  movefile(['evalDirect.',mexext],'../private/');
end;

if (exist('DualTree.cpp'))
  mex DualTree.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['DualTree.',mexext],'../private/');
end;

%%%%PRODUCT SAMPLING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist('prodSampleGibbs1.cpp'))
  mex prodSampleGibbs1.cpp prodSampleGibbs.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['prodSampleGibbs1.',mexext],'../private/');
end;

if (exist('prodSampleGibbs2.cpp'))
  mex prodSampleGibbs2.cpp prodSampleGibbs.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['prodSampleGibbs2.',mexext],'../private/');
end;

if (exist('prodSampleGibbsMS1.cpp'))
  mex prodSampleGibbsMS1.cpp prodSampleGibbsMS.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['prodSampleGibbsMS1.',mexext],'../private/');
end;

if (exist('prodSampleGibbsMS2.cpp'))
  mex prodSampleGibbsMS2.cpp prodSampleGibbsMS.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['prodSampleGibbsMS2.',mexext],'../private/');
end;

if (exist('prodSampleEpsilon.cpp'))
  mex prodSampleEpsilon.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['prodSampleEpsilon.',mexext],'../private/');
end;

if (exist('prodSampleExact.cpp'))
  mex prodSampleExact.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['prodSampleExact.',mexext],'../private/');
end;

%%%%%ENTROPY,ISE,KL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (exist('entropyGradISE.cpp'))
  mex entropyGradISE.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['entropyGradISE.',mexext],'../private/');
end;

if (exist('llGrad.cpp'))
  mex llGrad.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['llGrad.',mexext],'../');
end;

if (exist('iseEpsilon.cpp'))
  mex iseEpsilon.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['iseEpsilon.',mexext],'../private');
end;


%%%%%%NEAREST NEIGHBORS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (exist('knn.cpp'))
  mex knn.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['knn.',mexext],'..');
end;

%%%%%REDUCED SET%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist('reduceSolve.cpp'))
  mex reduceSolve.cpp
  movefile(['reduceSolve.',mexext],'../private');
end;
