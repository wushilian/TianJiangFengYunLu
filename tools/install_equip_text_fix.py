#!/usr/bin/env python3
import shutil
import zlib
from pathlib import Path

from rubymarshal.reader import loads
from rubymarshal.writer import writes

from paths import GAME
SCRIPTS = GAME / "Data" / "Scripts.rxdata"
SOURCE = Path(__file__).with_name("tianjiang_equip_text_fix.rb")
NAME = b"TianJiangEquipTextFix"
MAGIC = 99000005


def main():
    source = SOURCE.read_text(encoding="utf-8")
    data = loads(SCRIPTS.read_bytes())
    data = [x for x in data if x[1] != NAME]
    main_index = next(i for i, x in enumerate(data) if x[1] == b"Main")
    data.insert(main_index, [MAGIC, NAME, zlib.compress(source.encode("utf-8"), 9)])
    backup = SCRIPTS.with_suffix(".rxdata.bak-equip-text")
    if not backup.exists():
        shutil.copy2(SCRIPTS, backup)
    SCRIPTS.write_bytes(writes(data))
    check = loads(SCRIPTS.read_bytes())
    names = [x[1].decode("utf-8", "replace") for x in check]
    assert names[-1] == "Main"
    assert names[-2] == NAME.decode()
    code = zlib.decompress(check[-2][2]).decode("utf-8")
    assert "Window_zhuangbei" in code
    print("scripts:", len(check), "main_index:", main_index, "inserted:", NAME.decode())
    print("last:", names[-4:])
    print("verified; size:", SCRIPTS.stat().st_size)


if __name__ == "__main__":
    main()
