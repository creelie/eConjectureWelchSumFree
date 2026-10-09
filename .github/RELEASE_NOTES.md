**The Welch function is not third-order sum-free**, by Deep Bhattacharjee.

Let n = 2m+1. Hou and Zhao conjectured (arXiv:2609.31489, Conjecture 4.10) that for n ≥ 7 the Welch function X^(2^m+3) on F_(2^n) sums to zero over some three-dimensional affine subspace. The paper proves it, with an exact count.

| Step | Content |
|---|---|
| Lemma 2.3 | The question is whether Z(x) = {y : g(x,y) = 0} has dimension 3 for some x ∉ F_2 (Hou–Zhao) |
| Lemmas 3.2–3.4 | An additive polynomial of degree 8 whose roots V lie in F and contain Z(x) |
| Lemmas 3.5–3.6, 4.1 | Z(x) = V exactly when two elements of F_2 vanish; each is a trace |
| Theorem 1.1 | dim Z(x) = 3 iff Tr(1/(x+u)) = Tr(xu/(x+u)) = 1, u = x^(2^m) |
| Theorem 1.2 | The number of such x is (2^n + 1 − 3K_n)/4, K_n the Kloosterman sum |
| Corollary 1.3 | Positive for n ≥ 7 by Weil's bound; N_n(2^n − 1)/42 zero-sum subspaces |

The proofs are by hand. Checks in C and Python test the criterion and every lemma at every element of F_(2^n) (n ≤ 21 and n ≤ 13); C++ counts the zero-sum subspaces from the definition for n ≤ 11; Julia and Bash check the count and Table 1; a Lean kernel certificate settles n = 5 and n = 7, and Lean 4 + Mathlib proves the algebraic identities of the proof.

Files:
- `welch-third-order-sum-free.pdf`: the paper
- `welch-third-order-sum-free-tex.zip`: LaTeX source
- `welch-third-order-sum-free-arxiv.tar.gz`: LaTeX source, ready for arXiv

Run `scripts/run_all.sh` to repeat the checks and `scripts/build_paper.sh` to rebuild the files above.
