import re, sys

env = {'__METAL_VERSION__': '320', '__APPLE__': '1'}


def ev(expr):
    e = re.sub(r'defined\s*\(\s*(\w+)\s*\)', lambda m: '1' if m.group(1) in env else '0', expr)
    e = re.sub(r'defined\s+(\w+)', lambda m: '1' if m.group(1) in env else '0', e)
    e = re.sub(r'\b[A-Za-z_]\w*\s*\([^()]*\)', '0', e)
    for _ in range(5):
        e = re.sub(r'\b([A-Za-z_]\w*)\b', lambda m: env.get(m.group(1), '0'), e)
    e = e.replace('&&', ' and ').replace('||', ' or ').replace('!', ' not ').replace('not =', '!=')
    e = re.sub(r'(\d+)u?ll?\b', r'\1', e)
    try:
        return bool(eval(e))
    except Exception:
        return False


def kept(path):
    stack, active, out = [], True, []
    for n, line in enumerate(open(path, encoding='utf-8'), 1):
        m = re.match(r'#\s*(ifdef|ifndef|if|elif|else|endif|define|undef)\b\s*(.*)', line.strip())
        if not m:
            if active:
                out.append((n, line.rstrip()))
            continue
        d, rest = m.groups()
        if d in ('ifdef', 'ifndef', 'if'):
            c = rest.split()[0] in env if d == 'ifdef' else rest.split()[0] not in env if d == 'ifndef' else ev(rest)
            stack.append((active, c))
            active = active and c
        elif d == 'elif':
            par, taken = stack.pop()
            c = not taken and ev(rest)
            stack.append((par, taken or c))
            active = par and c
        elif d == 'else':
            par, taken = stack.pop()
            stack.append((par, True))
            active = par and not taken
        elif d == 'endif':
            active = stack.pop()[0]
        elif d == 'define' and active:
            mm = re.match(r'(\w+)(?:\s+(.*))?$', rest)
            if mm:
                env[mm.group(1)] = (mm.group(2) or '1').split('//')[0].strip() or '1'
        elif d == 'undef' and active:
            env.pop(rest.split()[0], None)
    return out


if __name__ == '__main__':
    pat = re.compile(r'\bdouble\b|f64_num\(|f64_of\(|0x1p64|\bfma\(|\bsqrt\(|__umul64hi|__int128')
    bad = 0
    for path in sys.argv[1:]:
        ls = kept(path)
        hits = [(n, l) for n, l in ls if pat.search(l) and not l.strip().startswith('//')]
        bad += len(hits)
        print(f'{path.split("/")[-1]}: {len(ls)} lines kept for Metal, {len(hits)} with double, __int128 or __umul64hi')
        for n, l in hits[:20]:
            print(f'  {n}: {l.strip()[:140]}')
    sys.exit(1 if bad else 0)
