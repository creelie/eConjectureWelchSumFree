// welch_subspaces.cpp -- checks Corollary 1.3 and Lemma 2.3 of
// "The Welch function is not third-order sum-free" straight from the definition of sum-freedom.
//
//  (1) For n = 3, 5, 7, 9, 11 it runs over all ordered bases (a,b,c) of three-dimensional F_2-subspaces of
//      F_{2^n}, sums W_n(X) = X^(2^m+3) over each subspace, and counts the subspaces with zero sum
//      (each subspace has 168 ordered bases). The count must equal N_n (2^n - 1)/42, with
//      N_n = (2^n + 1 - 3K_n)/4 and K_n the Kloosterman sum computed directly. No use is made of g(x,y).
//  (2) For n = 3, ..., 21 (odd) and 2000 random triples: the sum of W_n over an affine subspace c + A0
//      equals the sum over A0, and the sum over <1,x,y> equals g(x,y).
// Prints "ALL OK" at the end if every check passed.
#include <cstdint>
#include <cstdio>
#include <random>
#include <vector>

typedef uint64_t u64;
static int n;
static u64 MOD;

static u64 mul(u64 a, u64 b) {
    u64 r = 0;
    while (b) {
        if (b & 1) r ^= a;
        b >>= 1;
        a <<= 1;
        if ((a >> n) & 1) a ^= MOD;
    }
    return r;
}
static u64 pw(u64 a, u64 e) { u64 r = 1; while (e) { if (e & 1) r = mul(r, a); a = mul(a, a); e >>= 1; } return r; }
static u64 frob(u64 a, int k) { while (k--) a = mul(a, a); return a; }
static int tr(u64 a) { u64 t = 0; for (int i = 0; i < n; i++) { t ^= a; a = mul(a, a); } return (int)t; }

int main() {
    const u64 moduli[22] = {0, 0, 0, 0xB, 0, 0x25, 0, 0x83, 0, 0x211, 0, 0x805, 0, 0x201B, 0,
                            0x8003, 0, 0x20009, 0, 0x80027, 0, 0x200005};
    bool ok = true;
    for (n = 3; n <= 11; n += 2) {
        MOD = moduli[n];
        int m = (n - 1) / 2;
        u64 q = 1ULL << n, e = (1ULL << m) + 3;
        std::vector<u64> W(q);
        for (u64 a = 0; a < q; a++) W[a] = pw(a, e);
        long long K = 0;
        for (u64 z = 1; z < q; z++) K += tr(z ^ pw(z, q - 2)) ? -1 : 1;
        long long N = ((long long)q + 1 - 3 * K) / 4;
        long long ordered = 0;
        for (u64 a = 1; a < q; a++)
            for (u64 b = 1; b < q; b++) {
                if (b == a) continue;
                u64 sab = W[a] ^ W[b] ^ W[a ^ b];
                for (u64 c = 1; c < q; c++) {
                    if (c == a || c == b || c == (a ^ b)) continue;
                    if ((sab ^ W[c] ^ W[a ^ c] ^ W[b ^ c] ^ W[a ^ b ^ c]) == 0) ordered++;
                }
            }
        long long zero = ordered / 168, predicted = N * (long long)(q - 1) / 42;
        bool good = ordered % 168 == 0 && zero == predicted && N * (long long)(q - 1) % 42 == 0;
        printf("n=%d  zero-sum 3-dim linear subspaces: %lld  N_n(2^n-1)/42 = %lld  %s\n", n, zero, predicted,
               good ? "ok" : "FAIL");
        ok = ok && good;
    }
    std::mt19937_64 rng(20261009);
    for (n = 3; n <= 21; n += 2) {
        MOD = moduli[n];
        int m = (n - 1) / 2;
        u64 q = 1ULL << n, e = (1ULL << m) + 3;
        int bad = 0;
        for (int it = 0; it < 2000; it++) {
            u64 a = rng() % q, b = rng() % q, c = rng() % q, s = rng() % q;
            u64 lin = 0, aff = 0;
            for (int i = 0; i < 8; i++) {
                u64 v = ((i & 1) ? a : 0) ^ ((i & 2) ? b : 0) ^ ((i & 4) ? c : 0);
                lin ^= pw(v, e);
                aff ^= pw(s ^ v, e);
            }
            if (lin != aff) bad++;
            u64 x = a, y = b, x2 = mul(x, x), y2 = mul(y, y), xm = frob(x, m), ym = frob(y, m);
            u64 g = mul(ym, x2 ^ x) ^ mul(y2, xm ^ x) ^ mul(y, xm ^ x2), sum = 0;
            for (int i = 0; i < 8; i++) sum ^= pw(((i & 1) ? x : 0) ^ ((i & 2) ? y : 0) ^ ((i & 4) ? 1 : 0), e);
            if (sum != g) bad++;
        }
        printf("n=%2d  affine sum = linear sum, and sum over <1,x,y> = g(x,y), on 2000 random triples: %s\n", n,
               bad ? "FAIL" : "ok");
        ok = ok && !bad;
    }
    printf(ok ? "ALL OK\n" : "FAILED\n");
    return ok ? 0 : 1;
}
