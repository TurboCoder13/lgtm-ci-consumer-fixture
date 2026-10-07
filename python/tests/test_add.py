"""Tests for the fixture's ``add`` helper."""

from fixture_py import add


def test_add() -> None:
    """``add`` sums two integers."""
    assert add(2, 3) == 5  # nosec B101 - pytest assertion
