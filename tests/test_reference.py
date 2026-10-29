# SPDX-License-Identifier: MIT
import unittest

from reference import dot, packet, q, vectors


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


if __name__ == "__main__":
    unittest.main()
