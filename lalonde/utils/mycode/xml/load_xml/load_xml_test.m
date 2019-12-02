% Test script for load_xml.

function load_xml_test

%% Init

addpath /nfs/hn01/jlalonde/jrollo/matlab/database
addpath /nfs/hn01/jlalonde/jrollo/matlab/database/labelme
addpath /nfs/hn01/jlalonde/jrollo/matlab/xml
setPathLabelme;

useAttributes = 1;

%% Test: text-based format

input = 'test.xml';
output = 'output.xml';

xmlStruct = load_xml(input);
write_xml(output, xmlStruct, useAttributes);

%% Test: attribute-based format.

input = 'test2.xml';
output = 'output2.xml';

xmlStruct = load_xml(input);
write_xml(output, xmlStruct, useAttributes);


%% Test 3 - contains siblings with dissimilar structures.

input = 'test3.xml';
output = 'output3.xml';

xmlStruct = load_xml(input);
write_xml(output, xmlStruct, useAttributes);


%% Test 4 - contains a self-closing tag with no attributes (like <tag/>)

input = 'test4.xml';
output = 'output4.xml';

xmlStruct = load_xml(input);
write_xml(output, xmlStruct, useAttributes);

%% Test 5 - dissimilar structures: later rep has an extra field.

input = 'test5.xml';
output = 'output5.xml';

xmlStruct = load_xml(input);
write_xml(output, xmlStruct, useAttributes)
