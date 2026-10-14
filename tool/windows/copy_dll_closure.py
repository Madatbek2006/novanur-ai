"""Копирует DLL вместе со всем, от чего она зависит, — и ничего лишнего.

Установщик Tesseract (UB-Mannheim) кладёт 51 DLL на 158 МБ: вместе с
распознаванием там инструменты обучения моделей (pango, cairo, ICU…).
Программе нужна только libtesseract-5.dll и цепочка её зависимостей —
её и находим по таблицам импорта.

    python copy_dll_closure.py <откуда> <куда> libtesseract-5.dll
"""

import shutil
import sys
from pathlib import Path

import pefile


def closure(folder: Path, root: str) -> dict[str, Path]:
    available = {p.name.lower(): p for p in folder.glob("*.dll")}
    found: dict[str, Path] = {}
    todo = [root.lower()]
    while todo:
        name = todo.pop()
        if name in found or name not in available:
            continue  # системные DLL (kernel32, msvcrt…) есть в Windows и так
        found[name] = available[name]
        pe = pefile.PE(str(available[name]), fast_load=True)
        pe.parse_data_directories(directories=[
            pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_IMPORT"],
            pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT"],
        ])
        for entry in getattr(pe, "DIRECTORY_ENTRY_IMPORT", []) + getattr(pe, "DIRECTORY_ENTRY_DELAY_IMPORT", []):
            todo.append(entry.dll.decode().lower())
    return found


def main():
    # Консоль Windows по умолчанию в cp1252 — кириллица в отчёте её роняла.
    sys.stdout.reconfigure(encoding="utf-8")
    source, target, root = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
    found = closure(source, root)
    if root.lower() not in found:
        sys.exit(f"{root} не найдена в {source}")
    target.mkdir(parents=True, exist_ok=True)
    for path in found.values():
        shutil.copy(path, target / path.name)
    size = sum(p.stat().st_size for p in found.values()) / 2**20
    print(f"{len(found)} DLL, {size:.1f} МБ: {', '.join(sorted(p.name for p in found.values()))}")


if __name__ == "__main__":
    main()
