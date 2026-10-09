#!/usr/bin/env bash
# check_welch.sh -- bash integer arithmetic only.
#
#  (1) In F_32 and F_128 (moduli X^5+X^2+1 and X^7+X+1): for every x outside F_2, count the y with
#      g(x,y) = 0 by trying all y, so |Z(x)| is 4 or 8; count the x with |Z(x)| = 8 and compare with
#      the trace criterion of Theorem 1.1 and with N_5 = 0, N_7 = 42 of Table 1.
#  (2) The Kloosterman sums K_n of F_32 and F_128, summed directly, against Carlitz's recurrence.
#  (3) For odd 5 <= n <= 61: K_n from the recurrence, N_n = (2^n+1-3K_n)/4, and the values of Table 1.
# Prints "ALL OK" at the end if every check passed.
set -u
FAILED=0

check_field() {
  local n=$1 mod=$2 m=$(( ($1 - 1) / 2 )) q=$(( 1 << $1 ))
  local -a M SQ
  local a b r i
  for (( a = 0; a < q; a++ )); do
    for (( b = 0; b < q; b++ )); do
      local x=$a y=$b; r=0
      while (( y )); do
        (( y & 1 )) && (( r ^= x ))
        (( y >>= 1, x <<= 1 ))
        (( (x >> n) & 1 )) && (( x ^= mod ))
      done
      M[a*q+b]=$r
    done
    SQ[a]=${M[a*q+a]}
  done
  frob() { local z=$1 k=$2; while (( k-- > 0 )); do z=${SQ[z]}; done; echo $z; }
  local -a FM INV TR
  for (( a = 0; a < q; a++ )); do
    FM[a]=$(frob $a $m)
    local t=0 z=$a
    for (( i = 0; i < n; i++ )); do (( t ^= z )); z=${SQ[z]}; done
    TR[a]=$t
    for (( b = 1; b < q; b++ )); do (( ${M[a*q+b]} == 1 )) && INV[a]=$b; done
  done
  INV[0]=0
  local N=0 crit=0 mism=0 x u x2 A B C y cnt g K=0
  for (( x = 2; x < q; x++ )); do
    u=${FM[x]}; x2=${SQ[x]}
    (( A = x2 ^ x, B = u ^ x, C = u ^ x2 ))
    cnt=0
    for (( y = 0; y < q; y++ )); do
      (( g = ${M[${FM[y]}*q+A]} ^ ${M[${SQ[y]}*q+B]} ^ ${M[y*q+C]} ))
      if (( g == 0 )); then (( cnt += 1 )); fi
    done
    if (( cnt != 4 && cnt != 8 )); then FAILED=1; fi
    local d=$(( x ^ u )); local di=${INV[d]}
    local c=0
    (( ${TR[di]} == 1 && ${TR[${M[${M[x*q+u]}*q+di]}]} == 1 )) && c=1
    if (( cnt == 8 )); then (( N += 1 )); fi
    if (( c == 1 )); then (( crit += 1 )); fi
    if (( (cnt == 8) != c )); then (( mism += 1 )); fi
  done
  for (( a = 1; a < q; a++ )); do
    if (( ${TR[a ^ ${INV[a]}]} )); then (( K -= 1 )); else (( K += 1 )); fi
  done
  echo "n=$n: x with |Z(x)| = 8: $N; by the trace criterion: $crit; mismatches: $mism; K_n = $K"
  (( mism == 0 && N == crit )) || FAILED=1
  eval "N_$n=$N K_$n=$K"
}

check_field 5 $(( 0x25 ))
check_field 7 $(( 0x83 ))
(( N_5 == 0 && N_7 == 42 )) || FAILED=1

declare -a KR
KR[0]=-2; KR[1]=1
for (( k = 2; k <= 61; k++ )); do (( KR[k] = -KR[k-1] - 2 * KR[k-2] )); done
(( KR[5] == K_5 && KR[7] == K_7 )) || FAILED=1
table="5:0 7:42 9:132 11:462 13:2184 15:7986 17:32844 19:131670 21:522192"
for entry in $table; do
  n=${entry%%:*}; want=${entry##*:}
  (( v = (1 << n) + 1 - 3 * KR[n] ))
  (( v % 4 == 0 && v / 4 == want )) || { echo "Table 1 mismatch at n=$n"; FAILED=1; }
done
for (( n = 7; n <= 61; n += 2 )); do
  (( v = (1 << n) + 1 - 3 * KR[n] ))
  (( v > 0 && v % 4 == 0 )) || { echo "N_n not a positive integer at n=$n"; FAILED=1; }
done
echo "Table 1 reproduced from the recurrence; N_n is a positive integer for odd 7 <= n <= 61"
if (( FAILED == 0 )); then echo "ALL OK"; else echo "FAILED"; exit 1; fi
