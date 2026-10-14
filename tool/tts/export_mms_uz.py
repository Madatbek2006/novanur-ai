"""Узбекский голос для телефона: MMS-TTS → ONNX для sherpa-onnx.

Тот же голос, что сейчас синтезирует бэк (facebook/mms-tts-uzb-script_cyrillic),
но работающий на телефоне без сети. Интерфейс — как у официальной конвертации
MMS в sherpa-onnx (https://k2-fsa.github.io/sherpa/onnx/tts/mms.html): входы
x, x_length, noise_scale, length_scale, noise_scale_w, выход y, те же
метаданные и tokens.txt. Отличие одно: веса берём из transformers-версии
модели — той, что уже стоит на бэке, — а не из исходного чекпойнта VITS.

Модель читает только кириллицу: латиницу перед синтезом надо перевести, как
это делает бэк в app/services/converter.py.

На телефон идёт model.mixed.onnx — веса сжаты по частям (см. MIXED), а
считается всё во float32: onnxruntime разворачивает веса при загрузке.

Лицензия весов MMS — CC-BY-NC-4.0.

    uv venv --python 3.12 .venv
    uv pip install --python .venv/bin/python torch transformers==4.56.0 onnx onnxruntime
    .venv/bin/python path/to/export_mms_uz.py [папка]   # → assets/tts/uz/model.onnx, tokens.txt
"""

import collections
import shutil
import sys
from pathlib import Path

import numpy as np
import onnx
import onnxruntime as ort
import torch
from onnx import TensorProto, helper, numpy_helper
from transformers import AutoTokenizer, VitsModel
from transformers.models.vits import modeling_vits

MODEL = "facebook/mms-tts-uzb-script_cyrillic"
ASSETS = Path(__file__).resolve().parents[2] / "assets/tts/uz"

# Сколько бит на вес в каждой части модели — по первому совпавшему префиксу
# имени узла. Подобрано замером на четырёх фразах против float32:
#
#   всё в int4 (17.8 МБ) — конец фразы на 12% быстрее, тембр плавает от
#     фразы к фразе: ошибку дают кодировщик текста и предсказатель
#     длительностей, они решают, как фраза прозвучит целиком;
#   flow в int4 почти не слышно (тембр 0.04 против 0.75 у «всё в int4»);
#   вокодер в int4 окрашивает голос ровно на всех фразах (0.20), и половина
#     этого — от двух слоёв повышения частоты: их держим в int8 (0.10).
#
# Итог: темп как у оригинала, тембр 0.10, файл вдвое меньше int8.
MIXED = [
    ("/model/text_encoder", 8),
    ("/model/duration_predictor", 8),
    ("/model/flow", 4),
    ("/model/decoder/upsampler", 8),
    ("/model/decoder", 4),
]
BLOCK = 32


def _relative_embeddings(self, relative_embeddings, length):
    """Трассируемая замена VitsAttention._get_relative_embeddings.

    Оригинал считает отступ питоновским max() и ветвится по нему: при
    трассировке отступ застывает под длину примера, и на тексте другой длины
    внимание смотрит не туда — звук выходит другим и на четверть длиннее.
    Здесь отступ всегда равен длине (его всегда хватает), а срез начинается с
    постоянного места, так что граф верен для любой длины.
    """
    padded = torch.nn.functional.pad(relative_embeddings, [0, 0, length, length, 0, 0])
    start = self.window_size + 1
    return padded[:, start : start + 2 * length - 1]


def check_relative_embeddings(model: VitsModel):
    """Замена обязана совпадать с оригиналом на любой длине."""
    attention = model.text_encoder.encoder.layers[0].attention
    for length in (1, 2, 4, 5, 6, 21, 200):
        expected = original_relative_embeddings(attention, attention.emb_rel_k, length)
        got = _relative_embeddings(attention, attention.emb_rel_k, length)
        assert torch.equal(expected, got), length


original_relative_embeddings = modeling_vits.VitsAttention._get_relative_embeddings


class OnnxModel(torch.nn.Module):
    """VitsModel с ручками синтеза на входе, а не в конфиге.

    transformers держит noise_scale, speaking_rate и noise_scale_duration
    атрибутами модели. Подставленные тензором, они попадают в граф входами —
    так же, как в оригинальном VITS, и sherpa-onnx может их задавать.
    """

    def __init__(self, model: VitsModel):
        super().__init__()
        self.model = model

    def forward(self, x, x_length, noise_scale, length_scale, noise_scale_w):
        self.model.noise_scale = noise_scale
        self.model.speaking_rate = 1.0 / length_scale
        self.model.noise_scale_duration = noise_scale_w
        mask = (torch.arange(x.shape[1]).unsqueeze(0) < x_length.unsqueeze(1)).long()
        waveform = self.model(input_ids=x, attention_mask=mask).waveform
        return waveform.unsqueeze(1)  # [N, 1, T], как у sherpa-onnx


