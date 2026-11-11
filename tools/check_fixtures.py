"""Re-read golden fixtures from disk and check them against Dart sources.

Counts are taken from those sources on every run. They are not literals here.
A3 checks tokens.json and typography.json. icons.json, dock_edges.json, and
ripple.json are checked only after those files exist.
"""

from __future__ import annotations

import json
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ONEWIFI = ROOT.parent / "ONEWIFIX" / "IOS"
GLASS_PATH = ONEWIFI / "lib" / "design" / "one" / "glass.dart"
PALETTE_PATH = ONEWIFI / "lib" / "design" / "one" / "one_palette.dart"
THEME_PATH = ONEWIFI / "lib" / "design" / "theme" / "one_theme.dart"
REF = ROOT / "_ref" / "flutter-3.44.9" / "material"
A1_PATH = ROOT / "_golden" / "test" / "scenes" / "a1_typography_test.dart"

FILL_NAMES = ("fill", "fillStrong", "barFill", "modalFill", "dialogFill")
A4_FILES = ("icons.json", "dock_edges.json", "ripple.json")
ALPHA_RE = re.compile(r"^\d+\.\d{4}$")
ARGB_RE = re.compile(r"^[0-9A-F]{8}$")


def check(fixtures: Path) -> list[str]:
    """Read fixtures from disk and return a list of problems."""
    fixtures = Path(fixtures)
    try:
        errors = []
        errors.extend(_check_tokens(fixtures / "tokens.json"))
        errors.extend(_check_typography(fixtures / "typography.json"))
        errors.extend(_check_a4_if_present(fixtures))
        return errors
    except (OSError, ValueError) as exc:
        return [str(exc)]


def main() -> int:
    fixtures = ROOT / "_golden" / "fixtures"
    errors = check(fixtures)
    if errors:
        for err in errors:
            print(err)
        return 1
    checked = ["tokens.json", "typography.json"]
    for name in A4_FILES:
        if (fixtures / name).is_file():
            checked.append(name)
    print("ok " + " ".join(checked))
    return 0


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _load_json(path: Path) -> tuple[object | None, list[str]]:
    if not path.is_file():
        return None, [f"missing {path.name}"]
    try:
        return json.loads(path.read_text(encoding="utf-8")), []
    except json.JSONDecodeError as exc:
        return None, [f"{path.name} invalid json: {exc}"]


def _num_eq(got: object, expected: float) -> bool:
    if isinstance(got, bool) or not isinstance(got, (int, float)):
        return False
    return math.isclose(float(got), expected, rel_tol=0.0, abs_tol=1e-9)


def _dart_round(value: float) -> int:
    if value >= 0:
        return int(math.floor(value + 0.5))
    return int(math.ceil(value - 0.5))


def _float_to_int8(value: float) -> int:
    return min(255, max(0, _dart_round(value * 255.0)))


def _hex_color(argb: str) -> tuple[float, float, float, float]:
    return (
        int(argb[0:2], 16) / 255.0,
        int(argb[2:4], 16) / 255.0,
        int(argb[4:6], 16) / 255.0,
        int(argb[6:8], 16) / 255.0,
    )


def _argb(color: tuple[float, float, float, float]) -> str:
    return "".join(f"{_float_to_int8(channel):02X}" for channel in color)


def _with_alpha(
    color: tuple[float, float, float, float], alpha: float
) -> tuple[float, float, float, float]:
    return (alpha, color[1], color[2], color[3])


def _alpha_blend(
    foreground: tuple[float, float, float, float],
    background: tuple[float, float, float, float],
) -> tuple[float, float, float, float]:
    alpha = foreground[0]
    if alpha == 0:
        return background
    inverse = 1.0 - alpha
    back = background[0]
    if back == 1:
        return (
            1.0,
            alpha * foreground[1] + inverse * background[1],
            alpha * foreground[2] + inverse * background[2],
            alpha * foreground[3] + inverse * background[3],
        )
    back *= inverse
    out = alpha + back
    return (
        out,
        (foreground[1] * alpha + background[1] * back) / out,
        (foreground[2] * alpha + background[2] * back) / out,
        (foreground[3] * alpha + background[3] * back) / out,
    )


def _linearize(component: float) -> float:
    if component <= 0.03928:
        return component / 12.92
    return ((component + 0.055) / 1.055) ** 2.4


def _luminance(color: tuple[float, float, float, float]) -> float:
    return (
        0.2126 * _linearize(color[1])
        + 0.7152 * _linearize(color[2])
        + 0.0722 * _linearize(color[3])
    )


def _saturation(color: tuple[float, float, float, float]) -> float:
    red, green, blue = color[1], color[2], color[3]
    high = max(red, green, blue)
    low = min(red, green, blue)
    if low == high:
        return 0.0
    lightness = (high + low) / 2.0
    return min(1.0, max(0.0, (high - low) / (1.0 - abs(2.0 * lightness - 1.0))))


def _slice(src: str, start: str, end: str) -> str:
    at = src.find(start)
    if at < 0:
        raise ValueError(f"missing {start!r}")
    stop = src.find(end, at + len(start))
    if stop < 0:
        raise ValueError(f"missing {end!r} after {start!r}")
    return src[at:stop]


def _glass_constants(src: str) -> dict[str, float]:
    assigns = re.findall(r"static const double (\w+) = ([^;]+);", src)
    if not assigns:
        raise ValueError("glass.dart has no static const double")
    pending = {name: expr.strip() for name, expr in assigns}
    env: dict[str, float] = {}
    while pending:
        progress = False
        for name, expr in list(pending.items()):
            try:
                env[name] = _eval_const(expr, env)
            except KeyError:
                continue
            progress = True
            del pending[name]
        if not progress:
            raise ValueError(f"unresolved glass constants: {sorted(pending)}")
    return env


