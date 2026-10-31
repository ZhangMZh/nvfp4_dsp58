# SPDX-License-Identifier: MIT
"""Independent arithmetic oracle; no AMD tools or Python packages required."""

from fractions import Fraction
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


def scale(code):
    exponent, fraction = (code >> 3) & 15, code & 7
    if exponent == 15 and fraction == 7:
        return None
    value = (Fraction(fraction, 8) if exponent == 0 else 1 + Fraction(fraction, 8))
    value *= Fraction(2) ** (max(exponent, 1) - 7)
    return -value if code & 128 else value


SCALES = tuple(scale(code) for code in range(256))


def scaled_dot(a, b, scale_a, scale_b):
    sa, sb = SCALES[scale_a], SCALES[scale_b]
    if sa is None or sb is None:
        return 0, True
    result = Fraction(dot(a, b), 4) * sa * sb * (1 << 20)
    assert result.denominator == 1
    return int(result), False


def scaled_packet(a, b, scale_a, scale_b):
    return packet(a, b) | (scale_a << 128) | (scale_b << 136)


def scaled_vectors():
    # Exercise changing signs/exponents/invalid flags during the initial II/latency checks.
    for index in range(1024):
        yield [7] * 16, [15 if index & 1 else 7] * 16, index & 255, (index * 37) & 255
    # Preserve every existing position/code pair and all original arithmetic cases.
    for a, b in vectors():
        yield a, b, 0x38, 0x38
    # Every scale-byte pair, at the minimum nonzero and negative maximum dot.
    for sa in range(256):
        for sb in range(256):
            yield [1] + [0] * 15, [1] + [0] * 15, sa, sb
            yield [7] * 16, [15] * 16, sa, sb
    edges = (0, 0x80, 1, 0x81, 7, 8, 0x38, 0x77, 0x78, 0x7e, 0xfe, 0x7f, 0xff)
    for sa in edges:
        for sb in edges:
            yield [7] * 16, [7] * 16, sa, sb
            yield [7] * 16, [7, 15] * 8, sa, sb
            yield [0, 8] * 8, [7] * 16, sa, sb
    rng = random.Random(0x5CA1ED)
    for _ in range(8192):
        yield ([rng.randrange(16) for _ in range(16)], [rng.randrange(16) for _ in range(16)],
               rng.randrange(256), rng.randrange(256))


def write_vectors(path, block_scaling=False):
    count = 0
    with path.open("w") as output:
        if block_scaling:
            for a, b, sa, sb in scaled_vectors():
                result, invalid = scaled_dot(a, b, sa, sb)
                word = (result & ((1 << 48) - 1)) | (int(invalid) << 48)
                output.write(f"{word:016x}{scaled_packet(a, b, sa, sb):036x}\n")
                count += 1
        else:
            for a, b in vectors():
                output.write(f"{dot(a, b) & 0xFFFF:04x}{packet(a, b):032x}\n")
                count += 1
    return count


if __name__ == "__main__":
    import argparse
    from pathlib import Path

    parser = argparse.ArgumentParser(description="Write independent dot16 golden vectors.")
    parser.add_argument("output", type=Path)
    parser.add_argument("--block-scaling", action="store_true",
                        help="Apply exact E4M3 block scaling and emit 144/64-bit vectors.")
    args = parser.parse_args()
    count = write_vectors(args.output, args.block_scaling)
    print(f"Wrote {count} vectors to {args.output}")
