
#include "csa.hh"

char* CSA::err_messages[] =
{
"Can't read from the input file.",
"Not a correct assignment problem line.",
"Error reading a node descriptor from the input.",
"Error reading an arc descriptor from the input.",
"Unknown line type in the input",
"Inconsistent number of arcs in the input.",
"Parsing noncontiguous node ID numbers not implemented.",
"Can't obtain enough memory to solve this problem.",
};

char* CSA::nomem_msg = "Insufficient memory.\n";

CSA::CSA (int n, int m, const int* graph) 
{
    assert(n>0);
    assert(m>0);
    assert(graph!=NULL);
    assert((n%2)==0);
    _init(n,m);
    main(graph);
}

CSA::~CSA () 
{
    _delete();
}