def _eval_const(expr: str, env: dict[str, float]) -> float:
    match = re.fullmatch(r"(\w+)\s*([+\-*/])\s*(\w+|\d+(?:\.\d+)?)", expr)
    if match:
        left = env[match.group(1)]
        right_text = match.group(3)
        right = env[right_text] if right_text in env or not right_text[0].isdigit() else float(right_text)
        if not right_text[0].isdigit() and right_text not in env:
            raise KeyError(right_text)
        op = match.group(2)
        if op == "+":
            return left + right
        if op == "-":
            return left - right
        if op == "*":
            return left * right
        return left / right
    if re.fullmatch(r"\d+(?:\.\d+)?", expr):
        return float(expr)
    if re.fullmatch(r"\w+", expr):
        return env[expr]
    raise ValueError(f"cannot evaluate glass constant {expr!r}")


def _palette(src: str) -> dict[str, dict[str, str]]:
    named = {"Colors.white": "FFFFFFFF", "Colors.black": "FF000000"}
    for name, hex_value in re.findall(r"const Color (\w+) = Color\(0x([0-9A-Fa-f]{8})\);", src):
        named[name] = hex_value.upper()
    schemes: dict[str, dict[str, str]] = {}
    for name, body in re.findall(
        r"const ColorScheme (oneBlackWhite(?:Light|Dark)) = ColorScheme\((.*?)\n\);",
        src,
        re.S,
    ):
        brightness = re.search(r"brightness:\s*Brightness\.(\w+)", body)
        if brightness is None:
            raise ValueError(f"{name} has no brightness")
        fields = {"brightness": brightness.group(1)}
        for key, raw in re.findall(r"(\w+):\s*([^,\n]+)", body):
            if key == "brightness":
                continue
            raw = raw.strip()
            color = re.search(r"Color\(0x([0-9A-Fa-f]{8})\)", raw)
            if color:
                fields[key] = color.group(1).upper()
            elif raw in named:
                fields[key] = named[raw]
            else:
                raise ValueError(f"{name}.{key} has unknown color {raw!r}")
        schemes[name] = fields
    if set(schemes) != {"oneBlackWhiteLight", "oneBlackWhiteDark"}:
        raise ValueError(f"unexpected palette schemes: {sorted(schemes)}")
    return schemes


def _color_scheme_model(src: str) -> tuple[list[str], dict[str, str]]:
    start = src.find("final Brightness brightness;")
    end = src.find("ColorScheme copyWith(", start)
    if start < 0 or end < 0:
        raise ValueError("color_scheme.dart fields not found")
    body = src[start:end]
    fields: list[str] = []
    for name in re.findall(r"(?:final Color |Color get )(\w+)", body):
        if name not in fields:
            fields.append(name)
    fallbacks = {
        name: expr.strip()
        for name, expr in re.findall(r"Color get (\w+) => _\w+ \?\? ([^;]+);", body)
    }
    if not fields:
        raise ValueError("color_scheme.dart has no color fields")
    return fields, fallbacks


def _resolve_scheme_color(
    field: str,
    constructed: dict[str, str],
    fallbacks: dict[str, str],
    seen: set[str],
) -> str:
    if field in constructed:
        return constructed[field]
    if field in seen:
        raise ValueError(f"cycle resolving {field}")
    expr = fallbacks.get(field)
    if expr is None:
        raise ValueError(f"no palette value or fallback for {field}")
    color = re.fullmatch(r"const Color\(0x([0-9A-Fa-f]{8})\)", expr)
    if color:
        return color.group(1).upper()
    if re.fullmatch(r"[A-Za-z_]\w*", expr):
        return _resolve_scheme_color(expr, constructed, fallbacks, seen | {field})
    raise ValueError(f"cannot resolve {field} from {expr!r}")


def _m3_english(src: str) -> dict[str, dict[str, float | int]]:
    start = src.find("abstract final class _M3Typography")
    english = src.find("static const TextTheme englishLike = TextTheme(", start)
    dense = src.find("static const TextTheme dense = TextTheme(", english)
    if english < 0 or dense < 0:
        raise ValueError("M3 englishLike typography not found")
    body = src[english:dense]
    styles: dict[str, dict[str, float | int]] = {}
    pattern = re.compile(
        r"(\w+): TextStyle\([^)]*fontSize: ([0-9.]+), fontWeight: FontWeight\.w(\d+), "
        r"letterSpacing: (-?[0-9.]+), height: ([0-9.]+)"
    )
    for name, size, weight, spacing, height in pattern.findall(body):
        styles[name] = {
            "fontSize": float(size),
            "fontWeight": int(weight),
            "letterSpacing": float(spacing),
            "height": float(height),
        }
    if not styles:
        raise ValueError("M3 englishLike has no styles")
    return styles


def _text_theme_fields(src: str) -> list[str]:
    start = src.find("class TextTheme")
    end = src.find("TextTheme copyWith(", start)
    if start < 0 or end < 0:
        raise ValueError("text_theme.dart fields not found")
    fields: list[str] = []
    for name in re.findall(r"final TextStyle\? (\w+);", src[start:end]):
        if name not in fields:
            fields.append(name)
    if not fields:
        raise ValueError("text_theme.dart has no styles")
    return fields


