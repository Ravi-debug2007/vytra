"""Oracle tests for Lab conversion, bins, and aggregation."""

from __future__ import annotations

import math
import unittest

from cielab_reference import load_goldens, max_delta, rgb255_to_lab, apply_white_patch, white_ref_accept
from classify import (
    HIGH,
    LOW,
    MODERATE,
    UNABLE,
    classify_anemia,
    classify_anemia_series,
    classify_jaundice,
    classify_jaundice_series,
)


class TestCielab(unittest.TestCase):
    def test_goldens(self) -> None:
        data = load_goldens()
        for row in data["samples"]:
            got = rgb255_to_lab(*row["rgb255"])
            delta = max_delta(got, row)
            self.assertLessEqual(
                delta,
                0.05,
                msg=f"{row['name']} Δ={delta:.4f} got={got}",
            )

    def test_white_black(self) -> None:
        self.assertAlmostEqual(rgb255_to_lab(255, 255, 255)[0], 100.0, places=2)
        self.assertAlmostEqual(rgb255_to_lab(0, 0, 0)[0], 0.0, places=2)

    def test_white_patch_rejects_zero_gain(self) -> None:
        with self.assertRaises(ValueError):
            apply_white_patch(200, 200, 200, 0.0, 0.8, 0.8)

    def test_white_ref_cast_fails(self) -> None:
        self.assertFalse(white_ref_accept(200, 160, 140, (0.0, 0.0, 0.0)))

    def test_white_ref_accepts_paper(self) -> None:
        self.assertTrue(white_ref_accept(236, 234, 228, (0.0, 0.0, 0.0)))


class TestClassify(unittest.TestCase):
    def test_anemia_boundaries(self) -> None:
        data = load_goldens()
        for row in data["classify_boundaries"]["anemia"]:
            self.assertEqual(classify_anemia(row["a"]), row["expect"])

    def test_jaundice_boundaries(self) -> None:
        data = load_goldens()
        for row in data["classify_boundaries"]["jaundice"]:
            self.assertEqual(classify_jaundice(row["b"]), row["expect"])

    def test_sample_classes(self) -> None:
        data = load_goldens()
        for row in data["samples"]:
            lab = rgb255_to_lab(*row["rgb255"])
            if "anemia_class" in row:
                self.assertEqual(classify_anemia(lab[1]), row["anemia_class"])
            if "jaundice_class" in row:
                self.assertEqual(classify_jaundice(lab[2]), row["jaundice_class"])

    def test_aggregate_unable(self) -> None:
        self.assertEqual(classify_anemia_series([])[0], UNABLE)
        self.assertIsNone(classify_anemia_series([8.0])[1])
        self.assertEqual(classify_jaundice_series([12.0])[0], UNABLE)

    def test_aggregate_median_of_two(self) -> None:
        risk, signal = classify_anemia_series([4.0, 12.0])
        self.assertIsNotNone(signal)
        self.assertTrue(math.isclose(signal or 0.0, 8.0))
        self.assertEqual(risk, MODERATE)

    def test_aggregate_median_of_three(self) -> None:
        risk, signal = classify_jaundice_series([4.0, 16.0, 11.0])
        self.assertTrue(math.isclose(signal or 0.0, 11.0))
        self.assertEqual(risk, MODERATE)


if __name__ == "__main__":
    unittest.main()
