Deep Bhattacharjee, *The Welch function is not third-order sum-free*. Final revision, single column (amsart), 8 pages.

The paper proves Conjecture 5.10 of X. Hou and S. Zhao, *Further results on sum-freedom of
binary and q-ary functions* (arXiv:2609.31489): for n = 2m+1 >= 7 the Welch function
X^(2^m+3) on F_(2^n) is not third-order sum-free. With u = x^(2^m), the kernel Z(x) of the
linearised polynomial of Hou and Zhao has dimension 3 exactly when Tr(1/(x+u)) = Tr(xu/(x+u)) = 1,
the number of such x is (2^n + 1 - 3K_n)/4 with K_n the Kloosterman sum of F_(2^n), and Weil's
bound makes it positive for n >= 7; the Welch function sums to zero over exactly
N_n (2^n - 1)/42 three-dimensional linear subspaces. Every statement is proved by hand.
Programs in C, C++, bash, Python, Julia and Lean 4 check the statements on small fields; this
release runs them before publishing. No statement of the paper rests on them.

The results were first made public on 9 October 2026 as release v1.0.0 of this repository; an
earlier and incomplete version of the paper appeared on Hexagon as hexagon:2610.00472.

Files: the paper (`WelchSumFree_final2.pdf`), its LaTeX source (`WelchSumFree_final2-tex.zip`)
and the arXiv tarball (`WelchSumFree_final2-arxiv.tar.gz`).

Contact: d.bhattacharjee@erl-forschung.de, itsdeep@live.com; for this repository egspl@proton.me.
