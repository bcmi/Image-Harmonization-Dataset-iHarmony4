function makeBlankClass(name, parentdir)

%create the class directory
classdir = fullfile(parentdir, ['@', name]);
if(~exist(classdir, 'dir'))
    mkdir(classdir);
end
privatedir = fullfile(classdir, 'private');
if(~exist(privatedir, 'dir'))
    mkdir(privatedir);
end
%create a blank constructor
F = fopen(fullfile(classdir, [name, '.m']), 'w');
fprintf(F, 'function m = %s(p)\n%%class constructor\n', name);
fprintf(F, 'if nargin == 0\n\t%%default initialization\n\tm = init;\n\tm = class(m,%s);\n', name);
fprintf(F, 'elseif(isa(p, %s))\n\t%%return a copy\n\tm = p;\nelse\n\t%%initialize from parameters\n\tm = init(p);\n\tm = class(m,%s);\nend', name, name);
fprintf(F, '\n\n%%%%\nfunction m = init(p)\n%%define default parameters\n\nif(nargin>0)\n%%override default parameters\nm = replaceStructFields(m, p);\nend\n');
F = fclose(F);
%copy the unit test function
copyfile('blankClassFiles/unitTest.m', classdir);
copyfile('blankClassFiles/replaceStructFields.m', privatedir);
copyfile('blankClassFiles/test.m', privatedir);
copyfile('blankClassFiles/testTemplate.m', privatedir);