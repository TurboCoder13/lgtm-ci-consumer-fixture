from fixture_private import answer


def test_answer() -> None:
    assert answer() == 42
