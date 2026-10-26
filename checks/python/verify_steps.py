"""verify_steps.py -- checks every step of the proof of Theorem 1.1 in
"The Welch function is not third-order sum-free", with nothing but the Python standard library.

Part 1. Polynomial identities over F_2 in independent variables x, u, y (Section 3):
    t = d^2 + d + v                                          (3.2)
    t^4 P(y) = (d+v) d^4 Pi(y)^2 + t^3 v^2 Pi(y)             (Lemma 3.3)
    P(1) = P(x) = 0
    identity (3.3) multiplied by d^4 (d+v), and the identities used for Tr(tv/d^2) and gamma
Part 2. At every x in F_{2^n} \\ F_2, n = 3, 5, ..., 13: Lemma 3.1, (3.1), Lemma 3.4 (Tr a = 0, Tr tz = 0,
    V in F), Lemma 3.2, Lemma 3.5 (delta well defined, in <1,x>, dim Z(x) = 3 iff delta = 0),
    Lemma 3.6, Lemma 4.1 and Theorem 1.1.
Prints "ALL OK" at the end if every check passed.
"""
import sys

# ---------- Part 1: sparse polynomials over F_2 ----------
class P2:
    """Polynomial over F_2 in variables (x, u, y): a set of exponent triples."""
    def __init__(self, terms=()):
        self.t = frozenset(terms)
    def __add__(self, o):
        return P2(self.t ^ o.t)
    def __mul__(self, o):
        s = set()
        for a in self.t:
            for b in o.t:
                s ^= {(a[0] + b[0], a[1] + b[1], a[2] + b[2])}
        return P2(s)
    def __pow__(self, k):
        r = ONE
        for _ in range(k):
            r = r * self
        return r
    def __eq__(self, o):
        return self.t == o.t
    def __hash__(self):
        return hash(self.t)

ONE = P2([(0, 0, 0)])
X, U, Y = P2([(1, 0, 0)]), P2([(0, 1, 0)]), P2([(0, 0, 1)])

def part1():
    t = X**2 + X
    d = X + U
    v = U**2 + U
    ok = True
    def check(name, a, b):
        nonlocal ok
        good = a == b
        ok = ok and good
        print(("ok   " if good else "FAIL ") + name)
    check("t = d^2 + d + v", t, d**2 + d + v)
    N = lambda yy: d * yy**2 + (X**2 + U) * yy           # t * Y(y)
    tP = lambda yy: v**2 * yy * t**4 + (d + v) * N(yy)**4 + (U**4 + X) * N(yy)**2 * t**2   # t^4 P(y)
    Pi = Y**4 + (t + ONE) * Y**2 + t * Y
    check("t^4 P(y) = (d+v) d^4 Pi^2 + t^3 v^2 Pi  (Lemma 3.3)", tP(Y), (d + v) * d**4 * Pi**2 + t**3 * v**2 * Pi)
    check("P(1) = 0", tP(ONE), P2())
    check("P(x) = 0", tP(X), P2())
    check("Pi(y) = y(y+1)(y+x)(y+x+1)", Pi, Y * (Y + ONE) * (Y + X) * (Y + X + ONE))
    check("identity (3.3) times d^4(d+v)", t * v**2,
          v**2 * (d + v) + v * d**2 * (d + v) + d**3 * (d + v) + d**4)
    check("t v = v d^2 + v d + v^2  (Tr(tv/d^2) = 0)", t * v, v * d**2 + v * d + v**2)
    check("t v = v (d+v) + v d^2  (gamma = v/d^2 + v/(d+v))", t * v, v * (d + v) + v * d**2)
    check("v + t = d^2 + d", v + t, d**2 + d)
    return ok

# ---------- Part 2: arithmetic in F_{2^n} ----------
MODULI = {3: 0xB, 5: 0x25, 7: 0x83, 9: 0x211, 11: 0x805, 13: 0x201B}

def make_field(n):
    mod = MODULI[n]
    def mul(a, b):
        r = 0
        while b:
            if b & 1:
                r ^= a
            b >>= 1
            a <<= 1
            if (a >> n) & 1:
                a ^= mod
        return r
    def pw(a, e):
        r = 1
        while e:
            if e & 1:
                r = mul(r, a)
            a = mul(a, a)
            e >>= 1
        return r
    def frob(a, k):
        for _ in range(k % n):
            a = mul(a, a)
        return a
    def tr(a):
        s = 0
        for _ in range(n):
            s ^= a
            a = mul(a, a)
        return s
    return mul, pw, frob, tr

