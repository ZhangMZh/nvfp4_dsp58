# SPDX-License-Identifier: MIT
"""Independent arithmetic oracle; no AMD tools or Python packages required."""

import random


def q(code):
    """Decode from E2M1 fields rather than the RTL's lookup tables."""
    sign, exponent, fraction = code >> 3, (code >> 1) & 3, code & 1
    magnitude = fraction if exponent == 0 else (2 + fraction) << (exponent - 1)
    return -magnitude if sign else magnitude


def dot(a, b):
    assert len(a) == len(b) == 16
    return sum(q(x) * q(y) for x, y in zip(a, b))


def packet(a, b):
    return sum(x << (4 * i) for i, x in enumerate(a + b))


def vectors():
    # Repeated full blocks exercise maximum magnitude and signed zero.
    for x in range(16):
        for y in range(16):
            yield [x] * 16, [y] * 16
    # Every code pair in every physical multiplier position, with other terms zero.
    for position in range(16):
        for x in range(16):
            for y in range(16):
                a, b = [0] * 16, [0] * 16
                a[position], b[position] = x, y
                yield a, b
    for x in range(16):
        yield [x] * 16, [7, 15] * 8
    rng = random.Random(0x16D558)
    for _ in range(8192):
        yield [rng.randrange(16) for _ in range(16)], [rng.randrange(16) for _ in range(16)]


def write_vectors(path):
    count = 0
    with path.open("w") as out:
        for a, b in vectors():
            out.write(f"{dot(a, b) & 0xFFFF:04x}{packet(a, b):032x}\n")
            count += 1
    return count


if __name__ == "__main__":
    import argparse
    from pathlib import Path

    parser = argparse.ArgumentParser(description="Write independent dot16 golden vectors.")
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    print(f"Wrote {write_vectors(args.output)} vectors to {args.output}")
