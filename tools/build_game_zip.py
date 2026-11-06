#!/usr/bin/env python3
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

from paths import REPO, GAME
OUT = REPO / "app" / "src" / "main" / "assets" / "game.zip"
CORE = REPO / "app" / "src" / "main" / "assets" / "core.zip"

CORE_FILES = (
    "Data/Scripts.rxdata", "mkxp.json", "mkxp_compat.rb",
    "Data/Map020.rxdata", "Data/Enemies.rxdata", "Data/Troops.rxdata",
    # 1.5.26 文本统一：涉及改名的地图 + 游戏结束图名
    "Data/System.rxdata",
    "Data/Map001.rxdata", "Data/Map046.rxdata", "Data/Map047.rxdata",
    "Data/Map048.rxdata", "Data/Map053.rxdata", "Data/Map062.rxdata",
    "Data/Map084.rxdata", "Data/Map102.rxdata", "Data/Map104.rxdata",
    "Data/Map108.rxdata", "Data/Map110.rxdata", "Data/Map111.rxdata",
    "Data/Map119.rxdata", "Data/Map121.rxdata", "Data/Map122.rxdata",
    "Data/Map146.rxdata", "Data/Map149.rxdata",
    # 1.5.27 南疆提示与防具店/货店入口
    "Data/Map136.rxdata", "Data/Map140.rxdata",
    "Data/Map138.rxdata", "Data/Map139.rxdata",
)

EXCLUDE_SUFFIXES = (".bak-true-ending", ".bak", ".tmp")
EXCLUDE_PREFIXES = ("Scripts.rxdata.bak",)
EXCLUDE_NAMES = {".DS_Store", "Thumbs.db"}


def main():
    tmp = OUT.with_suffix(".zip.tmp")
    count = 0
    with ZipFile(tmp, "w", ZIP_DEFLATED, compresslevel=9) as z:
        for path in sorted(GAME.rglob("*")):
            if not path.is_file():
                continue
            if path.name in EXCLUDE_NAMES or path.name.endswith(EXCLUDE_SUFFIXES):
                continue
            if any(path.name.startswith(prefix) for prefix in EXCLUDE_PREFIXES):
                continue
            if ".bak" in path.name:
                continue
            z.write(path, path.relative_to(GAME).as_posix())
            count += 1
    tmp.replace(OUT)
    print("wrote", OUT, "files", count, "bytes", OUT.stat().st_size)

    core_tmp = CORE.with_suffix(".zip.tmp")
    with ZipFile(core_tmp, "w", ZIP_DEFLATED, compresslevel=9) as z:
        for name in CORE_FILES:
            z.write(GAME / name, name)
    core_tmp.replace(CORE)
    print("wrote", CORE, "files", len(CORE_FILES), "bytes", CORE.stat().st_size)


if __name__ == "__main__":
    main()
