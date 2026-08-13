"""Risk classification and series aggregation. threshold_version = th-1.0.0

Prototype heuristics. Not Tamir 2017. Not a clinical cutoff.
"""

from __future__ import annotations

from statistics import median
from typing import Optional, Sequence

HIGH = "HIGH"
MODERATE = "MODERATE"
LOW = "LOW"
UNABLE = "UNABLE_TO_ASSESS"


def classify_anemia(a_star: float) -> str:
    if a_star < 5.0:
        return HIGH
    if a_star < 10.0:
        return MODERATE
    return LOW


def classify_jaundice(b_star: float) -> str:
    if b_star >= 15.0:
        return HIGH
    if b_star >= 10.0:
        return MODERATE
    return LOW


def aggregate(values: Sequence[float]) -> tuple[str, Optional[float]]:
    """< 2 valid → UNABLE, signal None. n=2 median is the arithmetic mean."""
    valid = [float(v) for v in values]
    if len(valid) < 2:
        return UNABLE, None
    return "", float(median(valid))


def classify_anemia_series(values: Sequence[float]) -> tuple[str, Optional[float]]:
    _, signal = aggregate(values)
    if signal is None:
        return UNABLE, None
    return classify_anemia(signal), signal


def classify_jaundice_series(values: Sequence[float]) -> tuple[str, Optional[float]]:
    _, signal = aggregate(values)
    if signal is None:
        return UNABLE, None
    return classify_jaundice(signal), signal
