"""Модель для кнопки «Предметы дома».

Код со страницы датасета
https://platform.ultralytics.com/ultralytics/datasets/homeobjects-3k :
yolo26n, дообученная на HomeObjects-3K — 12 предметов комнаты (кровать,
диван, стул, стол, лампа, телевизор, ноутбук, шкаф, окно, дверь, растение,
фоторамка). Готовой обученной модели Ultralytics не выкладывает, поэтому
учим сами.

Запускать из любой папки вне репозитория — туда скачается датасет (390 МБ)
и лягут прогоны:

    uv venv --python 3.12 .venv
    uv pip install --python .venv/bin/python ultralytics
    .venv/bin/python path/to/train.py          # обучение
    .venv-export/bin/python path/to/train.py export   # → assets/ml/home_objects.tflite

Лицензия у YOLO26 и у датасета — AGPL-3.0.
"""

import shutil
import sys
from pathlib import Path

from ultralytics import YOLO

NAME = "home-objects-yolo26n"
WEIGHTS = Path("runs/detect") / NAME / "weights/best.pt"
ASSET = Path(__file__).resolve().parents[2] / "assets/ml/home_objects.tflite"

# Сторона входа модели на телефоне. Учим на 640, как на странице датасета,
# а на телефон выгружаем меньше — считается пропорционально площади кадра.
# Замер точности (`train.py compare`, mAP50-95 на валидации):
#   640 — 0.502, 512 — 0.478, 480 — 0.474, 416 — 0.437, 320 — 0.373.
# 480 почти не уступает 640 и считается вдвое быстрее; ниже точность падает
# заметно: на 320 теряется четверть.
PHONE_IMGSZ = 480


def train():
    model = YOLO("yolo26n.pt")
    model.train(
        data="HomeObjects-3K.yaml",
        epochs=100,
        imgsz=640,
        device="mps",
        name=NAME,
        exist_ok=True,
    )


def compare():
    """Точность обученной модели на разных размерах входа."""
    model = YOLO(WEIGHTS)
    for imgsz in (640, 416, 320):
        metrics = model.val(data="HomeObjects-3K.yaml", imgsz=imgsz, device="mps", plots=False)
        print(f"imgsz={imgsz}: mAP50-95={metrics.box.map:.3f} mAP50={metrics.box.map50:.3f}")


def export():
    """Модель для телефона.

    Нужен отдельный venv: litert-torch тянет свою версию torch и сломал бы
    окружение обучения. `nms=False` — не опечатка: только так Ultralytics
    выгружает готовый список находок YOLO26 [1, 300, 6] (x1, y1, x2, y2 в
    пикселях входа, уверенность, номер класса); иначе — сырой выход головы,
    которому нужен NMS. Вход — [1, 3, side, side], RGB 0…1.

        uv pip install --python .venv-export/bin/python ultralytics litert-torch ai-edge-litert
    """
    model = YOLO(WEIGHTS)
    exported = model.export(format="litert", imgsz=PHONE_IMGSZ, nms=False)
    shutil.copy(exported, ASSET)
    print(f"→ {ASSET}")


if __name__ == "__main__":
    {"train": train, "compare": compare, "export": export}[sys.argv[1] if len(sys.argv) > 1 else "train"]()
