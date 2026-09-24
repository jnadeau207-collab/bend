# two @unsafe defs recurse into each other through their laws: an unsafe
# body may call a law not yet filled, as it may call itself without descent
import Base

type Term is Type:
  TRef{k: String}
  TLam{f: Term -> Term}
  TApp{f: Term, x: Term}

law wnf:
  for x: Term
  Term

law wnf_app:
  for f: Term
  for x: Term
  Term

@unsafe
def wnf_app(f, x):
  match f:
    case TLam{b}:
      wnf(b(x))
    case g:
      TApp{g, x}

@unsafe
def wnf(x):
  match x:
    case TApp{f, a}:
      wnf_app(wnf(f), a)
    case term:
      term

def show(t: Term) -> String:
  match t:
    case TRef{k}:
      k
    case TLam{f}:
      "lam"
    case TApp{f, x}:
      "app"

def main() -> String:
  show(wnf(TApp{TLam{x => TApp{x, TRef{"y"}}}, TLam{z => z}}))

#|"y"
