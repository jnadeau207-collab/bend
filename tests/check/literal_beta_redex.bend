# a literal lambda application is a beta-redex: term_higher takes its
# beta steps as it builds it, and the substituted body, a constructor,
# checks against the goal as any constructor does. in an infer position
# (a let's value) the constructor it leaves cannot infer.
import Base

law main:
  U32

def main(): (x => x)(3)

#|3
