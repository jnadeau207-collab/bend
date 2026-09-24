# a bang runs sin, cos and tan on the GPU, where they are Metal's fast::
# trig: each leaf keeps three digits of sin x + cos x + tan x, and the
# GPU, libm and Math sum them alike
import Base

law wave:
  for +d: Nat
  for +x: F32
  U32

def wave(d, x):
  match d:
    case 0n:
      s = (F32.sin(x) + F32.cos(x) + F32.tan(x) + 8.0 : F32)
      F32.to_u32((s * 1000.0 : F32))
    case 1n+p:
      a b = wave(p, x) wave(p, (x + 0.1 : F32))
      U32.add(a, b)

law main:
  IO(Unit)

def main():
  IO.print(U32.show(wave!(3n, 0.3)))

#|78542
