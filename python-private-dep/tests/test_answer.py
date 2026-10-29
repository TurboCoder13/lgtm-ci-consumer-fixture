"""Tests for the frozen-install private dependency fixture."""

import pytest
from fixture_private import answer


def test_answer() -> None:
    """Verify the public package works without installing the private group."""
    if answer() != 42:
        pytest.fail("The frozen fixture must return the expected answer")
