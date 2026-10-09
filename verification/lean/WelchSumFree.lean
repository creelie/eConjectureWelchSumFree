/-
  WelchSumFree.lean -- Lean 4 kernel checks (core Lean only, no Mathlib) for
  "The Welch function is not third-order sum-free".

  Field elements of F_{2^n} are natural numbers below 2^n (bit i = coefficient of X^i), multiplied
  modulo X^5 + X^2 + 1 (n = 5) or X^7 + X + 1 (n = 7). Every theorem is proved by `decide +kernel`, so
  the kernel evaluates the definitions itself.

  * `n7_count`     : in F_128 exactly 42 elements x outside F_2 have |Z(x)| = 8, where
                     Z(x) = {y : g(x,y) = 0} is found by trying every y (Table 1, N_7 = 42).
  * `n7_criterion` : for every x in F_128 outside F_2, |Z(x)| is 4 or 8, and it is 8 exactly when
                     Tr(1/(x+u)) = Tr(xu/(x+u)) = 1 with u = x^8 (Theorem 1.1 for n = 7).
  * `n7_kloosterman` : the Kloosterman sum of F_128 is -13, so (2^7 + 1 - 3 K_7)/4 = 42 (Theorem 1.2).
  * `n7_witness`   : x = X, y = X^3 gives g(x,y) = 0 with 1, x, y independent, so X^11 sums to zero
                     over the subspace spanned by 1, X, X^3 of F_128 (Conjecture 4.10 of Hou and Zhao
                     for n = 7, directly from the definition).
  * `n5_count`, `n5_sumfree` : in F_32 no x has |Z(x)| = 8, and X^7 sums to a nonzero value over
                     every three-dimensional linear subspace of F_32 (the case n = 5).
-/

/-- multiplication in F_{2^n} modulo `md`, with `k` remaining bits of `b` -/
def gfMulAux (n md : Nat) : Nat → Nat → Nat → Nat → Nat
  | 0, _, _, r => r
  | k + 1, a, b, r =>
    let r' := if b % 2 = 1 then r ^^^ a else r
    let a' := a <<< 1
    let a'' := if (a' >>> n) % 2 = 1 then a' ^^^ md else a'
    gfMulAux n md k a'' (b >>> 1) r'

def gfMul (n md a b : Nat) : Nat := gfMulAux n md n a b 0

/-- z ↦ z^(2^k) -/
def frob (n md : Nat) : Nat → Nat → Nat
  | 0, z => z
  | k + 1, z => frob n md k (gfMul n md z z)

/-- z ↦ z^e by square and multiply, e < 2^bits -/
def gfPowAux (n md : Nat) : Nat → Nat → Nat → Nat → Nat
  | 0, _, _, r => r
  | k + 1, a, e, r =>
    gfPowAux n md k (gfMul n md a a) (e >>> 1) (if e % 2 = 1 then gfMul n md r a else r)

def gfInv (n md z : Nat) : Nat := gfPowAux n md n z (2 ^ n - 2) 1

/-- absolute trace, an element of {0, 1} -/
def trAux (n md : Nat) : Nat → Nat → Nat → Nat
  | 0, _, t => t
  | k + 1, z, t => trAux n md k (gfMul n md z z) (t ^^^ z)

def tr (n md z : Nat) : Nat := trAux n md n z 0

/-- g(x,y) = y^(2^m)(x^2+x) + y^2(x^(2^m)+x) + y(x^(2^m)+x^2), n = 2m+1 -/
def g (n md x y : Nat) : Nat :=
  let m := (n - 1) / 2
  let u := frob n md m x
  let x2 := gfMul n md x x
  gfMul n md (frob n md m y) (x2 ^^^ x) ^^^ gfMul n md (gfMul n md y y) (u ^^^ x) ^^^ gfMul n md y (u ^^^ x2)

/-- |Z(x)| = number of y in F with g(x,y) = 0 -/
def zsize (n md x : Nat) : Nat :=
  (List.range (2 ^ n)).foldl (fun c y => if g n md x y = 0 then c + 1 else c) 0

/-- the trace criterion of Theorem 1.1 -/
def crit (n md x : Nat) : Bool :=
  let u := frob n md ((n - 1) / 2) x
  let di := gfInv n md (x ^^^ u)
  tr n md di = 1 && tr n md (gfMul n md (gfMul n md x u) di) = 1

def outside (n : Nat) : List Nat := (List.range (2 ^ n)).filter (fun x => x ≥ 2)

def countBig (n md : Nat) : Nat := ((outside n).filter (fun x => zsize n md x = 8)).length

def criterionHolds (n md : Nat) : Bool :=
  (outside n).all (fun x =>
    let s := zsize n md x
    (s == 4 || s == 8) && ((s == 8) == crit n md x))

/-- the Kloosterman sum, returned as (number of +1 terms, number of -1 terms) -/
def kloosterman (n md : Nat) : Nat × Nat :=
  ((List.range (2 ^ n)).filter (fun z => z ≥ 1)).foldl
    (fun (p : Nat × Nat) z => if tr n md (z ^^^ gfInv n md z) = 0 then (p.1 + 1, p.2) else (p.1, p.2 + 1)) (0, 0)

theorem n7_count : countBig 7 0x83 = 42 := by decide +kernel

theorem n7_criterion : criterionHolds 7 0x83 = true := by decide +kernel

/-- K_7 = 57 - 70 = -13 and (128 + 1 + 39)/4 = 42 -/
theorem n7_kloosterman : kloosterman 7 0x83 = (57, 70) := by decide +kernel

/-- the span of 1, X, X^3 in F_128: 1, x, y independent and g(x,y) = 0 -/
theorem n7_witness : g 7 0x83 2 8 = 0 := by decide +kernel

/-- sum of W(a) = a^(2^m+3) over the span of a, b, c -/
def spanSum (n md a b c : Nat) : Nat :=
  let e := 2 ^ ((n - 1) / 2) + 3
  let w := fun z => gfPowAux n md n z e 1
  w a ^^^ w b ^^^ w c ^^^ w (a ^^^ b) ^^^ w (a ^^^ c) ^^^ w (b ^^^ c) ^^^ w (a ^^^ b ^^^ c)

theorem n7_witness_sum : spanSum 7 0x83 1 2 8 = 0 := by decide +kernel

theorem n5_count : countBig 5 0x25 = 0 := by decide +kernel

/-- every triple a < b < c of nonzero elements of F_32 with c ∉ {a ^^^ b} spans a three-dimensional
subspace, and every such subspace arises; the sum of X^7 over it is never zero -/
def sumFree5 : Bool :=
  (List.range 32).all fun a => (List.range 32).all fun b => (List.range 32).all fun c =>
    !(0 < a && a < b && b < c && c != (a ^^^ b)) || spanSum 5 0x25 a b c != 0

theorem n5_sumfree : sumFree5 = true := by decide +kernel

#print axioms n7_count
#print axioms n7_criterion
#print axioms n7_kloosterman
#print axioms n7_witness_sum
#print axioms n5_count
#print axioms n5_sumfree
