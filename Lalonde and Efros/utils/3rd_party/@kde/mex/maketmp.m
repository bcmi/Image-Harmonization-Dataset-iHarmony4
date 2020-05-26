clear mex;

if (0)
%%%CONSTRUCTOR%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist('BallTree.cpp'))
  mex BallTree.cpp cpp/BallTreeClass.cc
  movefile(['BallTree.',mexext],'../private/');
end;

if (exist('BallTreeDensity.cpp'))
  mex BallTreeDensity.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['BallTreeDensity.',mexext],'../private/');
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

if (exist('llGrad.cpp'))
  mex llGrad.cpp cpp/BallTreeClass.cc cpp/BallTreeDensityClass.cc
  movefile(['llGrad.',mexext],'../');
end;

end;