def _sample_text() -> str:
    match = re.search(r"static const sample = '([^']*)';", _read(A1_PATH))
    if match is None:
        raise ValueError("a1 sample string not found")
    return match.group(1)


def _font_family() -> str:
    match = re.search(r"fontFamily:\s*'([^']+)'", _read(THEME_PATH))
    if match is None:
        raise ValueError("one_theme.dart fontFamily not found")
    return match.group(1)


def _check_tokens(path: Path) -> list[str]:
    payload, errors = _load_json(path)
    if payload is None:
        return errors
    if not isinstance(payload, dict):
        return ["tokens.json is not an object"]
    glass_src = _read(GLASS_PATH)
    palette = _palette(_read(PALETTE_PATH))
    fields, fallbacks = _color_scheme_model(_read(REF / "color_scheme.dart"))
    constants = _glass_constants(glass_src)
    errors.extend(_check_schemes(payload.get("schemes"), palette, fields, fallbacks))
    errors.extend(_check_glass(payload.get("glass"), constants))
    errors.extend(_check_resolved(payload.get("resolved"), payload.get("schemes"), glass_src, constants))
    return errors


def _check_schemes(
    got: object,
    palette: dict[str, dict[str, str]],
    fields: list[str],
    fallbacks: dict[str, str],
) -> list[str]:
    if not isinstance(got, dict):
        return ["tokens.json schemes missing"]
    errors: list[str] = []
    if set(got) != set(palette):
        errors.append(f"scheme names {sorted(got)} != {sorted(palette)}")
    for name, constructed in palette.items():
        scheme = got.get(name)
        if not isinstance(scheme, dict):
            errors.append(f"schemes.{name} missing")
            continue
        if scheme.get("brightness") != constructed["brightness"]:
            errors.append(
                f"schemes.{name}.brightness {scheme.get('brightness')!r} "
                f"!= {constructed['brightness']!r}"
            )
        expected: dict[str, str] = {}
        for field in fields:
            try:
                expected[field] = _resolve_scheme_color(
                    field, {k: v for k, v in constructed.items() if k != "brightness"}, fallbacks, set()
                )
            except ValueError as exc:
                errors.append(f"schemes.{name}.{field}: {exc}")
                continue
            actual = scheme.get(field)
            if actual != expected[field]:
                errors.append(f"schemes.{name}.{field} {actual!r} != {expected[field]!r}")
        extra = set(scheme) - set(fields) - {"brightness"}
        if extra:
            errors.append(f"schemes.{name} extra keys {sorted(extra)}")
    return errors


def _check_glass(got: object, constants: dict[str, float]) -> list[str]:
    if not isinstance(got, dict):
        return ["tokens.json glass missing"]
    errors: list[str] = []
    missing = set(constants) - set(got)
    extra = set(got) - set(constants)
    if missing:
        errors.append(f"glass missing {sorted(missing)}")
    if extra:
        errors.append(f"glass extra {sorted(extra)}")
    for name, expected in constants.items():
        if name in got and not _num_eq(got[name], expected):
            errors.append(f"glass.{name} {got[name]!r} != {expected}")
    return errors


def _check_resolved(
    got: object,
    schemes: object,
    glass_src: str,
    constants: dict[str, float],
) -> list[str]:
    if not isinstance(got, dict) or not isinstance(schemes, dict):
        return ["tokens.json resolved missing"]
    errors: list[str] = []
    expected = _expected_resolved(glass_src, constants, schemes)
    if set(got) != {"light", "dark"}:
        errors.append(f"resolved brightnesses {sorted(got)}")
    for brightness, want in expected.items():
        actual = got.get(brightness)
        if not isinstance(actual, dict):
            errors.append(f"resolved.{brightness} missing")
            continue
        errors.extend(_match_tree(f"resolved.{brightness}", actual, want))
    return errors


def _match_tree(path: str, got: object, want: object) -> list[str]:
    if isinstance(want, float):
        if not _num_eq(got, want):
            return [f"{path} {got!r} != {want}"]
        return []
    if isinstance(want, str):
        if got != want:
            return [f"{path} {got!r} != {want!r}"]
        return []
    if isinstance(want, dict):
        if not isinstance(got, dict):
            return [f"{path} is not an object"]
        errors: list[str] = []
        if set(got) != set(want):
            errors.append(f"{path} keys {sorted(got)} != {sorted(want)}")
        for key, child in want.items():
            if key in got:
                errors.extend(_match_tree(f"{path}.{key}", got[key], child))
        return errors
    if isinstance(want, list):
        if not isinstance(got, list) or len(got) != len(want):
            return [f"{path} length {len(got) if isinstance(got, list) else 'n/a'} != {len(want)}"]
        errors = []
        for index, child in enumerate(want):
            errors.extend(_match_tree(f"{path}[{index}]", got[index], child))
        return errors
    return [f"{path} unexpected expected type"]


def _expected_resolved(
    glass_src: str,
    constants: dict[str, float],
    schemes: dict[str, object],
) -> dict[str, object]:
    out: dict[str, object] = {}
    for brightness, scheme_name in (("light", "oneBlackWhiteLight"), ("dark", "oneBlackWhiteDark")):
        scheme = schemes.get(scheme_name)
        if not isinstance(scheme, dict):
            raise ValueError(f"schemes.{scheme_name} missing")
        out[brightness] = _resolved_for(brightness == "dark", scheme, glass_src, constants)
    return out


def _scheme_color(scheme: dict[str, object], name: str) -> tuple[float, float, float, float]:
    value = scheme.get(name)
    if not isinstance(value, str) or not ARGB_RE.fullmatch(value):
        raise ValueError(f"scheme color {name} is {value!r}")
    return _hex_color(value)


