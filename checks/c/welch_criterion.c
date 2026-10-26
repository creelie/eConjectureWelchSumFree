/* welch_criterion.c -- checks Theorems 1.1 and 1.2 of
 * "The Welch function is not third-order sum-free" at every element of F_{2^n}, n = 3, 5, ..., 21.
 *
 * For n = 2m+1 and x in F \ F_2 it computes dim Z(x), where Z(x) is the kernel of the F_2-linear map
 *     y -> g(x,y) = y^(2^m)(x^2+x) + y^2(x^(2^m)+x) + y(x^(2^m)+x^2),
 * by Gaussian elimination on the images of a basis, and compares:
 *   (1) dim Z(x) is 2 or 3;
 *   (2) dim Z(x) = 3  iff  Tr(1/(x+u)) = 1 and Tr(xu/(x+u)) = 1, where u = x^(2^m)   (Theorem 1.1);
 *   (3) the number N_n of x with dim Z(x) = 3 equals (2^n + 1 - 3K_n)/4, where K_n is the Kloosterman
 *       sum over F^*, computed directly                                                     (Theorem 1.2);
 *   (4) K_n agrees with the recurrence K_0 = -2, K_1 = 1, K_n = -K_{n-1} - 2K_{n-2}           (Carlitz).
 * Each modulus is first checked to be irreducible (Rabin's test).
 * Usage: welch_criterion [nmax]   (default 21). Prints "ALL OK" at the end if every check passed.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef uint64_t u64;
static int n;
static u64 MOD;

static inline u64 mul(u64 a, u64 b) {
    u64 r = 0;
    while (b) {
        if (b & 1) r ^= a;
        b >>= 1;
        a <<= 1;
        if ((a >> n) & 1) a ^= MOD;
    }
    return r;
}
static u64 frob(u64 a, int k) { k %= n; while (k--) a = mul(a, a); return a; }
static u64 inv(u64 a) { /* a^(2^n - 2) */
    u64 r = 1, e = (1ULL << n) - 2;
    while (e) { if (e & 1) r = mul(r, a); a = mul(a, a); e >>= 1; }
    return r;
}
static int tr(u64 a) { u64 t = 0; for (int i = 0; i < n; i++) { t ^= a; a = mul(a, a); } return (int)t; }

/* polynomials over F_2 as bit masks: remainder and gcd, for Rabin's irreducibility test */
static int deg(u64 p) { int d = -1; while (p) { d++; p >>= 1; } return d; }
static u64 pmod(u64 a, u64 b) { int db = deg(b); while (a && deg(a) >= db) a ^= b << (deg(a) - db); return a; }
static u64 pgcd(u64 a, u64 b) { while (b) { u64 t = pmod(a, b); a = b; b = t; } return a; }
static int irreducible(void) {
    /* X^(2^n) = X in F_2[X]/(MOD), and gcd(X^(2^(n/r)) - X, MOD) = 1 for each prime r | n */
    if (frob(2, n) != 2) return 0;
    for (int r = 2; r <= n; r++) {
        int prime = 1;
        for (int s = 2; s * s <= r; s++) if (r % s == 0) prime = 0;
        if (!prime || n % r) continue;
        if (pgcd(MOD, frob(2, n / r) ^ 2) != 1) return 0;
    }
    return 1;
}

static int rank(u64 *rows) {
    int r = 0;
    for (int b = 0; b < n && r < n; b++) {
        int p = -1;
        for (int i = r; i < n; i++) if ((rows[i] >> b) & 1) { p = i; break; }
        if (p < 0) continue;
        u64 t = rows[r]; rows[r] = rows[p]; rows[p] = t;
        for (int i = 0; i < n; i++) if (i != r && ((rows[i] >> b) & 1)) rows[i] ^= rows[r];
        r++;
    }
    return r;
}

int main(int argc, char **argv) {
    /* irreducible moduli x^n + ... (bit i = coefficient of x^i) */
    static const u64 moduli[22] = {0, 0, 0, 0xB, 0, 0x25, 0, 0x83, 0, 0x211, 0, 0x805, 0, 0x201B, 0,
                                   0x8003, 0, 0x20009, 0, 0x80027, 0, 0x200005};
    int nmax = argc > 1 ? atoi(argv[1]) : 21;
    int ok = 1;
    long long Krec[64];
    Krec[0] = -2; Krec[1] = 1;
    for (int k = 2; k < 64; k++) Krec[k] = -Krec[k - 1] - 2 * Krec[k - 2];
    for (n = 3; n <= nmax && n <= 21; n += 2) {
        MOD = moduli[n];
        int m = (n - 1) / 2;
        u64 q = 1ULL << n;
        if (!irreducible()) { printf("n=%d: modulus not irreducible\n", n); ok = 0; continue; }
        long long K = 0;
        for (u64 z = 1; z < q; z++) K += tr(z ^ inv(z)) ? -1 : 1;
        u64 bm[64], b2[64];
        for (int i = 0; i < n; i++) { bm[i] = frob(1ULL << i, m); b2[i] = mul(1ULL << i, 1ULL << i); }
        long long N = 0, mismatch = 0, otherdim = 0;
        for (u64 x = 2; x < q; x++) {
            u64 u = frob(x, m), x2 = mul(x, x);
            u64 A = x2 ^ x, B = u ^ x, C = u ^ x2, rows[64];
            for (int i = 0; i < n; i++) rows[i] = mul(bm[i], A) ^ mul(b2[i], B) ^ mul(1ULL << i, C);
            int dim = n - rank(rows);
            if (dim != 2 && dim != 3) otherdim++;
            u64 di = inv(x ^ u);
            int crit = tr(di) == 1 && tr(mul(mul(x, u), di)) == 1;
            if (crit != (dim == 3)) mismatch++;
            if (dim == 3) N++;
        }
        long long formula = ((long long)q + 1 - 3 * K) / 4;
        int good = otherdim == 0 && mismatch == 0 && N == formula && ((long long)q + 1 - 3 * K) % 4 == 0
                   && K == Krec[n] && (n < 7 || N > 0) && (n != 5 || N == 0);
        printf("n=%2d  K_n=%6lld  N_n=%7lld  (2^n+1-3K_n)/4=%7lld  dims outside {2,3}: %lld  criterion mismatches: %lld  %s\n",
               n, K, N, formula, otherdim, mismatch, good ? "ok" : "FAIL");
        if (!good) ok = 0;
    }
    printf(ok ? "ALL OK\n" : "FAILED\n");
    return ok ? 0 : 1;
}
