# verify_count.jl -- checks Theorem 1.2 and the bound of Corollary 1.3 in
# "The Welch function is not third-order sum-free".
#
#  (1) For n = 3, 5, ..., 23: the number of x in F_{2^n} \ F_2 with Tr(1/(x+u)) = Tr(xu/(x+u)) = 1,
#      u = x^(2^m), equals (2^n + 1 - 3K_n)/4, with K_n summed directly over F^*.
#  (2) K_n agrees with Carlitz's recurrence K_0 = -2, K_1 = 1, K_n = -K_{n-1} - 2K_{n-2}, and
#      |K_n| <= 2^(n/2+1) (Weil), for the same n.
#  (3) For odd 7 <= n <= 61, with K_n from the recurrence: (2^n + 1 - 3K_n)/4 is a positive integer,
#      and (2^(n/2) - 3)^2 > 8, so the lower bound of Section 1 is positive.
# Prints "ALL OK" at the end if every check passed.

const MODULI = Dict(3 => 0xB, 5 => 0x25, 7 => 0x83, 9 => 0x211, 11 => 0x805, 13 => 0x201B, 15 => 0x8003,
                    17 => 0x20009, 19 => 0x80027, 21 => 0x200005, 23 => 0x800021)

function gfmul(a::UInt64, b::UInt64, n::Int, mod::UInt64)
    r = UInt64(0)
    while b != 0
        if b & 1 == 1
            r ⊻= a
        end
        b >>= 1
        a <<= 1
        if (a >> n) & 1 == 1
            a ⊻= mod
        end
    end
    r
end

function gfpow(a::UInt64, e::UInt64, n, mod)
    r = UInt64(1)
    while e != 0
        if e & 1 == 1
            r = gfmul(r, a, n, mod)
        end
        a = gfmul(a, a, n, mod)
        e >>= 1
    end
    r
end

function gftr(a::UInt64, n, mod)
    t = UInt64(0)
    for _ in 1:n
        t ⊻= a
        a = gfmul(a, a, n, mod)
    end
    Int(t)
end

function frob(a::UInt64, k, n, mod)
    for _ in 1:k
        a = gfmul(a, a, n, mod)
    end
    a
end

function check(n)
    mod = UInt64(MODULI[n]); m = (n - 1) ÷ 2; q = UInt64(1) << n
    @assert frob(UInt64(2), n, n, mod) == 2      # X^(2^n) = X modulo the modulus
    K = 0
    for z in UInt64(1):q-1
        K += gftr(z ⊻ gfpow(z, q - 2, n, mod), n, mod) == 1 ? -1 : 1
    end
    N = 0
    for x in UInt64(2):q-1
        u = frob(x, m, n, mod)
        di = gfpow(x ⊻ u, q - 2, n, mod)
        if gftr(di, n, mod) == 1 && gftr(gfmul(gfmul(x, u, n, mod), di, n, mod), n, mod) == 1
            N += 1
        end
    end
    K, N
end

function main()
    ok = true
    Krec = Dict{Int,BigInt}(0 => -2, 1 => 1)
    for k in 2:61
        Krec[k] = -Krec[k-1] - 2 * Krec[k-2]
    end
    for n in 3:2:23
        K, N = check(n)
        q = BigInt(2)^n
        good = 4N == q + 1 - 3K && K == Krec[n] && BigInt(K)^2 <= 4 * q
        println(good ? "ok   " : "FAIL ", "n=$n: K_n=$K, N_n=$N, (2^n+1-3K_n)/4=$(div(q + 1 - 3K, 4))")
        ok &= good
    end
    good = true
    for n in 7:2:61
        q = BigInt(2)^n
        v = q + 1 - 3 * Krec[n]
        good &= v > 0 && v % 4 == 0 && Krec[n]^2 <= 4q
        # (2^(n/2) - 3)^2 > 8  <=>  2^n + 1 > 6 * 2^(n/2)  <=>  (2^n + 1)^2 > 36 * 2^n
        good &= (q + 1)^2 > 36 * q
    end
    println(good ? "ok   " : "FAIL ", "odd 7 <= n <= 61: N_n positive integer, Weil bound holds, lower bound positive")
    ok &= good
    println(ok ? "ALL OK" : "FAILED")
    exit(ok ? 0 : 1)
end

main()
