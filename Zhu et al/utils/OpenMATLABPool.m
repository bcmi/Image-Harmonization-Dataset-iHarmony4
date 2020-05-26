function [size] = OpenMATLABPool(n)
% Function: open MATLAB pool
% Author:    Jun-Yan Zhu (junyanz@berkeley.edu)


if exist('parpool','file')
    poolObj = gcp('nocreate');
    if isempty(poolObj) && n ~= 1
        if n <= 0
            n = 8;
        end
        myCluster = parcluster('local');
        myCluster.NumWorkers = n;
        parpool(myCluster, n);
    end
    gcpObj = gcp('nocreate');
    size = gcpObj.NumWorkers;
else
    if matlabpool('size') == 0 && n ~= 1
        if n <= 0
            n = 8;
        end
        defaultProfile = parallel.defaultClusterProfile;
        myCluster = parcluster(defaultProfile);
        myCluster.NumWorkers = n;
        matlabpool(myCluster, 'open');
        
    end
    size = matlabpool('size');
end

% if matlabpool('size') == 0 && n ~= 1
%     if n <= 0
%         n = 8;
%     end
%     defaultProfile = parallel.defaultClusterProfile;
%     myCluster = parcluster(defaultProfile);
%     myCluster.NumWorkers = n;
%     matlabpool(myCluster, 'open');
%
% end
%
% size = matlabpool('size');
% end