def _paint(color: tuple[float, float, float, float]) -> dict[str, str]:
    return {"argb": _argb(color), "alpha": _alpha_text(color[0])}


def _alpha_text(alpha: float) -> str:
    scaled = alpha * 10000.0
    rounded = _dart_round(scaled)
    sign = "-" if rounded < 0 else ""
    whole, frac = divmod(abs(rounded), 10000)
    return f"{sign}{whole}.{frac:04d}"


def _resolved_for(
    dark: bool,
    scheme: dict[str, object],
    glass_src: str,
    constants: dict[str, float],
) -> dict[str, object]:
    def color(name: str) -> tuple[float, float, float, float]:
        return _scheme_color(scheme, name)

    white = (1.0, 1.0, 1.0, 1.0)
    black = (1.0, 0.0, 0.0, 0.0)
    node: dict[str, object] = {}
    for fill_name in FILL_NAMES:
        node[fill_name] = _paint(_fill_color(fill_name, dark, color, glass_src, constants))
    node["stroke"] = _paint(_stroke_color(dark, color, glass_src))
    node["shadow"] = _shadows(dark, black, glass_src)
    node["backdrop"] = _backdrop(dark, color, glass_src)
    node["accent"] = _paint(_accent_color(color, glass_src))
    return node


def _fill_color(
    name: str,
    dark: bool,
    color,
    glass_src: str,
    constants: dict[str, float],
) -> tuple[float, float, float, float]:
    if name == "fill":
        body = _slice(glass_src, "static Color fill(", "static Color fillStrong(")
        pairs = re.findall(r"scheme\.(\w+)\.withValues\(alpha: ([0-9.]+)\)", body)
        if len(pairs) != 2:
            raise ValueError(f"fill() alphas {pairs}")
        field, alpha = pairs[0] if dark else pairs[1]
        return _with_alpha(color(field), float(alpha))
    if name == "fillStrong":
        body = _slice(glass_src, "static Color fillStrong(", "static Color barFill(")
        match = re.search(
            r"scheme\.(\w+)\.withValues\(alpha: dark \? ([0-9.]+) : ([0-9.]+)\)", body
        )
        if match is None:
            raise ValueError("fillStrong() shape changed")
        alpha = float(match.group(2) if dark else match.group(3))
        return _with_alpha(color(match.group(1)), alpha)
    if name == "barFill":
        body = _slice(glass_src, "static Color barFill(", "static Color blurredBarFill(")
        match = re.search(
            r"scheme\.(\w+)\.withValues\(alpha: (\w+)\)[\s\S]*scheme\.(\w+)\.withValues\(alpha: (\w+)\)",
            body,
        )
        if match is None:
            raise ValueError("barFill() shape changed")
        field = match.group(1) if dark else match.group(3)
        token = match.group(2) if dark else match.group(4)
        return _with_alpha(color(field), _const_alpha(token, constants))
    if name == "modalFill":
        body = _slice(glass_src, "static Color modalFill(", "static const double dialogAlpha")
        return _single_alpha_fill(body, "modalFill", color, constants)
    if name == "dialogFill":
        body = _slice(glass_src, "static Color dialogFill(", "static Color stroke(")
        return _single_alpha_fill(body, "dialogFill", color, constants)
    raise ValueError(name)


def _const_alpha(token: str, constants: dict[str, float]) -> float:
    if re.fullmatch(r"\d+(?:\.\d+)?", token):
        return float(token)
    if token not in constants:
        raise KeyError(token)
    return constants[token]


def _single_alpha_fill(body: str, name: str, color, constants: dict[str, float]):
    match = re.search(r"scheme\.(\w+)\.withValues\(alpha: (\w+)\)", body)
    if match is None:
        raise ValueError(f"{name}() shape changed")
    return _with_alpha(color(match.group(1)), _const_alpha(match.group(2), constants))


def _stroke_color(dark: bool, color, glass_src: str):
    body = _slice(glass_src, "static Color stroke(", "static List<BoxShadow> shadow(")
    alphas = [float(item) for item in re.findall(r"withValues\(alpha: ([0-9.]+)\)", body)]
    if (
        len(alphas) != 3
        or "Color.alphaBlend" not in body
        or "scheme.onSurface" not in body
        or "Colors.white" not in body
    ):
        raise ValueError(f"stroke() shape changed alphas={alphas}")
    if dark:
        return _with_alpha((1.0, 1.0, 1.0, 1.0), alphas[0])
    return _alpha_blend(
        _with_alpha((1.0, 1.0, 1.0, 1.0), alphas[1]),
        _with_alpha(color("onSurface"), alphas[2]),
    )


def _shadows(dark: bool, black, glass_src: str) -> dict[str, list[dict[str, object]]]:
    body = _slice(glass_src, "static List<BoxShadow> shadow(", "static LinearGradient backdrop(")
    pairs = [(float(strong), float(normal)) for strong, normal in re.findall(
        r"strong \? ([0-9.]+) : ([0-9.]+)", body
    )]
    returns = re.split(r"return <BoxShadow>\[", body)
    if len(pairs) != 9 or len(returns) != 3 or "Colors.black" not in body:
        raise ValueError(f"shadow() shape changed pairs={len(pairs)} returns={len(returns) - 1}")
    if "spreadRadius" in body:
        raise ValueError("shadow() now sets spreadRadius")

    def pick(index: int, strong: bool) -> float:
        return pairs[index][0] if strong else pairs[index][1]

    def layer(alpha_i: int, blur_i: int, y_i: int, strong: bool) -> dict[str, object]:
        paint = _paint(_with_alpha(black, pick(alpha_i, strong)))
        return {
            "argb": paint["argb"],
            "alpha": paint["alpha"],
            "blurRadius": pick(blur_i, strong),
            "offsetX": 0.0,
            "offsetY": pick(y_i, strong),
            "spreadRadius": 0.0,
        }

    def layers(strong: bool) -> list[dict[str, object]]:
        if dark:
            return [layer(0, 1, 2, strong)]
        return [layer(3, 4, 5, strong), layer(6, 7, 8, strong)]

    return {"normal": layers(False), "strong": layers(True)}


