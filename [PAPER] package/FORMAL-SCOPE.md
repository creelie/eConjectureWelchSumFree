# Proof and verification scope

The paper proves that the Welch function is not third-order sum-free for every odd n >= 7, with an exact Kloosterman-sum formula counting the relevant elements and zero-sum subspaces.

The manuscript reproduces the reduction to the linearised polynomial, proves the two-trace criterion and exact count, and applies the classical Weil bound. The Hou-Zhao preprint identifies the conjecture and prior work; its reduction is proved again in the manuscript rather than assumed.

Lean checks supplied algebraic identities and finite-field certificates for n = 5 and n = 7. The complete general trace and character-sum proof is written mathematics; it is not a complete Lean formalisation. Finite computations are supporting checks, not the proof for all n. The successful prior repository CI is recorded in verification/previous-ci.json; no new local Lean rebuild is claimed by this package.

The mathematical proof bodies have not been changed by this packaging revision. It does not claim a new conjecture beyond the statements in the manuscript.
