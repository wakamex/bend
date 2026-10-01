# io (io_bang_loop_heap): a loop over IO whose bang forks keeps its heap:
# after a warm-up, the bump stays put. The fork's join continues the bang's
# root, as the root task the host made does, and the device left both to
# the host, which frees only its own: a node a bang, which ran gtube's
# visualizer out of memory after hours. Off the GPU the bump reads 0: the
# CPU's threads keep free nodes until a generation fills, which a loop
# this short does not reach.
import Base

def heap.bump() -> IO(U32):
  import "./bang_loop_heap.c"
  import "./bang_loop_heap.js"

def touch(+k: U32, a: Array<U32>) -> Array<U32>:
  Array.set(U32, a, 0, k)

@unsafe
def pair(+k: U32, a: Array<U32>, b: Array<U32>) -> Array<U32> & Array<U32>:
  x y = touch(k, a) touch(k, b)
  (x, y)

@unsafe
def run(n: Nat, p: Array<U32> & Array<U32>) -> IO(Array<U32> & Array<U32>):
  match n:
    case 0n:
      IO.pure(Array<U32> & Array<U32>, p)
    case 1n+r:
      (a, b) = p
      do IO<Array<U32> & Array<U32>>:
        k : U32 <- heap.bump()
        run(r, pair!(k, a, b))

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    p : Array<U32> & Array<U32> <- run(50n, ([0 : U32^4n], [0 : U32^4n]))
    b0 : U32 <- heap.bump()
    q : Array<U32> & Array<U32> <- run(500n, p)
    b1 : U32 <- heap.bump()
    IO.print(U32.show((b1 - b0 : U32)))

#|0