def _backdrop(dark: bool, color, glass_src: str) -> dict[str, object]:
    body = _slice(glass_src, "static LinearGradient backdrop(", "static Color accent(")
    pure = re.search(r"const Color\(0x([0-9A-Fa-f]{8})\)", body)
    neutral = re.search(
        r"colors: dark\s*\?\s*<Color>\[scheme\.(\w+), scheme\.(\w+)\]\s*"
        r":\s*<Color>\[scheme\.(\w+), scheme\.(\w+)\]",
        body,
    )
    blends = re.findall(
        r"scheme\.(\w+)\.withValues\(alpha: dark \? ([0-9.]+) : ([0-9.]+)\)",
        body,
    )
    neutral_limit = re.search(r"saturation < ([0-9.]+)", _slice(
        glass_src, "static bool isNeutralAccent(", "static BoxDecoration decoration("
    ))
    if pure is None or neutral is None or len(blends) != 2 or neutral_limit is None:
        raise ValueError("backdrop() shape changed")
    surface = color("surface")
    pure_hex = pure.group(1).upper()
    is_pure = dark and _argb(surface) == pure_hex
    if is_pure:
        top = bottom = surface
    elif _saturation(color("primary")) < float(neutral_limit.group(1)):
        if dark:
            top, bottom = color(neutral.group(1)), color(neutral.group(2))
        else:
            top, bottom = color(neutral.group(3)), color(neutral.group(4))
    else:
        def blend(index: int) -> tuple[float, float, float, float]:
            field, dark_alpha, light_alpha = blends[index]
            alpha = float(dark_alpha if dark else light_alpha)
            return _alpha_blend(_with_alpha(color(field), alpha), surface)

        top, bottom = blend(0), blend(1)
    return {
        "begin": "topCenter",
        "end": "bottomCenter",
        "top": _paint(top),
        "bottom": _paint(bottom),
    }


def _accent_color(color, glass_src: str):
    body = _slice(glass_src, "static Color accent(", "static bool isNeutralAccent(")
    match = re.search(r"computeLuminance\(\) > ([0-9.]+)", body)
    if match is None or "scheme.onSurface" not in body or "scheme.primary" not in body:
        raise ValueError("accent() shape changed")
    primary = color("primary")
    if _luminance(primary) > float(match.group(1)):
        return color("onSurface")
    return primary


def _check_typography(path: Path) -> list[str]:
    payload, errors = _load_json(path)
    if payload is None:
        return errors
    if not isinstance(payload, dict):
        return ["typography.json is not an object"]
    styles = _m3_english(_read(REF / "typography.dart"))
    fields = _text_theme_fields(_read(REF / "text_theme.dart"))
    if set(styles) != set(fields):
        errors.append(
            "M3 englishLike styles and TextTheme fields differ: "
            f"only M3 {sorted(set(styles) - set(fields))}, "
            f"only TextTheme {sorted(set(fields) - set(styles))}"
        )
    sample = _sample_text()
    family = _font_family()
    if payload.get("sample") != sample:
        errors.append(f"typography sample {payload.get('sample')!r} != {sample!r}")
    if set(payload) - {"sample", "light", "dark"}:
        errors.append(f"typography extra keys {sorted(set(payload) - {'sample', 'light', 'dark'})}")
    for brightness in ("light", "dark"):
        block = payload.get(brightness)
        if not isinstance(block, dict):
            errors.append(f"typography.{brightness} missing")
            continue
        if set(block) != set(styles):
            errors.append(f"typography.{brightness} styles {sorted(block)} != {sorted(styles)}")
        for name, expected in styles.items():
            got = block.get(name)
            if not isinstance(got, dict):
                errors.append(f"typography.{brightness}.{name} missing")
                continue
            errors.extend(_check_style(f"typography.{brightness}.{name}", got, expected, family))
    light = payload.get("light")
    dark = payload.get("dark")
    if isinstance(light, dict) and isinstance(dark, dict):
        for name in styles:
            if light.get(name) != dark.get(name):
                errors.append(f"typography.{name} light/dark differ")
    return errors


