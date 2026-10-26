# The Welch function is not third-order sum-free

Deep Bhattacharjee. Final revision, 26 October 2026.

Let n = 2m+1 and F = F_{2^n}. A function f: F -> F is *k-th order sum-free* (Carlet) if it sums
to a nonzero value over every k-dimensional affine subspace of F over F_2. Hou and Zhao
(*Further results on sum-freedom of binary and q-ary functions*, arXiv:2609.31489,
Conjecture 5.10) conjectured that for n >= 7 the Welch function W_n(X) = X^(2^m+3) is not
third-order sum-free.

The paper proves the conjecture. Hou and Zhao reduced it to the F_2-space
Z(x) = {y in F : g(x,y) = 0}, where g(x,y) = y^(2^m)(x^2+x) + y^2(x^(2^m)+x) + y(x^(2^m)+x^2):
the Welch function sums to zero over some three-dimensional subspace exactly when
dim Z(x) >= 3 for some x outside F_2. The paper shows:

1. **Theorem 1.1.** For x outside F_2 and u = x^(2^m), dim Z(x) is 2 or 3, and it is 3 exactly
   when Tr(1/(x+u)) = 1 and Tr(xu/(x+u)) = 1.
2. **Theorem 1.2.** The number of such x is N_n = (2^n + 1 - 3K_n)/4, where
   K_n = sum over z != 0 of (-1)^Tr(z + 1/z) is the Kloosterman sum of F.
3. **Corollary 1.3.** By Weil's bound |K_n| <= 2^(n/2+1), N_n > 0 for every n >= 7, so the
   conjecture holds; the Welch function sums to zero over exactly N_n (2^n - 1)/42
   three-dimensional linear subspaces. For n = 5, K_5 = 11 gives N_5 = 0, the known
   sum-freedom of X^7 on F_32.

The proof applies the automorphism z -> z^(2^(m+1)), whose square is z -> z^2 and whose
inverse is z -> z^(2^m), to g(x,y) = 0; this gives an additive polynomial of degree 8 whose
roots V always lie in F and contain Z(x), and whether Z(x) = V comes down to two elements of
F_2, which equal their own traces because n is odd. The values 2 + N_n agree with the degrees
that Hou and Zhao computed for 5 <= n <= 15 (their Table 1). Every statement is proved by
hand; the programs here only check the statements on small fields, and no statement of the
paper rests on them.

The results were first made public on 9 October 2026 as release v1.0.0 of this repository
(later versions archived on Zenodo as
[10.5281/zenodo.23553010](https://doi.org/10.5281/zenodo.23553010) and
[10.5281/zenodo.23662272](https://doi.org/10.5281/zenodo.23662272); this revision
[10.5281/zenodo.23663217](https://doi.org/10.5281/zenodo.23663217), concept DOI
[10.5281/zenodo.23553009](https://doi.org/10.5281/zenodo.23553009)); an earlier and
incomplete version of the paper appeared on Hexagon as
[hexagon:2610.00472](https://hexagonmath.org/2610.00472) on 22 October 2026.

## Layout

- `paper/main.tex`: the LaTeX source; `paper/main.pdf` the compiled paper (9 pages, single column).
- `dist/`: the paper as `WelchSumFree_final2.pdf`, its source zip and the arXiv tarball.
- `checks/c/welch_criterion.c`: every x in F_{2^n} for odd 3 <= n <= 21: dim Z(x) in {2,3} by Gaussian elimination, Theorem 1.1 at every x, Theorem 1.2 with K_n summed directly, and Carlitz's recurrence for K_n.
- `checks/cpp/welch_subspaces.cpp`: straight from the definition, the three-dimensional subspaces of F_{2^n} on which X^(2^m+3) sums to zero, counted for n = 3, 5, 7, 9, 11 (1, 0, 127, 1606, 22517 = N_n (2^n-1)/42); Lemma 2.3 on random subspaces.
- `checks/shell/check_welch.sh`: bash integer arithmetic only: Z(x) by trying every y in F_32 and F_128, the Kloosterman sums, and Table 1 from the recurrence.
- `checks/python/verify_steps.py`: the polynomial identities of Section 3 over F_2, and every lemma of Sections 3 and 4 at every x for odd n <= 13.
- `checks/julia/verify_count.jl`: Theorem 1.2 for odd n <= 23, and positivity of N_n for odd 7 <= n <= 61.
- `checks/lean/WelchSumFree.lean`: kernel checks without Mathlib: N_7 = 42 with Z(x) found by trying every y, Theorem 1.1 at every x of F_128, K_7 = -13, an explicit zero-sum subspace <1, X, X^3> of F_128, N_5 = 0, and X^7 summing to a nonzero value over every three-dimensional subspace of F_32.
- `run_all.sh`: runs all of them.

## Running the checks

    ./run_all.sh

Requirements: a C and a C++ compiler, bash and Python 3. Julia and Lean 4 (v4.34.1) are used when
they are on the PATH and skipped otherwise.

## Releases

Releases are published by the workflow `release.yml` from the Actions tab.
Each release carries the paper files of `dist/`.

| Release | DOI |
| --- | --- |
| v2.0.0 | [10.5281/zenodo.23663217](https://doi.org/10.5281/zenodo.23663217) |
| v1.2.0 | [10.5281/zenodo.23662272](https://doi.org/10.5281/zenodo.23662272) |
| v1.1.0 | [10.5281/zenodo.23553010](https://doi.org/10.5281/zenodo.23553010) |
| v1.0.0 | 9 October 2026, first public record |

Concept DOI of all versions: [10.5281/zenodo.23553009](https://doi.org/10.5281/zenodo.23553009).

## Author

Deep Bhattacharjee, Formerly, Electro-Gravitational Space Propulsion Laboratory (EGSPL), Bhubaneswar, Odisha 751030, India; Formerly, University of Calcutta, Senate House, 87/1 College Street, Kolkata 700073, West Bengal, India.
Emails: d.bhattacharjee@erl-forschung.de, itsdeep@live.com, egspl@proton.me (for questions about this repository).
ORCID: 0000-0003-0466-750X.

## Licence

MIT, see `LICENSE`.
