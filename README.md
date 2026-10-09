# The Welch function is not third-order sum-free

Deep Bhattacharjee

Let n = 2m+1 and F = F_{2^n}. A function f: F → F is *k-th order sum-free* (Carlet) if it sums to a
nonzero value over every k-dimensional affine subspace of F over F_2. Hou and Zhao (*Further results on
sum-freedom of binary and q-ary functions*, arXiv:2609.31489, Conjecture 4.10) conjectured that for
n ≥ 7 the Welch function W_n(X) = X^(2^m+3) is not third-order sum-free.

The conjecture is true. Hou and Zhao reduced it to the F_2-space
Z(x) = {y ∈ F : g(x,y) = 0}, where g(x,y) = y^(2^m)(x²+x) + y²(x^(2^m)+x) + y(x^(2^m)+x²): the Welch
function sums to zero over some three-dimensional subspace exactly when dim Z(x) ≥ 3 for some
x ∉ F_2. The paper proves:

1. **Theorem 1.1.** For x ∉ F_2 and u = x^(2^m), dim Z(x) is 2 or 3, and it is 3 exactly when
   Tr(1/(x+u)) = 1 and Tr(xu/(x+u)) = 1.
2. **Theorem 1.2.** The number of such x is N_n = (2^n + 1 − 3K_n)/4, where
   K_n = Σ_{z ≠ 0} (−1)^Tr(z + 1/z) is the Kloosterman sum of F.
3. **Corollary 1.3.** By Weil's bound |K_n| ≤ 2^(n/2+1), N_n > 0 for every n ≥ 7, so the conjecture
   holds; the Welch function sums to zero over exactly N_n(2^n − 1)/42 three-dimensional linear
   subspaces. For n = 5, K_5 = 11 gives N_5 = 0, the known sum-freedom of X^7 on F_32.

The proof works with the automorphism ρ(z) = z^(2^(m+1)), whose square is z ↦ z² and whose inverse is
z ↦ z^(2^m). Applying ρ to g(x,y) = 0 gives an additive polynomial of degree 8 whose roots V always lie
in F and contain Z(x); a linear map built from g moves V into Z(x), and whether Z(x) = V comes down to
two elements of F_2, which equal their own traces because n is odd. The values of N_n + 2 agree with
the degrees Hou and Zhao computed for 5 ≤ n ≤ 15 (their Table 1).

## Paper

`preprintWelchSumFree/` holds the LaTeX source; `dist/` holds the PDF, a source zip and an arXiv
tarball, rebuilt by `scripts/build_paper.sh`.

## Checks

```
verification/c/welch_criterion.c       every x in F_{2^n} for odd 3 <= n <= 21: dim Z(x) in {2,3} by Gaussian
                                       elimination, Theorem 1.1 at every x, Theorem 1.2 with K_n summed
                                       directly, and Carlitz's recurrence for K_n
verification/cpp/welch_subspaces.cpp   straight from the definition: the three-dimensional subspaces of F_{2^n}
                                       on which X^(2^m+3) sums to zero, counted for n = 3, 5, 7, 9, 11
                                       (1, 0, 127, 1606, 22517 = N_n(2^n-1)/42); Lemma 2.3 on random subspaces
verification/shell/check_welch.sh      bash integer arithmetic only: Z(x) by trying every y in F_32 and F_128,
                                       the Kloosterman sums, and Table 1 from the recurrence
verification/python/verify_steps.py    the polynomial identities of Section 3 over F_2, and every lemma of
                                       Sections 3 and 4 at every x for n <= 13
verification/julia/verify_count.jl     Theorem 1.2 for odd n <= 23, and positivity of N_n for odd 7 <= n <= 61
verification/lean/WelchSumFree.lean    Lean 4 kernel checks (decide +kernel, no Mathlib): N_7 = 42 with Z(x)
                                       found by trying every y, Theorem 1.1 at every x of F_128, K_7 = -13,
                                       an explicit zero-sum subspace <1, X, X^3> of F_128, N_5 = 0, and X^7
                                       summing to a nonzero value over every 3-dimensional subspace of F_32
verification/lean/mathlib/             Lean 4 + Mathlib: the identities of Section 3 in every commutative ring
                                       of characteristic 2 (including the factorization of Lemma 3.3), Lemma
                                       2.1(a) in a field with 2^(2m+1) elements, the identity of Lemma 4.1,
                                       and the arithmetic of Theorem 1.2 and its positivity; standard axioms only
```

The Lean files check the algebra and the small cases; the trace arguments of Lemmas 3.4–3.6 and the
counting of Section 5 are checked numerically at every field element by the C and Python programs.

`scripts/run_all.sh` runs them all (`MATHLIB=1` also builds the Mathlib proofs); the `verify` workflow
runs them on every pull request.

## Citation

See `CITATION.cff`.

## Licence

MIT, see `LICENSE`.