def _check_style(
    path: str,
    got: dict[str, object],
    expected: dict[str, float | int],
    family: str,
) -> list[str]:
    errors: list[str] = []
    required = {"fontSize", "fontWeight", "height", "letterSpacing", "measuredHeight", "fontFamily"}
    if set(got) != required:
        errors.append(f"{path} keys {sorted(got)} != {sorted(required)}")
    for key in ("fontSize", "letterSpacing", "height"):
        if key in got and not _num_eq(got[key], float(expected[key])):
            errors.append(f"{path}.{key} {got[key]!r} != {expected[key]}")
    if "fontWeight" in got and got["fontWeight"] != expected["fontWeight"]:
        errors.append(f"{path}.fontWeight {got['fontWeight']!r} != {expected['fontWeight']}")
    if got.get("fontFamily") != family:
        errors.append(f"{path}.fontFamily {got.get('fontFamily')!r} != {family!r}")
    size = got.get("fontSize")
    height = got.get("height")
    measured = got.get("measuredHeight")
    if (
        isinstance(size, (int, float))
        and not isinstance(size, bool)
        and isinstance(height, (int, float))
        and not isinstance(height, bool)
        and isinstance(measured, (int, float))
        and not isinstance(measured, bool)
    ):
        product = float(size) * float(height)
        # TextPainter reports the line snapped to the nearest logical pixel.
        if abs(float(measured) - product) > 0.5:
            errors.append(f"{path}.measuredHeight {measured} != {product}")
    else:
        errors.append(f"{path}.measuredHeight missing")
    return errors


def _check_a4_if_present(fixtures: Path) -> list[str]:
    errors: list[str] = []
    checkers = {
        "icons.json": _check_icons,
        "dock_edges.json": _check_dock,
        "ripple.json": _check_ripple,
    }
    for name in A4_FILES:
        path = fixtures / name
        if path.is_file():
            errors.extend(checkers[name](path))
    return errors


def _check_icons(path: Path) -> list[str]:
    payload, errors = _load_json(path)
    if payload is None:
        return errors
    if not isinstance(payload, list):
        return ["icons.json is not a list"]
    names = _icon_names()
    parsed = _icon_codepoints()
    missing = [name for name in names if name not in parsed]
    if missing:
        errors.append("icons.dart has no code point for " + ", ".join(missing))
        return errors
    if len(payload) != len(names):
        errors.append(f"icons.json has {len(payload)} items, ow_icons.txt has {len(names)}")
    for index, name in enumerate(names):
        if index >= len(payload):
            break
        item = payload[index]
        if not isinstance(item, dict):
            errors.append(f"icons.json[{index}] is not an object")
            continue
        if item.get("name") != name:
            errors.append(f"icons.json[{index}].name {item.get('name')!r} != {name!r}")
        if item.get("codePoint") != parsed[name]:
            errors.append(
                f"icons.json {name} codePoint {item.get('codePoint')!r} != {parsed[name]}"
            )
    return errors


def _icon_names() -> list[str]:
    text = (ROOT / "_ref" / "ow_icons.txt").read_text(encoding="utf-8-sig")
    names = []
    for line in text.splitlines():
        name = line.strip()
        if not name:
            continue
        if name.startswith("Icons."):
            name = name.removeprefix("Icons.")
        names.append(name)
    if not names:
        raise ValueError("ow_icons.txt is empty")
    return names


def _icon_codepoints() -> dict[str, int]:
    text = _read(REF / "icons.dart")
    found = re.findall(
        r"static const IconData (\w+) = IconData\(\s*(0x[0-9a-fA-F]+)",
        text,
    )
    return {name: int(code, 16) for name, code in found}


def _check_dock(path: Path) -> list[str]:
    payload, errors = _load_json(path)
    if not isinstance(payload, dict):
        return errors or ["dock_edges.json is not an object"]
    body = _slice(
        _read(ONEWIFI / "lib" / "design" / "one" / "ultra_glass_dock.dart"),
        "glassDockTabEdges({",
        "class _DockLiquidIndicator",
    )
    if "Curves.easeOutCubic" not in body or "Curves.easeInCubic" not in body:
        return ["glassDockTabEdges no longer uses easeOutCubic/easeInCubic"]
    curves = _read(Path(r"C:\Flutter\flutter\packages\flutter\lib\src\animation\curves.dart"))
    ease_in = _cubic_points(curves, "easeInCubic")
    ease_out = _cubic_points(curves, "easeOutCubic")
    if payload.get("count") != 4:
        errors.append(f"dock_edges count {payload.get('count')!r} != 4")
    transitions = payload.get("transitions")
    expected_pairs = [(0, 1), (0, 3), (3, 0)]
    steps = [index / 10 for index in range(11)]
    if not isinstance(transitions, list) or len(transitions) != len(expected_pairs):
        return errors + ["dock_edges transitions are not 0->1, 0->3, 3->0"]
    for pair, block in zip(expected_pairs, transitions, strict=True):
        if not isinstance(block, dict):
            errors.append("dock transition is not an object")
            continue
        if (block.get("from"), block.get("to")) != pair:
            errors.append(f"dock transition {block.get('from')}->{block.get('to')} != {pair}")
        samples = block.get("samples")
        if not isinstance(samples, list) or len(samples) != len(steps):
            errors.append(f"dock {pair} sample count != {len(steps)}")
            continue
        for step, sample in zip(steps, samples, strict=True):
            if not isinstance(sample, dict):
                errors.append(f"dock {pair} sample is not an object")
                continue
            left, right = _dock_edges(pair[0], pair[1], step, 4, ease_in, ease_out)
            if not _num_eq(sample.get("t"), step):
                errors.append(f"dock {pair} t {sample.get('t')!r} != {step}")
            if not _near(sample.get("left"), left, 5e-3):
                errors.append(f"dock {pair} t={step} left {sample.get('left')!r} != {left}")
            if not _near(sample.get("right"), right, 5e-3):
                errors.append(f"dock {pair} t={step} right {sample.get('right')!r} != {right}")
    return errors


def _near(got: object, expected: float, tol: float) -> bool:
    if isinstance(got, bool) or not isinstance(got, (int, float)):
        return False
    return abs(float(got) - expected) <= tol


