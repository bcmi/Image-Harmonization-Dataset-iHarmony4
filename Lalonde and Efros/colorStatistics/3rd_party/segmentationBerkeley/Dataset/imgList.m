function [iids] = imgList(type)
% function [iids] = imgList(type)
%
% Return list of image IDs.
%
% INPUT
%	[type='all']	One of {'train','test','all'}
%
% OUTPUT
%	iids		Row vector of image IDs.
%
% See also bsdsRoot.
%
% David Martin <dmartin@eecs.berkeley.edu>
% January 2003

if nargin<1, type='all'; end

iids_train = load(fullfile(bsdsRoot,'iids_train.txt'));
iids_test = load(fullfile(bsdsRoot,'iids_test.txt'));

switch type,
 case 'all', iids = [ iids_train ; iids_test ];
 case 'train', iids = iids_train;
 case 'test', iids = iids_test;
 otherwise, error(sprintf('type=%s is invalid',type));
end

% return a row vector
iids = iids(:)';

