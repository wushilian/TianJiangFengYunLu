from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
GAME = REPO / "tianjiang_game"
if not GAME.exists():
    GAME = REPO.parent / "tianjiang_game"
