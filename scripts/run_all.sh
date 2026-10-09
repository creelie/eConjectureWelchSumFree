#!/usr/bin/env bash
# run_all.sh -- re-run every check of "The Welch function is not third-order sum-free".
#
#   C       verification/c/welch_criterion.c     every x in F_{2^n} for odd n <= 21: dim Z(x) in {2,3},
#                                                Theorem 1.1, Theorem 1.2 with K_n summed directly
#   C++     verification/cpp/welch_subspaces.cpp  zero-sum 3-dim subspaces counted from the definition for
#                                                n <= 11 (Corollary 1.3); Lemma 2.3 on random subspaces
#   Shell   verification/shell/check_welch.sh    bash integer arithmetic only: F_32 and F_128 by brute force,
#                                                Table 1 from Carlitz's recurrence
#   Python  verification/python/verify_steps.py  the polynomial identities of Section 3, and every lemma of
#                                                Sections 3-4 at every x for n <= 13
#   Julia   verification/julia/verify_count.jl   Theorem 1.2 for n <= 23 and positivity for n <= 61 (if julia
#                                                is on PATH or $JULIA is set)
#   Lean    verification/lean/WelchSumFree.lean  kernel checks for n = 5 and n = 7 (if lean is on PATH; the
#                                                folder pins v4.34.1)
#           verification/lean/mathlib            (MATHLIB=1 only: lake fetches Mathlib's cache and builds the
#                                                proofs of the identities of Section 3 and of Lemmas 2.1, 4.1)
#
# Exit status 0 means every check that ran passed.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
V="$ROOT/verification"
BUILD="$ROOT/build"
mkdir -p "$BUILD"
FAILED=0
fail() { echo "FAIL: $*"; FAILED=1; }
ok() { echo "ok:   $*"; }

echo "== C and C++"
cc -O2 -Wall -o "$BUILD/welch_criterion" "$V/c/welch_criterion.c" || fail "compile welch_criterion.c"
c++ -O2 -Wall -std=c++17 -o "$BUILD/welch_subspaces" "$V/cpp/welch_subspaces.cpp" || fail "compile welch_subspaces.cpp"
"$BUILD/welch_criterion" > "$BUILD/c.txt" && grep -q '^ALL OK' "$BUILD/c.txt" \
  && grep -q "n= 7  K_n=   -13  N_n=     42" "$BUILD/c.txt" \
  && ok "C: every element of F_{2^n} for odd n <= 21 (Theorems 1.1 and 1.2)" || fail "C (see build/c.txt)"
"$BUILD/welch_subspaces" > "$BUILD/cpp.txt" && grep -q '^ALL OK' "$BUILD/cpp.txt" \
  && grep -q "n=7  zero-sum 3-dim linear subspaces: 127" "$BUILD/cpp.txt" \
  && ok "C++: zero-sum subspaces from the definition, n <= 11 (Corollary 1.3)" || fail "C++ (see build/cpp.txt)"

echo "== Shell"
bash "$V/shell/check_welch.sh" > "$BUILD/sh.txt" 2>&1 && grep -q '^ALL OK' "$BUILD/sh.txt" \
  && ok "check_welch.sh" || fail "check_welch.sh (see build/sh.txt)"

echo "== Python"
python3 "$V/python/verify_steps.py" > "$BUILD/py.txt" 2>&1 && grep -q '^ALL OK' "$BUILD/py.txt" \
  && ok "verify_steps.py" || fail "verify_steps.py (see build/py.txt)"

echo "== Julia"
JULIA="${JULIA:-$(command -v julia || true)}"
if [ -z "$JULIA" ]; then echo "julia not found: skipping"; else
  "$JULIA" "$V/julia/verify_count.jl" > "$BUILD/jl.txt" 2>&1 && grep -q '^ALL OK' "$BUILD/jl.txt" \
    && ok "verify_count.jl" || fail "verify_count.jl (see build/jl.txt)"
fi

echo "== Lean"
if ! command -v lean > /dev/null; then echo "lean not found: skipping (install elan)"; else
  out=$(cd "$V/lean" && lean WelchSumFree.lean 2>&1); st=$?
  echo "$out" > "$BUILD/lean.txt"
  if [ $st -eq 0 ] && ! grep -q "error\|sorryAx" <<< "$out" \
       && [ "$(grep -c "depends on axioms: \[propext\]" <<< "$out")" = 6 ]; then
    ok "WelchSumFree.lean (kernel-checked)"
  else fail "WelchSumFree.lean (see build/lean.txt)"; fi
  if [ "${MATHLIB:-0}" = 1 ]; then
    out=$(cd "$V/lean/mathlib" && lake exe cache get > /dev/null && lake build 2>&1); st=$?
    echo "$out" > "$BUILD/lean_mathlib.txt"
    if [ $st -eq 0 ] && ! grep -q "sorryAx\|error" <<< "$out" \
         && [ "$(grep -c "depends on axioms" <<< "$out")" = 6 ]; then
      ok "mathlib/WelchMathlib.lean (standard axioms only)"
    else fail "mathlib/WelchMathlib.lean (see build/lean_mathlib.txt)"; fi
  else echo "Mathlib proof skipped (set MATHLIB=1)"; fi
fi

if [ $FAILED -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit $FAILED