def kernel_dim(images, n):
    rows = list(images)
    r = 0
    for b in range(n):
        p = next((i for i in range(r, n) if (rows[i] >> b) & 1), None)
        if p is None:
            continue
        rows[r], rows[p] = rows[p], rows[r]
        for i in range(n):
            if i != r and (rows[i] >> b) & 1:
                rows[i] ^= rows[r]
        r += 1
    return n - r

def part2(n):
    mul, pw, frob, tr = make_field(n)
    q, m = 1 << n, (n - 1) // 2
    inv = lambda a: pw(a, q - 2)
    rho = lambda a: frob(a, m + 1)
    wp = lambda a: mul(a, a) ^ a
    def Tm(s):
        r = 0
        for i in range(m):
            r ^= frob(s, i)
        return r
    def L(x, y):
        u = frob(x, m)
        return mul(frob(y, m), mul(x, x) ^ x) ^ mul(mul(y, y), x ^ u) ^ mul(y, mul(x, x) ^ u)
    def Phi(x, y):
        return rho(mul(L(x, y), inv(mul(x, x) ^ x)))
    def solve_wp(a):          # z with z^2 + z = a (n odd): half-trace; requires Tr(a) = 0
        h, z = 0, a
        for _ in range((n + 1) // 2):
            h ^= z
            z = frob(z, 2)
        assert wp(h) == a
        return h
    fails = 0
    count = 0
    for x in range(2, q):
        u = frob(x, m)
        t, d, v = mul(x, x) ^ x, x ^ u, mul(u, u) ^ u
        e = d ^ v
        # (3.1)
        if (rho(x), rho(u), rho(t), rho(d), rho(e), frob(t, m)) != (mul(u, u), x, mul(v, v), e, mul(d, d), v):
            fails += 1
        if 0 in (t, d, v, e):
            fails += 1
        # Lemma 3.1 on four sample elements
        for y in (3, 5, x ^ 7, mul(x, x) ^ 1):
            if L(x, y) != mul(t, Tm(wp(y))) ^ mul(d, wp(y)):
                fails += 1
        # Lemma 3.4
        a = mul(mul(t, mul(v, v)), inv(mul(pw(d, 4), e)))
        if tr(a) != 0:
            fails += 1
            continue
        z = solve_wp(a)
        if tr(mul(t, z)) != 0:
            fails += 1
            continue
        y0 = solve_wp(mul(t, z))
        V = [w ^ c for w in (0, y0) for c in (0, 1, x, x ^ 1)]
        # Lemma 3.2: every element of V is a root of P, i.e. L(Phi(y)) = 0
        if any(L(x, Phi(x, w)) != 0 for w in V):
            fails += 1
        # Lemma 3.5
        deltas = {Phi(x, y0 ^ c) for c in (0, 1, x, x ^ 1)}
        if len(deltas) != 1:
            fails += 1
        delta = deltas.pop()
        if delta not in (0, 1, x, x ^ 1):
            fails += 1
        dim = kernel_dim([L(x, 1 << i) for i in range(n)], n)
        if dim not in (2, 3) or (dim == 3) != (delta == 0):
            fails += 1
        # Lemma 3.6 and the element epsilon = T_m(a) + gamma
        gamma = mul(mul(t, v), inv(mul(mul(d, d), e)))
        eps = Tm(a) ^ gamma
        if eps not in (0, 1) or eps != 1 ^ tr(inv(d)) or (delta in (0, 1)) != (tr(inv(d)) == 1):
            fails += 1
        # Lemma 4.1
        xi = inv(x)
        if any(mul(xi, Phi(x, mul(x, y))) != Phi(xi, y) for y in (3, x ^ 5)):
            fails += 1
        if mul(mul(u, pw(x, 3)), L(xi, mul(y0, xi))) != L(x, y0):
            fails += 1
        # Theorem 1.1
        crit = tr(inv(d)) == 1 and tr(mul(mul(x, u), inv(d))) == 1
        if crit != (dim == 3):
            fails += 1
        count += dim == 3
    K = sum(-1 if tr(z ^ inv(z)) else 1 for z in range(1, q))
    good = fails == 0 and 4 * count == q + 1 - 3 * K
    print(("ok   " if good else "FAIL ") + f"n={n}: every step at all {q - 2} elements x; N_n = {count}, K_n = {K}")
    return good

if __name__ == "__main__":
    ok = part1()
    for n in (3, 5, 7, 9, 11, 13):
        ok = part2(n) and ok
    print("ALL OK" if ok else "FAILED")
    sys.exit(0 if ok else 1)
