# comp-splice pin (import_comp_splice_boundary): bend3 exported a ~
# template across a module boundary and minted in the importer's book.
# the corpus is flat self-contained files, so the template inlines here,
# and bend's ~ law ct_each checks once, f an opaque constant; the call
# mints ct_each~0, its body at the lambda.
import Base

type CtL is Data:
  CtC{h: U32, t: CtL}
  CtN{}

law ct_each:
  for ~f: U32 -> U32
  for xs: CtL
  CtL

def ct_each(f, xs):
  match xs:
    case CtC{h, t}:
      CtC{f(h), ct_each(f, t)}
    case CtN{}:
      CtN{}

law ct_total:
  for xs: CtL
  U32

def ct_total(xs):
  match xs:
    case CtC{h, t}:
      (h + ct_total(t) : U32)
    case CtN{}:
      0

law main:
  U32

def main():
  ct_total(ct_each(x => (x + 1 : U32), CtC{1, CtC{2, CtN{}}}))

#|5
