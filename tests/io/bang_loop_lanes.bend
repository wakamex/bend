# io (io_bang_loop_lanes): a loop over IO whose bang spreads a frame over
# every lane keeps its heap after a warm-up. A device lane kept its free
# chain between kernels, and the lanes freeing a class move from kernel to
# kernel, each keeping up to a generation of a class it no longer used (on
# 32,768 lanes, up to 64 MB a class). The bump reads as in
# io_bang_loop_heap.
import Base

def heap.bump() -> IO(U32):
  import "./bang_loop_heap.c"
  import "./bang_loop_heap.js"

type K is Data:
  K{t: F32, zoom: F32, mid: F32, hue: F32, beat: F32, w: U32, h: U32}

def px(+x: U32, +y: U32, +k: K) -> U32:
  K{t, zoom, mid, hue, beat, w, h} = k
  +dx = ((U32.to_f32(x) - U32.to_f32(w) * 0.5) * zoom : F32)
  +dy = ((U32.to_f32(y) - U32.to_f32(h) * 0.5) * zoom : F32)
  F32.to_u32((128.0 + 127.0 * F32.sin((dx + dy + t : F32)) : F32))

def lput(inside: Bool, +i: U32, +x: U32, +y: U32, +k: K, a: Array<U32>) -> Array<U32>:
  match inside:
    case True{}:
      Array.set(U32, a, i, px(x, y, k))
    case False{}:
      a

def lin(n: Nat, +i: U32, +x: U32, +y: U32, +d: U32, +e: U32, +k: K, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+r:
      K{t, zoom, mid, hue, beat, w, h} = k
      +c = Bool.to_u32((x + d >= w : U32))
      lin(r, (i + 32768 : U32), (x + d - c * w : U32), (y + e + c : U32), d, e, k, lput((i < w * h : U32), i, x, y, k, a))

def leaf(+j: U32, +k: K, a: Array<U32>) -> Array<U32>:
  K{t, zoom, mid, hue, beat, w, h} = k
  lin(U32.to_nat(((w * h + 32767) / 32768 : U32)), j, (j % w : U32), (j / w : U32), (32768 % w : U32), (32768 / w : U32), k, a)

@unsafe
def frame(+k: K, a: Array<U32>) -> Array<U32>:
  Array.spread(~U32, ~K, ~leaf, a, 32768, k)

@unsafe
def pair(+k: K, +k2: K, a: Array<U32>, b: Array<U32>) -> Array<U32> & Array<U32>:
  x y = frame(k, a) frame(k2, b)
  (x, y)

def kof(+s: U32, +o: F32) -> K:
  K{(U32.to_f32(s) + o : F32), 0.05, 0.3, 0.3, 0.0, 128, 64}

@unsafe
def step(r: Nat, +s: U32, a: Array<U32>, b: Array<U32>) -> IO(Array<U32> & Array<U32>):
  run(r, pair!(kof(s, 0.0), kof(s, 0.5), a, b))

@unsafe
def run(n: Nat, p: Array<U32> & Array<U32>) -> IO(Array<U32> & Array<U32>):
  match n:
    case 0n:
      IO.pure(Array<U32> & Array<U32>, p)
    case 1n+r:
      (a, b) = p
      do IO<Array<U32> & Array<U32>>:
        s : U32 <- heap.bump()
        step(r, s, a, b)

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    p : Array<U32> & Array<U32> <- run(100n, ([0 : U32^15n], [0 : U32^15n]))
    b0 : U32 <- heap.bump()
    q : Array<U32> & Array<U32> <- run(300n, p)
    b1 : U32 <- heap.bump()
    IO.print(U32.show((b1 - b0 : U32)))

#|0
