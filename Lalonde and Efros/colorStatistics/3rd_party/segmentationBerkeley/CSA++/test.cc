
#include "csa.hh"

int n = 6;
int m = 6;
static int data[] = {
    1, 4, 3,
    2, 5, 3,
    3, 6, 3,
    1, 5, 1,
    2, 6, 1,
    3, 4, 5,
};

int
main(int argc, char** argv)
{
    for (int iter = 0; iter < 10; iter++) {
        CSA csa (n, m, data);
        for (int i = 0; i < csa.edges(); i++) {
            int a, b, cost;
            csa.edge(i,a,b,cost);
            fprintf (stderr, "%d %d %d\n", a, b, cost);
        }
        fprintf (stderr, "TOTAL %d\n", csa.cost());
    }
    return 0;
}
