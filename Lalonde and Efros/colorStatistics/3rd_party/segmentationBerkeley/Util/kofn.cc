
#include "Random.hh"
#include "kofn.hh"

// O(n) implementation.
static void
_kOfN_largeK (int k, int n, int* values)
{
    assert (k > 0);
    assert (k <= n);
    int j = 0;
    for (int i = 0; i < n; i++) {
        double prob = (double) (k - j) / (n - i);
        assert (prob <= 1);
        double x = Random::rand.fp ();
        if (x < prob) {
            values[j++] = i;
        }
    }
    assert (j == k);
}

// O(k*lg(k)) implementation; constant factor is about 2x the constant
// factor for the O(n) implementation.
static void
_kOfN_smallK (int k, int n, int* values)
{
    assert (k > 0);
    assert (k <= n);
    if (k == 1) {
        values[0] = Random::rand.i32 (0, n - 1);
        return;
    }
    int leftN = n / 2;
    int rightN = n - leftN;
    int leftK = 0;
    int rightK = 0;
    for (int i = 0; i < k; i++) {
        int x = Random::rand.i32 (0, n - i - 1);
        if (x < leftN - leftK) {
            leftK++; 
        } else {
            rightK++;
        }
    }
    if (leftK > 0) { _kOfN_smallK (leftK, leftN, values); }
    if (rightK > 0) { _kOfN_smallK (rightK, rightN, values + leftK); }
    for (int i = leftK; i < k; i++) {
        values[i] += leftN;
    }
}

// Return k randomly selected integers from the interval [0,n), in
// increasing sorted order.
void
kOfN (int k, int n, int* values)
{
    assert (k >= 0);
    assert (n >= 0);
    if (k == 0) { return; }
    static double log2 = log (2);
    double klogk = k * log (k) / log2;
    if (klogk < n / 2) {
        _kOfN_smallK (k, n, values);
    } else {
        _kOfN_largeK (k, n, values);
    }
}

