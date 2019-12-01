
%Warning workspace will be cleared
clc
clear all
close all


mex BruteSearchMex.cpp
fprintf('Mex successifully completed!!!!\n');



N=1000000;%number of reference points
Nq=10;%number of query points
dim=3;%dimension of points
k=3;%number of neighbor
r=.01;%Search radius

p=rand(N,dim);%Note that functions in this new version requires the transpose of these matrix
qp=rand(Nq,dim);

try 
%% Nearest Neighbor
fprintf('\n\n\nNearest Neighbor Search of %4.0f query points and %4.0f reference points\n',N,Nq)
tic
[idc]=BruteSearchMex(p',qp');%find the nearest neighbour for each query points                    
fprintf('\t-Not returning the distances took: %4.4f s\n',toc)
tic
[idc,dist]=BruteSearchMex(p',qp');%same but returns also the distance of
fprintf('\t-Returning the distances took: %4.4f s\n',toc)



%% K-Nearest neighbor
fprintf('\n\n\n %1.0f Nearest Neighbors Search of %4.0f query points and %4.0f reference points\n',k,N,Nq)
tic
kidc=BruteSearchMex(p',qp','k',k);%find the K nearest neighbour for each query points
fprintf('\t-Not returning the distances took: %4.4f s\n',toc)                        

tic
[kidc,kdist]=BruteSearchMex(p',qp','k',k);%same but also returns  the distance
fprintf('\t-Returning the distances took: %4.4f s\n',toc)                                   


%% Radius Search

% NOTE: Differently from the others the radius search only supports one
% input query point

fprintf('\n\n\nRadius Search of %4.0f query points and %4.0f reference points within radius=%4.4f\n',N,Nq,r)
tic
for i=1:Nq
    [ridc,rdist]=BruteSearchMex(p',qp(i,:)','r',r);%same but also returns  the distances                                                   %     distance of pints
end
fprintf('\t-Returning the distances took: %4.4f s\n',toc) 
for i=1:Nq
    ridc=BruteSearchMex(p',qp(i,:)','r',r);%finds the points within the serach radius
end
fprintf('\t-Not returning the distances took: %4.4f s\n',toc)
catch
    error('Mex File do not run on your machine')
end
