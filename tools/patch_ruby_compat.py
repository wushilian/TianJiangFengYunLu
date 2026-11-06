#!/usr/bin/env python3
import re
import shutil
import zlib
from pathlib import Path
from rubymarshal.reader import loads
from rubymarshal.writer import writes

from paths import GAME
SCRIPTS = GAME / "Data" / "Scripts.rxdata"

LINE_RE = re.compile(r'^(\s*when\s+[^\n:]+?)\s*(?<!:):(?!:)\s*')

def main():
    data = loads(SCRIPTS.read_bytes())
    changed = []
    for entry in data:
        name = entry[1].decode('utf-8', 'replace')
        try:
            code = zlib.decompress(entry[2]).decode('utf-8')
        except Exception:
            code = entry[2].decode('utf-8')
        lines = code.splitlines(True)
        new_lines = []
        count = 0
        for line in lines:
            new_line, n = LINE_RE.subn(r'\1 then ', line)
            if n:
                count += n
            new_lines.append(new_line)
        if count:
            backup = SCRIPTS.with_suffix(f'.rxdata.bak-ruby-{len(changed)}')
            entry[2] = zlib.compress(''.join(new_lines).encode('utf-8'), 9)
            changed.append((name, count))
    if not changed:
        print('no changes')
        return
    backup = SCRIPTS.with_suffix('.rxdata.bak-ruby-compat')
    if not backup.exists():
        shutil.copy2(SCRIPTS, backup)
    SCRIPTS.write_bytes(writes(data))
    print('patched:', changed)
    print('size:', SCRIPTS.stat().st_size)

if __name__ == '__main__':
    main()
