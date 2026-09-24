# io (io_sleep_late_order): three workers sleep 30, 10 and 20 ms; main
# sleeps 1 ms (the workers arm their timers), then spins on the clock past
# all three deadlines before it waits again. A late wait once woke every
# due timer in the order they parked (1, 2, 3); it wakes the earliest
# first, so sleeps end in deadline order, 2, 3, 1, on every lane.
import Base

law work:
  for ms: U32
  for +n: U32
  IO(U32)

def work(ms, n):
  do IO<U32>:
    Unit <- IO.sleep(ms)
    Unit <- IO.print(String.append("done ", U32.show(n)))
    return n

# holds the thread (no timer) until the clock passes t
def spin(n: Nat, +t: Nat) -> IO(Unit):
  match n:
    case 0n:
      IO.pure(Unit, Unit{})
    case 1n+p:
      IO.bind(Nat, Unit, IO.now(), u => Bool.pick(IO(Unit), Nat.is_lt(u, t),
        spin(p, t), IO.pure(Unit, Unit{})))

law main:
  IO(U32)

def main():
  do IO<U32>:
    a : Chan(U32) <- IO.fork(U32, work(30, 1))
    b : Chan(U32) <- IO.fork(U32, work(10, 2))
    c : Chan(U32) <- IO.fork(U32, work(20, 3))
    Unit <- IO.sleep(1)
    t : Nat <- IO.now()
    Unit <- spin(100000000n, Nat.add(t, 40n))
    x : U32 <- IO.join(U32, a)
    y : U32 <- IO.join(U32, b)
    z : U32 <- IO.join(U32, c)
    Unit <- IO.print(U32.show((x + (y + z : U32) : U32)))
    return 0

#|done 2
#|done 3
#|done 1
#|6
