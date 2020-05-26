function unitTest(m)
%call the unit test functions
errors = 0;
sucesses = 0;
%mnames = methods(m);
mnames = {};
for(i=1:numel(mnames))
    if(numel(mnames{i})>=4 && strcmp(mnames{i}(1:4), 'test'))
        [e, s] = feval(mnames{i});
        fprintf(1, '%s: failed %d tests and passed %d\n', mnames{i}, e, s);
        errors = errors+e;
        sucesses = sucesses+s;
    end
end
fprintf(1, 'total: failed %d tests and passed %d\n', errors, sucesses);