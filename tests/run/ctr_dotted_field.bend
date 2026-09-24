# a dot inside a field name is a character, not a path. once the JS
# emitter read a field as x.a.b, so this Outer answered its Inner's 5
import Base

type Inner is Data:
  Inner{b: U32}

type Outer is Data:
  Outer{a: Inner, a.b: U32}

def second(x: Outer) -> U32:
  match x:
    case Outer{p, q}:
      q

law second_is_nine:
  {second(Outer{Inner{5}, 9}) == 9 : U32}

def second_is_nine():
  {==}

def main() -> U32:
  second(Outer{Inner{5}, 9})

#|9