def _cubic_points(src: str, name: str) -> tuple[float, float, float, float]:
    match = re.search(rf"static const Cubic {name} = Cubic\(([^)]+)\);", src)
    if match is None:
        raise ValueError(f"Curves.{name} not found")
    parts = [float(part.strip()) for part in match.group(1).split(",")]
    if len(parts) != 4:
        raise ValueError(f"Curves.{name} is {parts}")
    return (parts[0], parts[1], parts[2], parts[3])


def _cubic(points: tuple[float, float, float, float], t: float) -> float:
    if t == 0.0 or t == 1.0:
        return t
    a, b, c, d = points
    start = 0.0
    end = 1.0
    for _ in range(64):
        midpoint = (start + end) / 2
        estimate = _bezier(a, c, midpoint)
        if abs(t - estimate) < 0.001:
            return _bezier(b, d, midpoint)
        if estimate < t:
            start = midpoint
        else:
            end = midpoint
    raise ValueError(f"cubic did not converge at {t}")


def _bezier(p1: float, p2: float, m: float) -> float:
    return 3 * p1 * (1 - m) * (1 - m) * m + 3 * p2 * (1 - m) * m * m + m * m * m


def _dock_edges(
    origin: float,
    destination: float,
    t: float,
    count: int,
    ease_in: tuple[float, float, float, float],
    ease_out: tuple[float, float, float, float],
) -> tuple[float, float]:
    clamped = min(1.0, max(0.0, t))
    if count <= 0:
        return (0.0, 0.0)
    if origin == destination:
        index = min(max(origin, 0.0), float(count - 1))
        return (index, index + 1)
    lead = _cubic(ease_out, clamped)
    trail = _cubic(ease_in, clamped)

    def lerp(start: float, end: float, amount: float) -> float:
        return start + (end - start) * amount

    if destination >= origin:
        left = lerp(origin, destination, trail)
        right = lerp(origin + 1, destination + 1, lead)
    else:
        left = lerp(origin, destination, lead)
        right = lerp(origin + 1, destination + 1, trail)
    limit = float(count)
    return (min(max(left, 0.0), limit), min(max(right, 0.0), limit))


def _check_ripple(path: Path) -> list[str]:
    payload, errors = _load_json(path)
    if not isinstance(payload, dict):
        return errors or ["ripple.json is not an object"]
    model = _ripple_model()
    errors.extend(_match_ripple_constants(payload.get("constants"), model))
    box = payload.get("referenceBox")
    side = model["side"]
    if not isinstance(box, dict) or not _num_eq(box.get("width"), side) or not _num_eq(box.get("height"), side):
        errors.append(f"ripple referenceBox {box!r} != {side}")
    if not _near(payload.get("targetRadius"), model["target"], 1e-6):
        errors.append(f"ripple targetRadius {payload.get('targetRadius')!r} != {model['target']}")
    splash = payload.get("splashAlpha")
    if not isinstance(splash, dict):
        errors.append("ripple splashAlpha missing")
    else:
        if splash.get("light") != model["light_alpha"] or splash.get("dark") != model["dark_alpha"]:
            errors.append(
                f"ripple splashAlpha {splash.get('light')}/{splash.get('dark')} "
                f"!= {model['light_alpha']}/{model['dark_alpha']}"
            )
        if splash.get("line") != model["splash_line"]:
            errors.append(f"ripple splash line {splash.get('line')!r} != {model['splash_line']}")
    for phase, radius_ms, confirmed in (
        ("hold", model["unconfirmed_ms"], False),
        ("confirm", model["radius_ms"], True),
    ):
        block = payload.get(phase)
        if not isinstance(block, dict):
            errors.append(f"ripple.{phase} missing")
            continue
        for brightness, alpha in (("light", model["light_alpha"]), ("dark", model["dark_alpha"])):
            samples = block.get(brightness)
            if not isinstance(samples, list) or not samples:
                errors.append(f"ripple.{phase}.{brightness} missing")
                continue
            for sample in samples:
                if not isinstance(sample, dict) or not isinstance(sample.get("ms"), int):
                    errors.append(f"ripple.{phase}.{brightness} sample {sample!r}")
                    continue
                ms = sample["ms"]
                radius, paint = _ripple_sample(model, ms, radius_ms, confirmed, alpha)
                label = f"ripple.{phase}.{brightness} ms={ms}"
                if not _near(sample.get("radius"), radius, 0.05):
                    errors.append(f"{label} radius {sample.get('radius')!r} != {radius}")
                if sample.get("alpha") != paint:
                    errors.append(f"{label} alpha {sample.get('alpha')!r} != {paint}")
                if not _near(sample.get("opacity"), paint / 255.0, 1e-9):
                    errors.append(f"{label} opacity {sample.get('opacity')!r}")
    return errors


def _match_ripple_constants(got: object, model: dict[str, object]) -> list[str]:
    if not isinstance(got, list):
        return ["ripple constants missing"]
    errors: list[str] = []
    by_name = {}
    for item in got:
        if isinstance(item, dict) and isinstance(item.get("name"), str):
            by_name[item["name"]] = item
    expected = model["constants"]
    if not isinstance(expected, dict):
        return ["ripple model constants missing"]
    if set(by_name) != set(expected):
        errors.append(f"ripple constant names {sorted(by_name)} != {sorted(expected)}")
    for name, want in expected.items():
        item = by_name.get(name)
        if not isinstance(item, dict) or not isinstance(want, dict):
            continue
        if item.get("line") != want["line"]:
            errors.append(f"ripple {name} line {item.get('line')!r} != {want['line']}")
        key = "ms" if "ms" in want else "value"
        if not _same_const(item.get(key), want[key]):
            errors.append(f"ripple {name} {key} {item.get(key)!r} != {want[key]!r}")
    return errors


