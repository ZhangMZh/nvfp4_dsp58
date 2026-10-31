# SPDX-License-Identifier: MIT
from fractions import Fraction
import unittest

from reference import SCALES, dot, packet, q, scaled_dot, scaled_packet, vectors


class ReferenceTests(unittest.TestCase):
    def test_encoding(self):
        values = [0, 1, 2, 3, 4, 6, 8, 12]
        self.assertEqual([q(i) for i in range(16)], values + [-x for x in values])

    def test_carry_sign_identity(self):
        for a in range(16):
            for b in range(16):
                magnitude = abs(q(a) * q(b))
                sign = (a ^ b) >> 3
                nine_bits = magnitude ^ (511 if sign else 0)
                signed_c = nine_bits - 512 if nine_bits & 256 else nine_bits
                self.assertEqual(signed_c + sign, q(a) * q(b))

    def test_extrema_and_packing(self):
        self.assertEqual(dot([7] * 16, [7] * 16), 2304)
        self.assertEqual(dot([7] * 16, [15] * 16), -2304)
        self.assertEqual(dot([7] * 16, [7, 15] * 8), 0)
        a, b = list(range(16)), list(reversed(range(16)))
        packed = packet(a, b)
        self.assertEqual([(packed >> (4 * i)) & 15 for i in range(32)], a + b)

    def test_vector_bounds(self):
        for a, b in vectors():
            self.assertLessEqual(abs(dot(a, b)), 2304)


class ScaledReferenceTests(unittest.TestCase):
    def test_scale_decode(self):
        for code, value in enumerate(SCALES):
            exponent, fraction = (code >> 3) & 15, code & 7
            if code & 127 == 127:
                self.assertIsNone(value)
                continue
            integer = fraction if exponent == 0 else (8 + fraction) << (exponent - 1)
            if code & 128:
                integer = -integer
            self.assertEqual(value * 512, integer)
        self.assertEqual(SCALES[1], Fraction(1, 512))
        self.assertEqual(SCALES[0x7e], 448)
        self.assertEqual(SCALES[0xfe], -448)
        self.assertEqual(SCALES[0x38], 1)
        self.assertEqual(SCALES[0x80], 0)

    def test_all_scale_pairs(self):
        for sa, a in enumerate(SCALES):
            for sb, b in enumerate(SCALES):
                result, invalid = scaled_dot([1] + [0] * 15, [1] + [0] * 15, sa, sb)
                self.assertEqual(invalid, a is None or b is None)
                if invalid:
                    self.assertEqual(result, 0)
                else:
                    self.assertEqual(Fraction(result, 1 << 20), a * b / 4)
                    self.assertLessEqual(abs(result * 2304), 121221156962304)

    def test_extrema_unity_and_invalid(self):
        a, b = [7] * 16, [7] * 16
        self.assertEqual(scaled_dot(a, b, 0x7e, 0x7e), (121221156962304, False))
        self.assertEqual(scaled_dot(a, b, 0xfe, 0x7e), (-121221156962304, False))
        self.assertEqual(scaled_dot(a, b, 0x38, 0x38), (dot(a, b) << 18, False))
        self.assertEqual(scaled_dot([0] * 16, b, 0x7f, 0), (0, True))
        self.assertEqual(scaled_dot(a, b, 0x80, 0xfe), (0, False))

    def test_packing(self):
        a, b = list(range(16)), list(reversed(range(16)))
        word = scaled_packet(a, b, 0x3c, 0xc0)
        self.assertEqual(word >> 128, 0xc03c)
        self.assertEqual([(word >> (4 * i)) & 15 for i in range(32)], a + b)


if __name__ == "__main__":
    import argparse
    import sys

    parser = argparse.ArgumentParser(
        description="Run dot16 arithmetic tests; additional options (such as -v) go to unittest.")
    parser.add_argument("--block-scaling", action="store_true",
                        help="Run both base arithmetic and exact E4M3 scaling tests.")
    args, remaining = parser.parse_known_args()
    selected = ["ReferenceTests"]
    if args.block_scaling:
        selected.append("ScaledReferenceTests")
    unittest.main(argv=[sys.argv[0]] + remaining, defaultTest=selected)
