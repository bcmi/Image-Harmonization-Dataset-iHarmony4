function f=getBaseFile(x)
f='';
if ~isempty(x)
    [p,f] = fileparts(x);
end