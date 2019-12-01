function [e, s] = test(val, errormsg, e, s)
if(~val)
    fprintf(1, [errormsg, '\n']);
    e = e+1;
else
    s = s+1;
end