def _same_const(got: object, expected: object) -> bool:
    if isinstance(expected, float):
        return _num_eq(got, expected)
    return got == expected


def _ripple_model() -> dict[str, object]:
    lines = _read(REF / "ink_ripple.dart").splitlines()
    theme = _read(REF / "theme_data.dart").splitlines()
    tokens = _read(ONEWIFI / "lib" / "design" / "tokens" / "one_tokens.dart")
    side_match = re.search(r"static const double minimumTarget = ([0-9.]+);", tokens)
    if side_match is None:
        raise ValueError("OneSizes.minimumTarget not found")
    side = float(side_match.group(1))
    diagonal = math.hypot(side, side)
    target = diagonal / 2.0

    def find(source: list[str], needle: str) -> tuple[int, str]:
        for index, line in enumerate(source, start=1):
            if needle in line:
                return index, line
        raise ValueError(f"missing {needle}")

    def duration(name: str) -> dict[str, object]:
        line_no, line = find(lines, f"{name} =")
        seconds = re.search(r"Duration\(seconds: (\d+)\)", line)
        millis = re.search(r"Duration\(milliseconds: (\d+)\)", line)
        if seconds:
            ms = int(seconds.group(1)) * 1000
        elif millis:
            ms = int(millis.group(1))
        else:
            raise ValueError(f"{name} has no Duration")
        return {"line": line_no, "ms": ms}

    unconfirmed = duration("_kUnconfirmedRippleDuration")
    fade_in = duration("_kFadeInDuration")
    radius = duration("_kRadiusDuration")
    fade_out = duration("_kFadeOutDuration")
    cancel = duration("_kCancelDuration")
    interval_line, interval_text = find(lines, "_kFadeOutIntervalStart =")
    ratio = re.search(r"([0-9.]+) / ([0-9.]+)", interval_text)
    if ratio is None:
        raise ValueError("fade-out interval is not a ratio")
    interval = float(ratio.group(1)) / float(ratio.group(2))
    radius_line, radius_text = find(lines, "_targetRadius *")
    factors = re.search(r"_targetRadius \* ([0-9.]+), end: _targetRadius \+ ([0-9.]+)", radius_text)
    if factors is None:
        raise ValueError("radius factors not found")
    ease_line, _ease_text = find(lines, "Curves.ease")
    splash_line, splash_text = find(theme, "0x66C8C8C8")
    dark_hex = re.search(r"0x([0-9A-Fa-f]{2})[0-9A-Fa-f]{6}", splash_text)
    light_hex = re.search(r"0x66C8C8C8", splash_text)
    dark_match = re.search(r"0x(40)CCCCCC", splash_text)
    if light_hex is None or dark_match is None or dark_hex is None:
        raise ValueError(f"splash colors not on line {splash_line}")
    curves = _read(Path(r"C:\Flutter\flutter\packages\flutter\lib\src\animation\curves.dart"))
    return {
        "side": side,
        "target": target,
        "begin_factor": float(factors.group(1)),
        "end_extra": float(factors.group(2)),
        "interval": interval,
        "fade_in_ms": fade_in["ms"],
        "fade_out_ms": fade_out["ms"],
        "unconfirmed_ms": unconfirmed["ms"],
        "radius_ms": radius["ms"],
        "light_alpha": 0x66,
        "dark_alpha": 0x40,
        "splash_line": splash_line,
        "ease": _cubic_points(curves, "ease"),
        "constants": {
            "_kUnconfirmedRippleDuration": unconfirmed,
            "_kFadeInDuration": fade_in,
            "_kRadiusDuration": radius,
            "_kFadeOutDuration": fade_out,
            "_kCancelDuration": cancel,
            "_kFadeOutIntervalStart": {"line": interval_line, "value": interval},
            "radiusBeginFactor": {"line": radius_line, "value": float(factors.group(1))},
            "radiusEndExtra": {"line": radius_line, "value": float(factors.group(2))},
            "easeCurve": {"line": ease_line, "value": "Curves.ease"},
        },
    }


def _ripple_sample(
    model: dict[str, object],
    ms: int,
    radius_ms: object,
    confirmed: bool,
    splash: object,
) -> tuple[float, int]:
    ease = model["ease"]
    if not isinstance(ease, tuple) or not isinstance(radius_ms, int) or not isinstance(splash, int):
        raise ValueError("ripple model is incomplete")
    t = min(1.0, max(0.0, ms / radius_ms))
    begin = float(model["target"]) * float(model["begin_factor"])
    end = float(model["target"]) + float(model["end_extra"])
    radius = begin + (end - begin) * _cubic(ease, t)
    fade_in_ms = model["fade_in_ms"]
    fade_out_ms = model["fade_out_ms"]
    if not isinstance(fade_in_ms, int) or not isinstance(fade_out_ms, int):
        raise ValueError("ripple durations missing")
    if ms < fade_in_ms:
        alpha = _dart_round(splash * (ms / fade_in_ms))
    elif not confirmed:
        alpha = splash
    else:
        faded = min(1.0, max(0.0, ms / fade_out_ms))
        interval = float(model["interval"])
        shaped = min(1.0, max(0.0, (faded - interval) / (1.0 - interval)))
        alpha = _dart_round(splash + (0 - splash) * shaped)
    return radius, alpha


if __name__ == "__main__":
    sys.exit(main())
