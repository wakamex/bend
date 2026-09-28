# Array.spread writes i * 3 + x into cell i of a 4096-cell buffer for
# every i below 4000, once in sequence and once under a bang (on a GPU,
# split across the lanes); each fold of the cells then gives
# 3 * (0 + ... + 3999) + 4000 * 7 = 23994000 + 28000 = 24022000
import Base

def put(+i: U32, +x: U32, buf: Array<U32>) -> Array<U32>:
  Array.set(U32, buf, i, U32.add(U32.mul(i, 3), x))

@unsafe
def fill(buf: Array<U32>) -> Array<U32>:
  Array.spread(~U32, ~U32, ~put, buf, 4000, 7)

law fold:
  for  b: Array<U32>
  for +n: Nat
  for +s: U32
  U32

@unsafe
def fold.at(n: Nat, +s: U32, r: Array<U32> & U32) -> U32:
  (b, x) = r
  fold(b, n, U32.add(s, x))

def fold(b, n, s):
  match n:
    case 0n:
      s
    case 1n+p:
      fold.at(p, s, Array.get(U32, b, U32.from_nat(p)))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(fold(fill(Array.new(U32, 12n, 0)), 4096n, 0)))
    IO.print(U32.show(fold(fill!(Array.new(U32, 12n, 0)), 4096n, 0)))

#|24022000
#|24022000