def write_tokens(tokenizer, path: Path):
    """tokens.txt: «символ номер». Заглавные буквы — тем же номером, что и
    строчные: токенизатор MMS приводит текст к нижнему регистру, а sherpa-onnx
    — нет."""
    symbols = [s for s, _ in sorted(tokenizer.get_vocab().items(), key=lambda kv: kv[1])]
    upper = collections.Counter(s.upper() for s in symbols)
    with path.open("w", encoding="utf-8") as f:
        for idx, token in enumerate(symbols):
            # sherpa-onnx читает только односимвольные токены. <unk> добавляет
            # transformers, в исходном словаре MMS его нет — и модели он не нужен.
            if len(token) != 1:
                continue
            f.write(f"{token} {idx}\n")
            if token.lower() != token.upper() and len(token.upper()) == 1 and upper[token.upper()] == 1:
                f.write(f"{token.upper()} {idx}\n")


def add_meta_data(path: Path, model: VitsModel, tokenizer):
    onnx_model = onnx.load(str(path))
    meta = {
        "model_type": "vits",
        "comment": "mms",
        "url": f"https://huggingface.co/{MODEL}",
        "add_blank": int(tokenizer.add_blank),
        "language": "Uzbek (Cyrillic)",
        "frontend": "characters",
        "n_speakers": int(model.config.num_speakers),
        "sample_rate": model.config.sampling_rate,
    }
    for key, value in meta.items():
        prop = onnx_model.metadata_props.add()
        prop.key = key
        prop.value = str(value)
    onnx.save(onnx_model, str(path))


def compress(src: Path, dst: Path, plan=MIXED, block=BLOCK, min_size=4096):
    """Хранить веса в 8 или 4 битах, считать во float32.

    Каждый крупный вес свёртки или умножения заменяется маленькими целыми
    числами блоками по [block] со своим масштабом (float16) и подграфом,
    который восстанавливает float32. Подграф зависит только от констант,
    поэтому onnxruntime сворачивает его один раз при загрузке: в файле мало
    бит, а считает модель как оригинал. Динамическое int8 из onnxruntime
    было и хуже по звуку, и в sherpa-onnx вдвое медленнее float32.
    """
    model = onnx.load(str(src))
    graph = model.graph
    uses = collections.defaultdict(list)
    for node in graph.node:
        for i, name in enumerate(node.input):
            uses[name].append((node, i))

    def bits_for(t) -> int | None:
        consumers = uses[t.name]
        if not consumers or t.data_type != TensorProto.FLOAT:
            return None
        if any(n.op_type not in ("Conv", "ConvTranspose", "MatMul") or i != 1 for n, i in consumers):
            return None
        return next((b for prefix, b in plan if consumers[0][0].name.startswith(prefix)), None)

    keep, added, decode = [], [], []
    for t in graph.initializer:
        w = numpy_helper.to_array(t)
        bits = bits_for(t) if w.size >= min_size else None
        if bits is None:
            keep.append(t)
            continue

        n = t.name
        flat = w.reshape(-1)
        pad = (-flat.size) % block
        blocks = np.pad(flat, (0, pad)).reshape(-1, block)
        qmax = 2 ** (bits - 1) - 1
        scale = (np.abs(blocks).max(axis=1, keepdims=True) / qmax).astype(np.float16)
        scale[scale == 0] = 1
        q = np.clip(np.round(blocks / scale.astype(np.float32)), -qmax - 1, qmax).astype(np.int8)

        added.append(numpy_helper.from_array(scale, f"{n}__scale"))
        decode.append(helper.make_node("Cast", [f"{n}__scale"], [f"{n}__scale32"], to=TensorProto.FLOAT))
        if bits == 8:
            added.append(numpy_helper.from_array(q, f"{n}__q"))
            decode.append(helper.make_node("Cast", [f"{n}__q"], [f"{n}__qf"], to=TensorProto.FLOAT))
        else:
            # Два числа в байте: 0…15 со сдвигом на 8. Распаковка — сдвигами,
            # они есть в opset 13 и работают с uint8.
            u = (q.reshape(-1) + 8).astype(np.uint8)
            added.append(numpy_helper.from_array(u[0::2] | (u[1::2] << 4), f"{n}__packed"))
            decode += [
                helper.make_node("BitShift", [f"{n}__packed", "__four"], [f"{n}__hi"], direction="RIGHT"),
                helper.make_node("BitShift", [f"{n}__packed", "__four"], [f"{n}__shl"], direction="LEFT"),
                helper.make_node("BitShift", [f"{n}__shl", "__four"], [f"{n}__lo"], direction="RIGHT"),
                helper.make_node("Unsqueeze", [f"{n}__lo", "__last"], [f"{n}__lo1"]),
                helper.make_node("Unsqueeze", [f"{n}__hi", "__last"], [f"{n}__hi1"]),
                helper.make_node("Concat", [f"{n}__lo1", f"{n}__hi1"], [f"{n}__pairs"], axis=-1),
                helper.make_node("Cast", [f"{n}__pairs"], [f"{n}__u"], to=TensorProto.FLOAT),
                helper.make_node("Sub", [f"{n}__u", "__eight"], [f"{n}__qf"]),
            ]

        added += [
            numpy_helper.from_array(np.array([-1, block], np.int64), f"{n}__blocks"),
            numpy_helper.from_array(np.array(w.shape, np.int64), f"{n}__shape"),
            numpy_helper.from_array(np.array([flat.size], np.int64), f"{n}__size"),
        ]
        decode += [
            helper.make_node("Reshape", [f"{n}__qf", f"{n}__blocks"], [f"{n}__qb"]),
            helper.make_node("Mul", [f"{n}__qb", f"{n}__scale32"], [f"{n}__wb"]),
            helper.make_node("Reshape", [f"{n}__wb", "__flat"], [f"{n}__wf"]),
            helper.make_node("Slice", [f"{n}__wf", "__zero", f"{n}__size"], [f"{n}__ws"]),
            helper.make_node("Reshape", [f"{n}__ws", f"{n}__shape"], [n]),
        ]

    added += [
        numpy_helper.from_array(np.array([4], np.uint8), "__four"),
        numpy_helper.from_array(np.array([-1], np.int64), "__last"),
        numpy_helper.from_array(np.array([-1], np.int64), "__flat"),
        numpy_helper.from_array(np.array([0], np.int64), "__zero"),
        numpy_helper.from_array(np.array(8.0, np.float32), "__eight"),
    ]
    nodes = decode + list(graph.node)
    del graph.initializer[:]
    graph.initializer.extend(keep + added)
    del graph.node[:]
    graph.node.extend(nodes)
    onnx.save(model, str(dst))


