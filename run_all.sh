#!/usr/bin/env bash
# run_all.sh: every check in this repository. Outputs go to build/.
#   C       checks/c/welch_criterion.c     every x in F_{2^n} for odd n <= 21: dim Z(x) in {2,3},
#                                          Theorem 1.1 at every x, Theorem 1.2 with K_n summed directly,
#                                          and Carlitz's recurrence for K_n
#   C++     checks/cpp/welch_subspaces.cpp  the zero-sum three-dimensional subspaces counted from the
#                                          definition for odd n <= 11 (Corollary 1.3); Lemma 2.3 on random
#                                          subspaces
#   Shell   checks/shell/check_welch.sh    bash integer arithmetic only: F_32 and F_128 by brute force,
#                                          Table 1 from Carlitz's recurrence
#   Python  checks/python/verify_steps.py  the polynomial identities of Section 3, and every lemma of
#                                          Sections 3 and 4 at every x for odd n <= 13
#   Julia   checks/julia/verify_count.jl   Theorem 1.2 for odd n <= 23 and positivity for odd n <= 61
#                                          (if julia is on PATH or $JULIA is set)
#   Lean    checks/lean/WelchSumFree.lean  kernel checks for n = 5 and n = 7 (if lean is on PATH; the
#                                          folder pins v4.34.1)
# Needs a C and a C++ compiler, bash and Python 3; Julia and Lean are optional.
# Exit status 0 means every check that ran passed.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V="$ROOT/checks"
B="$ROOT/build"
mkdir -p "$B"
FAILED=0
fail() { echo "FAIL: $*"; FAILED=1; }
ok() { echo "ok:   $*"; }

echo "== C and C++"
cc -O2 -Wall -o "$B/welch_criterion" "$V/c/welch_criterion.c" || fail "compile welch_criterion.c"
c++ -O2 -Wall -std=c++17 -o "$B/welch_subspaces" "$V/cpp/welch_subspaces.cpp" || fail "compile welch_subspaces.cpp"
"$B/welch_criterion" > "$B/c.txt" && grep -q '^ALL OK' "$B/c.txt" \
  && grep -q "n= 7  K_n=   -13  N_n=     42" "$B/c.txt" \
  && ok "C: every element of F_{2^n} for odd n <= 21 (Theorems 1.1 and 1.2)" || fail "C (see build/c.txt)"
"$B/welch_subspaces" > "$B/cpp.txt" && grep -q '^ALL OK' "$B/cpp.txt" \
  && grep -q "n=7  zero-sum 3-dim linear subspaces: 127" "$B/cpp.txt" \
  && ok "C++: zero-sum subspaces from the definition, odd n <= 11 (Corollary 1.3)" || fail "C++ (see build/cpp.txt)"

echo "== Shell"
bash "$V/shell/check_welch.sh" > "$B/sh.txt" 2>&1 && grep -q '^ALL OK' "$B/sh.txt" \
  && ok "check_welch.sh" || fail "check_welch.sh (see build/sh.txt)"

echo "== Python"
python3 "$V/python/verify_steps.py" > "$B/py.txt" 2>&1 && grep -q '^ALL OK' "$B/py.txt" \
  && ok "verify_steps.py" || fail "verify_steps.py (see build/py.txt)"

echo "== Julia"
JULIA="${JULIA:-$(command -v julia || true)}"
if [ -z "$JULIA" ]; then echo "julia not found: skipping"; else
  "$JULIA" "$V/julia/verify_count.jl" > "$B/jl.txt" 2>&1 && grep -q '^ALL OK' "$B/jl.txt" \
    && ok "verify_count.jl" || fail "verify_count.jl (see build/jl.txt)"
fi

echo "== Lean"
if ! command -v lean > /dev/null; then echo "lean not found: skipping"; else
  out=$(cd "$V/lean" && lean WelchSumFree.lean 2>&1); st=$?
  echo "$out" > "$B/lean.txt"
  if [ $st -eq 0 ] && ! grep -q "error\|sorryAx" <<< "$out" \
       && [ "$(grep -c "depends on axioms: \[propext\]" <<< "$out")" = 6 ]; then
    ok "WelchSumFree.lean (kernel-checked)"
  else fail "WelchSumFree.lean (see build/lean.txt)"; fi
fi

if [ $FAILED -eq 0 ]; then echo "all checks passed"; else echo "SOME CHECKS FAILED"; exit 1; fi
