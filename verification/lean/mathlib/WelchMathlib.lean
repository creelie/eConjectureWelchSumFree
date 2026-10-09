/-
  WelchMathlib.lean -- Lean 4 + Mathlib proofs of the algebraic steps of
  "The Welch function is not third-order sum-free".

  The identities of Section 3 are proved in every commutative ring of characteristic 2, with
  t = x^2 + x, d = x + u, v = u^2 + u for independent x, u (in the paper u = x^(2^m)); each proof
  is a `linear_combination` of 2 = 0. Also proved: the Frobenius facts of Lemma 2.1(a) in a field
  with 2^(2m+1) elements, the identity of Lemma 4.1 in any field, the arithmetic that turns the three
  character sums into Theorem 1.2, and the inequality that makes the count positive for n >= 7.
  Only the standard axioms are used.
-/
import Mathlib

namespace WelchSumFree

variable {R : Type*} [CommRing R] [CharP R 2]

lemma two_eq_zero' : (2 : R) = 0 := by exact_mod_cast CharP.cast_eq_zero R 2

/-- (3.2): t = d^2 + d + v -/
theorem t_eq (x u t d v : R) (ht : t = x^2 + x) (hd : d = x + u) (hv : v = u^2 + u) :
    t = d^2 + d + v := by
  subst ht hd hv
  linear_combination (-u^2 - u*x - u) * (two_eq_zero' (R := R))

/-- Lemma 3.3 with denominators cleared: t^4 P(y) = (d+v) d^4 Pi(y)^2 + t^3 v^2 Pi(y), where
t Y(y) = d y^2 + (x^2+u) y and Pi(y) = y^4 + (t+1) y^2 + t y. -/
theorem P_factor (x u y t d v : R) (ht : t = x^2 + x) (hd : d = x + u) (hv : v = u^2 + u) :
    v^2 * y * t^4 + (d + v) * (d * y^2 + (x^2 + u) * y)^4 + (u^4 + x) * (d * y^2 + (x^2 + u) * y)^2 * t^2
      = (d + v) * d^4 * (y^4 + (t + 1) * y^2 + t * y)^2 + t^3 * v^2 * (y^4 + (t + 1) * y^2 + t * y) := by
  subst ht hd hv
  linear_combination (-u^6*x^2*y^6 - u^6*x^2*y^5 - u^6*x^2*y^4 - u^6*x^2*y^3 - u^6*x*y^6 - u^6*x*y^5 - u^6*x*y^4 - u^6*x*y^3 + 2*u^6*y^7 + 2*u^6*y^6 + 2*u^6*y^5 + u^5*x^6*y^3 + u^5*x^6*y^2 - u^5*x^5*y^4 - u^5*x^5*y^3 - 3*u^5*x^4*y^4 - 7*u^5*x^4*y^3 - 4*u^5*x^4*y^2 - 4*u^5*x^3*y^6 - 4*u^5*x^3*y^5 - 7*u^5*x^3*y^4 - 11*u^5*x^3*y^3 - 4*u^5*x^3*y^2 + 2*u^5*x^2*y^7 - 5*u^5*x^2*y^4 - 8*u^5*x^2*y^3 - u^5*x^2*y^2 + 6*u^5*x*y^7 - 4*u^5*x*y^4 - 2*u^5*x*y^3 + 4*u^5*y^7 + 4*u^5*y^6 + 4*u^5*y^5 + u^4*x^7*y^3 - u^4*x^7*y^2 - 3*u^4*x^6*y^4 - 4*u^4*x^6*y^3 - 6*u^4*x^6*y^2 - 11*u^4*x^5*y^4 - 20*u^4*x^5*y^3 - 14*u^4*x^5*y^2 - 3*u^4*x^4*y^6 - 16*u^4*x^4*y^4 - 30*u^4*x^4*y^3 - 14*u^4*x^4*y^2 + 6*u^4*x^3*y^7 - 3*u^4*x^3*y^6 - 9*u^4*x^3*y^5 - 20*u^4*x^3*y^4 - 24*u^4*x^3*y^3 - 5*u^4*x^3*y^2 + 10*u^4*x^2*y^7 + 3*u^4*x^2*y^5 - 8*u^4*x^2*y^4 - 9*u^4*x^2*y^3 + 14*u^4*x*y^7 + 6*u^4*x*y^6 + 6*u^4*x*y^5 - 4*u^4*x*y^4 - u^3*x^8*y^2 - 2*u^3*x^7*y^4 - 4*u^3*x^7*y^3 - 6*u^3*x^7*y^2 + 2*u^3*x^6*y^5 - 11*u^3*x^6*y^4 - 24*u^3*x^6*y^3 - 19*u^3*x^6*y^2 + 2*u^3*x^5*y^6 + 2*u^3*x^5*y^5 - 25*u^3*x^5*y^4 - 40*u^3*x^5*y^3 - 25*u^3*x^5*y^2 + 6*u^3*x^4*y^7 - 8*u^3*x^4*y^6 - 8*u^3*x^4*y^5 - 25*u^3*x^4*y^4 - 36*u^3*x^4*y^3 - 12*u^3*x^4*y^2 + 16*u^3*x^3*y^7 + 10*u^3*x^3*y^6 + 2*u^3*x^3*y^5 - 17*u^3*x^3*y^4 - 16*u^3*x^3*y^3 - u^3*x^3*y^2 + 18*u^3*x^2*y^7 - 4*u^3*x^2*y^6 + 2*u^3*x^2*y^5 - 8*u^3*x^2*y^4 - u^2*x^8*y^3 - u^2*x^8*y^2 + 2*u^2*x^7*y^5 - 8*u^2*x^7*y^4 - 16*u^2*x^7*y^3 - 10*u^2*x^7*y^2 + 2*u^2*x^6*y^6 + 3*u^2*x^6*y^5 - 12*u^2*x^6*y^4 - 30*u^2*x^6*y^3 - 18*u^2*x^6*y^2 + 2*u^2*x^5*y^7 + 3*u^2*x^5*y^5 - 20*u^2*x^5*y^4 - 28*u^2*x^5*y^3 - 10*u^2*x^5*y^2 + 18*u^2*x^4*y^7 + 9*u^2*x^4*y^6 - 8*u^2*x^4*y^5 - 15*u^2*x^4*y^4 - 12*u^2*x^4*y^3 - u^2*x^4*y^2 + 10*u^2*x^3*y^7 - 11*u^2*x^3*y^6 - 7*u^2*x^3*y^4 + u^2*x^3*y^3 - 2*u*x^8*y^4 - 6*u*x^8*y^3 - 3*u*x^8*y^2 + 6*u*x^7*y^5 - 4*u*x^7*y^4 - 11*u*x^7*y^3 - 5*u*x^7*y^2 + 6*u*x^6*y^6 - 8*u*x^6*y^4 - 9*u*x^6*y^3 - u*x^6*y^2 + 10*u*x^5*y^7 - 6*u*x^5*y^5 - 4*u*x^5*y^4 - 3*u*x^5*y^3 + u*x^5*y^2 + 2*u*x^4*y^7 - 6*u*x^4*y^6 - 2*u*x^4*y^4 + u*x^4*y^3 - x^9*y^3 + 2*x^8*y^5 - x^8*y^4 - x^8*y^3 + 2*x^7*y^6 - x^7*y^5 - x^7*y^4 + 2*x^6*y^7 - x^6*y^6 - x^6*y^5 - x^5*y^6) * (two_eq_zero' (R := R))

/-- Lemma 3.3: P(1) = 0 (denominators cleared) -/
theorem P_one (x u t d v : R) (ht : t = x^2 + x) (hd : d = x + u) (hv : v = u^2 + u) :
    v^2 * 1 * t^4 + (d + v) * (d * 1^2 + (x^2 + u) * 1)^4 + (u^4 + x) * (d * 1^2 + (x^2 + u) * 1)^2 * t^2 = 0 := by
  subst ht hd hv
  linear_combination (2*u^6*x^4 + 4*u^6*x^3 + 2*u^6*x^2 + 8*u^6 + 2*u^5*x^6 + 6*u^5*x^5 + 6*u^5*x^4 + 2*u^5*x^3 + 16*u^5*x^2 + 16*u^5*x + 16*u^5 + u^4*x^8 + 4*u^4*x^7 + 6*u^4*x^6 + 4*u^4*x^5 + 13*u^4*x^4 + 24*u^4*x^3 + 44*u^4*x^2 + 40*u^4*x + u^3*x^8 + 4*u^3*x^7 + 10*u^3*x^6 + 16*u^3*x^5 + 37*u^3*x^4 + 68*u^3*x^3 + 40*u^3*x^2 + u^2*x^8 + 4*u^2*x^7 + 14*u^2*x^6 + 42*u^2*x^5 + 53*u^2*x^4 + 22*u^2*x^3 + u*x^8 + 10*u*x^7 + 24*u*x^6 + 22*u*x^5 + 7*u*x^4 + x^9 + 4*x^8 + 6*x^7 + 4*x^6 + x^5) * (two_eq_zero' (R := R))

/-- Lemma 3.3: P(x) = 0 (denominators cleared) -/
theorem P_x (x u t d v : R) (ht : t = x^2 + x) (hd : d = x + u) (hv : v = u^2 + u) :
    v^2 * x * t^4 + (d + v) * (d * x^2 + (x^2 + u) * x)^4 + (u^4 + x) * (d * x^2 + (x^2 + u) * x)^2 * t^2 = 0 := by
  subst ht hd hv
  linear_combination (u^6*x^8 + 4*u^6*x^7 + 6*u^6*x^6 + 4*u^6*x^5 + u^6*x^4 + 6*u^5*x^9 + 19*u^5*x^8 + 22*u^5*x^7 + 12*u^5*x^6 + 4*u^5*x^5 + u^5*x^4 + 14*u^4*x^10 + 37*u^4*x^9 + 42*u^4*x^8 + 30*u^4*x^7 + 12*u^4*x^6 + u^4*x^5 + 16*u^3*x^11 + 44*u^3*x^10 + 61*u^3*x^9 + 40*u^3*x^8 + 10*u^3*x^7 + 4*u^3*x^6 + u^3*x^5 + 8*u^2*x^12 + 44*u^2*x^11 + 56*u^2*x^10 + 13*u^2*x^9 + 4*u^2*x^8 + 6*u^2*x^7 + 4*u^2*x^6 + u^2*x^5 + 32*u*x^12 + 16*u*x^11 + 2*u*x^10 + 6*u*x^9 + 6*u*x^8 + 2*u*x^7 + 8*x^13 + 2*x^11 + 4*x^10 + 2*x^9) * (two_eq_zero' (R := R))

/-- Pi(y) = y (y+1) (y+x) (y+x+1) -/
theorem Pi_eq (x y t : R) (ht : t = x^2 + x) :
    y * (y + 1) * (y + x) * (y + x + 1) = y^4 + (t + 1) * y^2 + t * y := by
  subst ht
  linear_combination (x*y^3 + x*y^2 + y^3) * (two_eq_zero' (R := R))

/-- identity (3.3) multiplied by d^4 (d+v) -/
theorem a_eq (x u t d v : R) (ht : t = x^2 + x) (hd : d = x + u) (hv : v = u^2 + u) :
    t * v^2 = v^2 * (d + v) + v * d^2 * (d + v) + d^3 * (d + v) + d^4 := by
  subst ht hd hv
  linear_combination (-u^6 - u^5*x - 4*u^5 - 5*u^4*x - 5*u^4 - 3*u^3*x^2 - 8*u^3*x - u^3 - u^2*x^3 - 9*u^2*x^2 - 5*u*x^3 - x^4) * (two_eq_zero' (R := R))

/-- Lemma 3.4: t v / d^2 = v + v/d + v^2/d^2, multiplied by d^2 -/
theorem tv_eq (x u t d v : R) (ht : t = x^2 + x) (hd : d = x + u) (hv : v = u^2 + u) :
    t * v = v * d^2 + v * d + v^2 := by
  subst ht hd hv
  linear_combination (-u^4 - u^3*x - 2*u^3 - u^2*x - u^2) * (two_eq_zero' (R := R))

/-- Lemma 3.6: gamma = t v / (d^2 (d+v)) = v/d^2 + v/(d+v), multiplied by d^2 (d+v) -/
theorem gamma_eq (x u t d v : R) (ht : t = x^2 + x) (hd : d = x + u) (hv : v = u^2 + u) :
    t * v = v * (d + v) + v * d^2 := by
  subst ht hd hv
  linear_combination (-u^4 - u^3*x - 2*u^3 - u^2*x - u^2) * (two_eq_zero' (R := R))

/-- Lemma 3.6: v + t = d^2 + d -/
theorem vt_eq (x u t d v : R) (ht : t = x^2 + x) (hd : d = x + u) (hv : v = u^2 + u) :
    v + t = d^2 + d := by
  subst ht hd hv
  linear_combination (-u*x) * (two_eq_zero' (R := R))

/-- Lemma 3.1, with Yp standing for y^(2^m) and Yp + y = T_m(y^2 + y) -/
theorem L_Tm (x u y Yp t d : R) (ht : t = x^2 + x) (hd : d = x + u) :
    t * (Yp + y) + d * (y^2 + y) = t * Yp + d * y^2 + (x^2 + u) * y := by
  subst ht hd
  linear_combination (x*y) * (two_eq_zero' (R := R))

/-- Lemma 3.6: with z^2 = z + a and Zm standing for z^(2^m),
wp(l0) = v z^(2^m) + t z + d^2 z^2 + d z equals v (z^(2^m) + z) + d^2 a -/
theorem wp_ell (x u z a Zm t d v : R) (ht : t = x^2 + x) (hd : d = x + u) (hv : v = u^2 + u) :
    t * z + d^2 * (z + a) + d * z + v * Zm = v * (Zm + z) + d^2 * a := by
  subst ht hd hv
  linear_combination (u*x*z + x^2*z + x*z) * (two_eq_zero' (R := R))

end WelchSumFree

namespace WelchSumFree

/-- proof of Theorem 1.2: (x+1)(u+1) = xu + d + 1, in any commutative ring -/
theorem shift_eq {S : Type*} [CommRing S] (x u : S) : (x + 1) * (u + 1) = x * u + (x + u) + 1 := by ring

/-- Lemma 4.1 in any field: u x^3 g(1/x, y/x) = g(x, y), with Yp = y^(2^m) and u = x^(2^m), so that
(y/x)^(2^m) = Yp/u and (1/x)^(2^m) = 1/u. -/
theorem inverse_eq {K : Type*} [Field K] (x u y Yp : K) (hx : x ≠ 0) (hu : u ≠ 0) :
    u * x^3 * ((Yp / u) * ((1/x)^2 + 1/x) + (y/x)^2 * (1/u + 1/x) + (y/x) * ((1/x)^2 + 1/u))
      = Yp * (x^2 + x) + y^2 * (u + x) + y * (u + x^2) := by
  field_simp
  ring

/-- Lemma 2.1(a): in a field with 2^(2m+1) elements, rho(z^(2^m)) = z and rho(rho(z)) = z^2,
where rho(z) = z^(2^(m+1)). -/
theorem frob_facts {K : Type*} [Field K] [Fintype K] (m : ℕ) (hK : Fintype.card K = 2^(2*m+1)) (z : K) :
    (z^(2^m))^(2^(m+1)) = z ∧ (z^(2^(m+1)))^(2^(m+1)) = z^2 := by
  have hq : z^(2^(2*m+1)) = z := by rw [← hK]; exact FiniteField.pow_card z
  constructor
  · rw [← pow_mul, ← pow_add, show m + (m + 1) = 2*m+1 by ring, hq]
  · rw [← pow_mul, ← pow_add, show m + 1 + (m + 1) = (2*m+1) + 1 by ring, pow_succ, pow_mul, hq]

/-- the arithmetic of the proof of Theorem 1.2: with sum(alpha) = sum(beta) = K - 1 and
sum(alpha beta) = 1 - K, (q - 2) - sum(alpha) - sum(beta) + sum(alpha beta) = q + 1 - 3K -/
theorem count_arith (q K : ℤ) : (q - 2) - (K - 1) - (K - 1) + (1 - K) = q + 1 - 3 * K := by ring

/-- the bound after Theorem 1.2: if s = 2^(n/2) >= 6 and |K| <= 2s, then s^2 + 1 - 3K > 0 -/
theorem count_pos (s K : ℝ) (hs : 6 ≤ s) (hK : K ≤ 2 * s) : 0 < s^2 + 1 - 3 * K := by
  nlinarith

end WelchSumFree

#print axioms WelchSumFree.P_factor
#print axioms WelchSumFree.a_eq
#print axioms WelchSumFree.wp_ell
#print axioms WelchSumFree.inverse_eq
#print axioms WelchSumFree.frob_facts
#print axioms WelchSumFree.count_pos