def inputs(ids: list[int], noise_scale=0.667, length_scale=1.0, noise_scale_w=0.8):
    return {
        "x": np.array([ids], dtype=np.int64),
        "x_length": np.array([len(ids)], dtype=np.int64),
        "noise_scale": np.array([noise_scale], dtype=np.float32),
        "length_scale": np.array([length_scale], dtype=np.float32),
        "noise_scale_w": np.array([noise_scale_w], dtype=np.float32),
    }


@torch.no_grad()
def main(out: Path):
    out.mkdir(parents=True, exist_ok=True)
    tokenizer = AutoTokenizer.from_pretrained(MODEL)
    model = VitsModel.from_pretrained(MODEL).eval()

    write_tokens(tokenizer, out / "tokens.txt")

    check_relative_embeddings(model)
    modeling_vits.VitsAttention._get_relative_embeddings = _relative_embeddings

    # eval() обязателен и у обёртки: после выгрузки torch возвращает ей прежний
    # режим — вместе со всеми вложенными модулями. Новая обёртка «учится», и
    # без этого модель после выгрузки работала бы с dropout.
    wrapper = OnnxModel(model).eval()
    ids = tokenizer("салом дунё", return_tensors="pt")["input_ids"]
    example = tuple(torch.from_numpy(v) for v in inputs(ids[0].tolist()).values())
    fp32 = out / "model.onnx"
    torch.onnx.export(
        wrapper,
        example,
        str(fp32),
        dynamo=False,  # данные решают длину звука — трассировка с этим справляется
        opset_version=13,
        input_names=["x", "x_length", "noise_scale", "length_scale", "noise_scale_w"],
        output_names=["y"],
        dynamic_axes={"x": {0: "N", 1: "L"}, "x_length": {0: "N"}, "y": {0: "N", 2: "L"}},
    )
    add_meta_data(fp32, model, tokenizer)

    # Без шума синтез детерминирован: ONNX обязан совпасть с PyTorch — на
    # текстах любой длины, а не только на длине примера.
    modeling_vits.VitsAttention._get_relative_embeddings = original_relative_embeddings
    model.noise_scale, model.noise_scale_duration, model.speaking_rate = 0.0, 0.0, 1.0
    session = ort.InferenceSession(str(fp32))
    for text in ("а", "стул", "китоб жавони ва телевизор",
                 "расмда ёруғ хона кўринмоқда девор ёнида китоб жавони турибди "
                 "унинг қаршисида эса катта телевизор бор"):
        ids = tokenizer(text)["input_ids"]
        expected = model(input_ids=torch.tensor([ids])).waveform[0].numpy()
        got = session.run(None, inputs(ids, 0.0, 1.0, 0.0))[0][0, 0]
        assert got.shape == expected.shape, (text, got.shape, expected.shape)
        diff = float(np.abs(got - expected).max())
        print(f"ONNX vs PyTorch, {len(ids):3} токенов: {got.shape[0]} отсчётов, расхождение {diff:.1e}")
        assert diff < 1e-3, (text, diff)

    mixed = out / "model.mixed.onnx"
    compress(fp32, mixed)

    for f in (fp32, mixed):
        print(f"{f.name}: {f.stat().st_size / 1e6:.1f} МБ")

    # В приложение. Сменилась модель — поднять UzbekVoice._version, иначе на
    # телефонах останется старая копия.
    ASSETS.mkdir(parents=True, exist_ok=True)
    shutil.copy(mixed, ASSETS / "model.onnx")
    shutil.copy(out / "tokens.txt", ASSETS / "tokens.txt")
    print(f"→ {ASSETS}")


if __name__ == "__main__":
    main(Path(sys.argv[1] if len(sys.argv) > 1 else "mms-uz"))
