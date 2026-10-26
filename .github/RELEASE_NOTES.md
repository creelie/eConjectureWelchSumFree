# The Welch function is not third-order sum-free - submission package v1.2.0

The paper proves that the Welch function is not third-order sum-free for every odd n >= 7, with an exact Kloosterman-sum formula counting the relevant elements and zero-sum subspaces.

This release prepares the existing general result for **Finite Fields and Their Applications**, with a portable manuscript source, cover letter, AI disclosure, Hexagon form, provenance and explicit verification scope. Authorship: Deep Bhattacharjee.

The mathematical proof bodies are unchanged. Lean checks supplied algebraic identities and finite-field certificates for n = 5 and n = 7. The complete general trace and character-sum proof is written mathematics; it is not a complete Lean formalisation. Finite computations are supporting checks, not the proof for all n. The successful prior repository CI is recorded in verification/previous-ci.json; no new local Lean rebuild is claimed by this package.

The source and manuscript are in `[PAPER] package/`. Existing preprint: https://hexagonmath.org/2610.00472v1. The planned Hexagon v2 has not been submitted by this packaging work.

Human-understanding declaration: some parts checked and understood by a human. No new full-human or full-Lean certification is asserted. Final upload ZIPs are assembled after the Zenodo archive DOI is confirmed and will be attached to this release.
