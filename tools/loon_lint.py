"""检查 Loon 插件写法。只放过 Clash-Client 解析器会收下、且激活时不会因为策略名找不到而丢掉的行。

每种写法的出处在 CITATIONS：(仓库相对路径, 1-based 行号, 该行必须出现的源文)。
行号对应本仓库 Clash-Client 的当前源码，不是文档里的旧行号。
"""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import urlparse

PARSER = "Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleParser.swift"
RULES = "Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleRuleMapping.swift"
LINE = "Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleLineSyntax.swift"
HOSTS = "Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleHostList.swift"
ACTIVATION = "Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleActivation.swift"

# 解析器收下这些写法；值是源码位置。拒绝写法用 reject- 前缀，指向解析器把该行丢掉的那一行。
CITATIONS: dict[str, tuple[str, int, str]] = {
    "metadata-hashbang": (PARSER, 394, 'hasPrefix("#!")'),
    "metadata-name": (PARSER, 402, 'case "name"'),
    "metadata-system": (PARSER, 474, "written.contains(name)"),
    "comment-line": (PARSER, 1068, 'hasPrefix("#")'),
    "section-header": (PARSER, 1071, 'hasPrefix("[")'),
    "section-key": (PARSER, 938, "lowercased().filter"),
    "rule": (PARSER, 1451, 'case "rule"'),
    "rule-domain": (RULES, 875, 'case "DOMAIN"'),
    "rule-domain-suffix-dot": (RULES, 874, "withoutLeadingDot"),
    "rule-ip-cidr": (RULES, 842, '"IP-CIDR6"'),
    "rule-dst-port": (RULES, 858, '"DST-PORT"'),
    "rule-url-regex": (RULES, 367, '"URL-REGEX"'),
    "rule-user-agent": (RULES, 382, '"USER-AGENT"'),
    "rule-protocol": (RULES, 896, '"PROTOCOL"'),
    "rule-policy": (RULES, 60, 'hasPrefix("REJECT-")'),
    "rule-proxy": (RULES, 206, '"PROXY"'),
    "rule-direct": (RULES, 50, '== "DIRECT"'),
    "rule-reject-drop": (RULES, 53, '"REJECT-DROP"'),
    "rule-no-resolve": (RULES, 110, '"no-resolve"'),
    "rule-domain-wildcard": (RULES, 862, 'case "DOMAIN-WILDCARD"'),
    "rule-ip-suffix": (RULES, 845, 'case "IP-SUFFIX"'),
    "rule-geoip": (RULES, 847, '"IP-ASN"'),
    "rule-src-ip": (RULES, 855, '"SRC-IP-CIDR"'),
    "rule-src-port": (RULES, 860, '"IN-PORT"'),
    "rewrite": (PARSER, 1457, '"rewrite"'),
    "rewrite-reject-word": (LINE, 275, '== "reject"'),
    "rewrite-reject-action": (LINE, 128, 'case "reject"'),
    "rewrite-302": (LINE, 261, 'case "302"'),
    "rewrite-307": (LINE, 262, 'case "307"'),
    "rewrite-header": (LINE, 263, '"transparent"'),
    "rewrite-reject-dict": (LINE, 132, 'case "reject-dict"'),
    "rewrite-reject-video": (LINE, 147, '"reject-video"'),
    "mitm": (PARSER, 1381, '"mitm"'),
    "mitm-hostname": (PARSER, 1385, '"hostname"'),
    "mitm-h2": (PARSER, 1392, '"h2"'),
    "mitm-host-entry": (HOSTS, 41, "func entry"),
    "mitm-append": (HOSTS, 104, '"%APPEND%"'),
    "mitm-insert": (HOSTS, 107, '"%INSERT%"'),
    "script": (PARSER, 1469, '"script"'),
    "script-http": (LINE, 650, '"http-response"'),
    "script-loon-types": (LINE, 907, '"network-changed"'),
    "script-address": (LINE, 696, '"https"'),
    "script-options": (PARSER, 1324, '"script-path"'),
    "script-cron": (LINE, 779, 'hasPrefix("@")'),
    "argument": (PARSER, 1507, '"argument"'),
    "argument-control": (PARSER, 758, '"switch"'),
    "reject-not-a-module": (PARSER, 1177, "notAModule"),
    "reject-before-section": (PARSER, 1078, "unreadableLine"),
    "reject-section": (PARSER, 1516, "sectionNotSupported"),
    "reject-proxy": (PARSER, 1513, '"proxygroup"'),
    "reject-type-parser": (PARSER, 419, '"parser"'),
    "reject-newer-syntax": (PARSER, 1378, "newerSyntaxNotSupported"),
    "reject-unknown-rule": (RULES, 931, "unsupportedRuleType"),
    "reject-policy-not-found": (ACTIVATION, 1245, "policyNotFound"),
    "reject-bad-argument": (PARSER, 1510, "loonArgument"),
    "reject-mitm-other": (PARSER, 1405, "settingNotSupported"),
}

_ACCEPTED_SECTIONS = {"rule", "mitm", "rewrite", "urlrewrite", "script", "argument"}
_QX_SECTIONS = {
    "rewrite_local",
    "rewrite_remote",
    "filter_local",
    "filter_remote",
    "task_local",
    "server_local",
    "server_remote",
    "http_backend",
}
_KNOWN_OPTIONS = {
    "no-resolve",
    "src",
    "extended-matching",
    "pre-matching",
    "allow-other-interface",
    "no-track",
    "dns-failed",
    "requires-resolve",
    "force-remote-dns",
}
_REGEX_TYPES = {"DOMAIN-REGEX", "PROCESS-NAME-REGEX", "PROCESS-PATH-REGEX", "URL-REGEX"}
_PLAIN_TYPES = {"DOMAIN", "DOMAIN-SUFFIX", "DOMAIN-KEYWORD", "GEOSITE", "NETWORK", "DOMAIN-WILDCARD"}
_ADDRESS_TYPES = {"IP-CIDR", "IP-CIDR6", "IP-SUFFIX", "SRC-IP", "SRC-IP-CIDR"}
_PORT_TYPES = {"DEST-PORT", "DST-PORT", "SRC-PORT", "IN-PORT"}
_PROTOCOLS = {"TCP", "UDP", "QUIC", "HTTP", "HTTPS", "TLS", "STUN", "MTPROTO"}
_REJECT_ACTIONS = {
    "reject",
    "reject-200",
    "reject-img",
    "reject-tinygif",
    "reject-dict",
    "reject-array",
    "reject-drop",
    "reject-no-drop",
    "reject-video",
}
_LOON_SCRIPT_TYPES = {"http-request", "http-response", "cron", "generic", "network-changed", "dns"}
_SCRIPT_OPTIONS = {
    "script-path",
    "requires-body",
    "require-body",
    "binary-body-mode",
    "binary-mode",
    "timeout",
    "time-out",
    "tag",
    "img-url",
    "enable",
    "enabled",
    "argument",
    "max-size",
    "script-update-interval",
}
_CRON_WORDS = {"@yearly", "@annually", "@monthly", "@weekly", "@daily", "@midnight", "@hourly"}
_HOST_CHARS = set("abcdefghijklmnopqrstuvwxyz0123456789.-_*?")
_HOST_SPECIALS = {"<ip-address>", "<ipv4-address>", "<ipv6-address>", "<simple-hostname>"}
_REF = re.compile(r"\$?\{([^{}\s]+)\}")
_MAX_RULE_BYTES = 4096
_MAX_LOGIC_DEPTH = 10
_MAX_SCRIPT_BYTES = 1024


def lint(text: str) -> list[tuple[int, str]]:
    """返回 (1-based 行号, 原因)。空列表表示这份插件只用了解析器会留下的写法。"""
    lines = text.split("\n")
    issues: list[tuple[int, str]] = []
    arguments: dict[str, str | None] = {}
    system: tuple[int, str] | None = None
    saw_section = False

    for index, raw in enumerate(lines, start=1):
        trimmed = raw.strip("\r").strip()
        if not _is_metadata(trimmed):
            continue
        key, value = _metadata(trimmed)
        if key == "type" and value.lower() == "parser":
            issues.append((index, "unsupported script type parser"))
        elif key == "system":
            system = (index, value)

    if system is not None and not _system_allows_ios(system[1]):
        issues.append((system[0], "other platform"))

    scanning: str | None = None
    for raw in lines:
        trimmed = raw.strip("\r").strip()
        if _skipped(trimmed):
            continue
        written = _strip_comment(trimmed)
        if not written:
            continue
        if written.startswith("[") and written.endswith("]"):
            scanning = _section_key(written[1:-1])
            continue
        if scanning != "argument":
            continue
        parsed = _argument(written)
        if parsed is not None:
            arguments[parsed[0]] = parsed[1]

    section = None
    for index, raw in enumerate(lines, start=1):
        trimmed = raw.strip("\r").strip()
        if _skipped(trimmed):
            continue
        written = _strip_comment(trimmed)
        if not written:
            continue
        if written.startswith("[") and written.endswith("]"):
            section = written[1:-1].strip()
            saw_section = True
            continue
        if section is None:
            issues.append((index, "unreadable line"))
            continue
        filled, reason = _substitute(written, arguments)
        if reason is not None or filled is None:
            issues.append((index, reason or "missing argument"))
            continue
        if "${args." in filled or "{{{" in filled:
            issues.append((index, "missing argument"))
            continue
        reason = _take(filled, _section_key(section))
        if reason is not None:
            issues.append((index, reason))

    if not saw_section:
        issues.append((1, "not a module"))
    return issues


def main(argv: list[str]) -> int:
    if not argv:
        print("usage: loon_lint.py <file.plugin> ...", file=sys.stderr)
        return 2
    failed = False
    for arg in argv:
        path = Path(arg)
        try:
            text = path.read_text(encoding="utf-8")
        except OSError as exc:
            print(f"{path}: {exc}", file=sys.stderr)
            failed = True
            continue
        issues = lint(text)
        if issues:
            failed = True
            for line, message in issues:
                print(f"{path}:{line}: {message}", file=sys.stderr)
        else:
            print(f"ok {path}")
    return 1 if failed else 0


def _is_metadata(line: str) -> bool:
    if not line.startswith("#!") or "=" not in line:
        return False
    key = line[2 : line.index("=")].strip()
    return bool(key) and all(ch.isalnum() or ch in "_-." for ch in key)


def _metadata(line: str) -> tuple[str, str]:
    equals = line.index("=")
    return line[2:equals].strip().lower(), line[equals + 1 :].strip()


def _system_allows_ios(value: str) -> bool:
    written = value.strip().lower()
    if not written or "ios" in written or "all" in written:
        return True
    return "ipad" in written and "tv" in written and "mac" in written


def _skipped(line: str) -> bool:
    return not line or line.startswith("#") or line.startswith("//") or line.startswith(";")


def _section_key(name: str) -> str:
    return "".join(ch for ch in name.lower() if not ch.isspace())


def _strip_comment(line: str) -> str:
    chars = list(line)
    quote: str | None = None
    in_class = False
    index = 0
    while index < len(chars):
        character = chars[index]
        previous = chars[index - 1] if index else None
        if character == "\\":
            index += 2
            continue
        if quote is not None:
            if character == quote:
                quote = None
        elif in_class:
            if character == "]":
                in_class = False
        elif character in "\"'" and (previous is None or previous in " \t=,"):
            quote = character
        elif character == "[":
            in_class = True
        elif previous in (" ", "\t") and (
            character in "#;" or (character == "/" and index + 1 < len(chars) and chars[index + 1] == "/")
        ):
            return "".join(chars[:index]).strip()
        index += 1
    return line.strip()


def _comma_split(text: str) -> list[str]:
    out: list[str] = []
    current: list[str] = []
    quoted = False
    previous = ""
    for character in text:
        if character == '"' and previous != "\\":
            quoted = not quoted
            current.append(character)
        elif character == "," and not quoted:
            out.append("".join(current))
            current = []
        else:
            current.append(character)
        previous = character
    out.append("".join(current))
    return out


def _unquote(text: str) -> str:
    if len(text) >= 2 and text.startswith('"') and text.endswith('"'):
        return text[1:-1].replace('\\"', '"')
    return text


def _argument(line: str) -> tuple[str, str | None] | None:
    if "=" not in line:
        return None
    name, rest = line.split("=", 1)
    name = name.strip()
    if not name or any(ch.isspace() or ch in "${},\"'" for ch in name):
        return None
    parts = _comma_split(rest)
    if not parts:
        return None
    control = parts.pop(0).strip().lower()
    if control not in {"input", "select", "switch"}:
        return None
    values: list[str] = []
    options: dict[str, str] = {}
    for part in parts:
        trimmed = part.strip()
        if "=" in trimmed:
            key, _, raw = trimmed.partition("=")
            key = key.strip().lower()
            if key in {"type", "tag", "desc"}:
                options.setdefault(key, _unquote(raw.strip()))
                continue
        if not options:
            values.append(_unquote(trimmed))
    if options.get("type", "").lower() == "number" and any(_number(item) is None for item in values):
        return None
    value = values[0] if values else None
    if control == "switch":
        value = value.lower() if value is not None and value.lower() in {"true", "false"} else None
    return name, value


def _number(text: str) -> float | None:
    try:
        value = float(text.strip())
    except ValueError:
        return None
    if value != value or value in {float("inf"), float("-inf")}:
        return None
    return value


def _substitute(line: str, arguments: dict[str, str | None]) -> tuple[str | None, str | None]:
    if "{" not in line or not arguments:
        return line, None
    matches = list(_REF.finditer(line))
    out = line
    for match in reversed(matches):
        name = match.group(1)
        if name not in arguments:
            continue
        value = arguments[name]
        if value is None:
            return None, "missing argument"
        out = out[: match.start()] + value + out[match.end() :]
    return out, None


def _take(line: str, key: str) -> str | None:
    if key in {"proxy", "proxygroup"}:
        return "modules cannot add proxies"
    if key in _QX_SECTIONS or key not in _ACCEPTED_SECTIONS:
        return "section not supported"
    if key in {"rewrite", "script", "urlrewrite"} and _newer_loon(line):
        return "newer syntax not supported"
    if key == "rule":
        return _rule(line)
    if key in {"rewrite", "urlrewrite"}:
        return _rewrite(line)
    if key == "script":
        return _script(line)
    if key == "mitm":
        return _mitm(line)
    return _argument_line(line)


def _newer_loon(line: str) -> bool:
    words = line.split(maxsplit=2)
    if len(words) < 2:
        return False
    first, second = words[0].lower(), words[1].lower()
    if first in {"request", "response"} and second == "if":
        return True
    if first == "cron" and re.search(r" then ", line, re.IGNORECASE):
        return True
    return first in {"network-changed", "generic"} and second == "then"


def _within_bounds(line: str) -> bool:
    if len(line.encode("utf-8")) > _MAX_RULE_BYTES:
        return False
    depth = 0
    for character in line:
        if character == "(":
            depth += 1
            if depth > 2 * _MAX_LOGIC_DEPTH + 1:
                return False
        elif character == ")":
            depth -= 1
    return True


def _fields(line: str) -> list[str]:
    out: list[str] = []
    current: list[str] = []
    quote: str | None = None
    for character in line:
        if quote is not None:
            if character == quote:
                quote = None
            else:
                current.append(character)
            continue
        if character in "\"'" and not any(ch not in " \t" for ch in current):
            quote = character
            continue
        if character == "," and quote is None:
            out.append("".join(current).strip())
            current = []
            continue
        current.append(character)
    out.append("".join(current).strip())
    return out


def _is_option(field: str) -> bool:
    lowered = field.lower()
    if lowered in _KNOWN_OPTIONS:
        return True
    if "=" not in lowered or lowered.startswith("="):
        return False
    name = lowered.split("=", 1)[0]
    return bool(name) and name[0].isalpha() and all(ch.isalnum() or ch == "-" for ch in name)


def _kernel_policy(policy: str) -> str | None:
    upper = policy.upper()
    if upper == "DIRECT":
        return "DIRECT"
    if upper == "REJECT-DROP" or upper.startswith("REJECT-DROP-"):
        return "REJECT-DROP"
    if upper == "REJECT" or (upper.startswith("REJECT-") and len(upper) > 7):
        return "REJECT"
    return None


def _rule(line: str) -> str | None:
    if not _within_bounds(line):
        return "unreadable line"
    field = _fields(line)
    if len(field) < 2 or not field[0] or not field[1]:
        return "unreadable line"
    kind = field[0].upper()
    rest = field[2:]
    options: list[str] = []
    if kind in _REGEX_TYPES:
        while rest and (not rest[-1] or _is_option(rest[-1])):
            if rest[-1]:
                options.insert(0, rest[-1])
            rest.pop()
        if not rest:
            return "unreadable line"
        policy = rest.pop()
        payload = [field[1], *rest]
    else:
        options = [item for item in rest if _is_option(item)]
        policies = [item for item in rest if item and not _is_option(item)]
        if not policies:
            return "unreadable line"
        policy = policies[0]
        payload = [field[1]]
    if policy != "PROXY" and _kernel_policy(policy) is None:
        return "policy not found"
    for option in options:
        if option.lower() not in _KNOWN_OPTIONS:
            return "unreadable line"
    body = ",".join(payload)
    if not body:
        return "unreadable line"
    if kind in _PLAIN_TYPES or kind in _ADDRESS_TYPES or kind in _PORT_TYPES:
        return None
    if kind in {"GEOIP", "IP-ASN"}:
        if body.upper() == "UNKNOWN":
            return "unsupported rule type"
        return None
    if kind == "URL-REGEX":
        return None if _valid_pattern(body) else "invalid pattern"
    if kind == "USER-AGENT":
        return None if len(payload) == 1 else "unreadable line"
    if kind == "PROTOCOL":
        return None if body.upper() in _PROTOCOLS else "unsupported rule type"
    return "unsupported rule type"


def _valid_pattern(pattern: str) -> bool:
    if not pattern:
        return False
    try:
        re.compile(pattern)
    except re.error:
        return False
    return True


def _tokens(line: str) -> list[str] | None:
    chars = list(line)
    out: list[str] = []
    index = 0
    while index < len(chars):
        while index < len(chars) and chars[index] in " \t":
            index += 1
        if index >= len(chars):
            break
        if chars[index] in "\"'":
            quote = chars[index]
            index += 1
            value: list[str] = []
            closed = False
            while index < len(chars):
                if chars[index] == "\\" and index + 1 < len(chars):
                    value.append(chars[index + 1])
                    index += 2
                    continue
                if chars[index] == quote:
                    index += 1
                    closed = True
                    break
                value.append(chars[index])
                index += 1
            if not closed:
                return None
            out.append("".join(value))
            continue
        start = index
        while index < len(chars) and chars[index] not in " \t":
            index += 1
        out.append("".join(chars[start:index]))
    return out


def _absolute_web(text: str) -> bool:
    parsed = urlparse(text)
    return parsed.scheme in {"http", "https"} and bool(parsed.hostname)


def _rewrite(line: str) -> str | None:
    words = _tokens(line)
    if not words or not words[0]:
        return "unreadable line"
    if len(words) == 2 and words[1].lower() == "reject":
        return None if _valid_pattern(words[0]) else "invalid pattern"
    if len(words) == 3 and words[1].lower() in {"302", "307", "header", "transparent"}:
        if not _absolute_web(words[2]):
            return "unsupported rewrite"
        return None if _valid_pattern(words[0]) else "invalid pattern"
    if len(words) == 2:
        action = words[1].lower().replace("_", "-")
        if action in _REJECT_ACTIONS or _absolute_web(words[1]):
            return None if _valid_pattern(words[0]) else "invalid pattern"
        return "unsupported rewrite"
    if len(words) == 3 and words[1].lower() == "url":
        action = words[2].lower().replace("_", "-")
        if action not in _REJECT_ACTIONS:
            return "unsupported rewrite"
        return None if _valid_pattern(words[0]) else "invalid pattern"
    if len(words) == 3:
        action = words[2].lower()
        if action in {"302", "307", "header", "transparent"}:
            return None if _valid_pattern(words[0]) else "invalid pattern"
        action = action.replace("_", "-")
        if action in _REJECT_ACTIONS:
            return None if _valid_pattern(words[0]) else "invalid pattern"
    return "unsupported rewrite"


def _script(line: str) -> str | None:
    parts = _script_parts(line)
    if parts is None:
        return "unreadable line"
    kind, head, options = parts
    if kind == "dns":
        return "dns scripts are not supported"
    values = {key: value for key, value in options}
    unknown = [key for key in values if key not in _SCRIPT_OPTIONS]
    if unknown:
        return "options with no effect"
    if any(values.get(key, "").lower() in {"0", "false", "no"} for key in ("enable", "enabled")):
        return "script turned off"
    pattern = head or ""
    if kind in {"http-request", "http-response"}:
        if not pattern:
            return "unreadable line"
        if not _valid_pattern(pattern):
            return "invalid pattern"
    elif kind == "cron":
        if not _cron(pattern):
            return "unreadable line"
    path = values.get("script-path", "")
    return _script_address(path, pattern)


def _script_parts(line: str) -> tuple[str, str | None, list[tuple[str, str]]] | None:
    stripped = line.strip()
    split_at = next((i for i, ch in enumerate(stripped) if ch in " \t"), None)
    if split_at is None:
        return None
    kind = stripped[:split_at].lower()
    rest = stripped[split_at:].strip()
    if kind not in _LOON_SCRIPT_TYPES:
        return None
    if kind == "cron":
        cron = _cron_head(rest)
        if cron is None:
            return None
        return kind, cron[0], _parameters(cron[1])
    if kind in {"network-changed", "generic", "dns"}:
        return kind, None, _parameters(rest)
    head = _split_head(stripped, 2)
    if head is None:
        return None
    return kind, head[0][1], _parameters(head[1])


def _split_head(text: str, count: int) -> tuple[list[str], str] | None:
    parts: list[str] = []
    index = 0
    while len(parts) < count:
        while index < len(text) and text[index] in " \t":
            index += 1
        if index >= len(text):
            return None
        start = index
        while index < len(text) and text[index] not in " \t":
            index += 1
        parts.append(text[start:index])
    return parts, text[index:].strip()


def _cron_head(rest: str) -> tuple[str, str] | None:
    if rest[:1] in "\"'":
        quote = rest[0]
        end = rest.find(quote, 1)
        if end < 0 or not rest[1:end]:
            return None
        return rest[1:end], rest[end + 1 :].strip()
    words: list[str] = []
    index = 0
    while index < len(rest):
        while index < len(rest) and rest[index] in " \t":
            index += 1
        if index >= len(rest):
            break
        start = index
        while index < len(rest) and rest[index] not in " \t":
            index += 1
        word = rest[start:index]
        after = rest[index:].lstrip(" \t")
        if "=" in word or after.startswith("="):
            if not words:
                return None
            return " ".join(words), rest[start:].strip()
        words.append(word)
    if not words:
        return None
    return " ".join(words), ""


def _parameters(text: str) -> list[tuple[str, str]]:
    chars = list(text)
    out: list[tuple[str, str]] = []
    index = 0

    def is_key(character: str) -> bool:
        return character.isascii() and (character.isalnum() or character in "-_")

    def starts_pair(start: int) -> bool:
        cursor = start
        while cursor < len(chars) and chars[cursor] == " ":
            cursor += 1
        key_start = cursor
        while cursor < len(chars) and is_key(chars[cursor]):
            cursor += 1
        key_end = cursor
        while cursor < len(chars) and chars[cursor] == " ":
            cursor += 1
        return key_end > key_start and cursor < len(chars) and chars[cursor] == "="

    while index < len(chars):
        while index < len(chars) and chars[index] in " ,":
            index += 1
        if index >= len(chars):
            break
        key_start = index
        while index < len(chars) and chars[index] != "=":
            index += 1
        if index >= len(chars):
            break
        key = "".join(chars[key_start:index]).strip().lower()
        index += 1
        while index < len(chars) and chars[index] == " ":
            index += 1
        value: list[str] = []
        while index < len(chars):
            if chars[index] == "," and starts_pair(index + 1):
                break
            value.append(chars[index])
            index += 1
        if key:
            out.append((key, "".join(value).strip()))
    return out


def _cron(written: str) -> bool:
    text = written.strip()
    if len(text) >= 2 and text[0] in "\"'" and text[-1] == text[0]:
        text = text[1:-1].strip()
    if text.startswith("@"):
        return text.lower() in _CRON_WORDS
    fields = text.split()
    if not 5 <= len(fields) <= 7:
        return False
    marks = set("*/,-?")
    for field in fields:
        if not all(ch.isascii() and (ch.isalnum() or ch in marks) for ch in field):
            return False
        letters: list[str] = []
        buf = ""
        for ch in field:
            if ch.isalpha():
                buf += ch
            elif buf:
                letters.append(buf)
                buf = ""
        if buf:
            letters.append(buf)
        if any(len(item) != 3 for item in letters):
            return False
    return True


def _script_address(path: str, pattern: str) -> str | None:
    if "boxjs" in path.lower() or "boxjs" in pattern.lower():
        return "boxjs not supported"
    parsed = urlparse(path)
    if parsed.scheme not in {"http", "https"} or not parsed.hostname:
        return "script without address"
    if len(path.encode("utf-8")) > _MAX_SCRIPT_BYTES:
        return "unreadable line"
    return None


def _mitm(line: str) -> str | None:
    if "=" not in line:
        return "unreadable line"
    name, value = line.split("=", 1)
    name = name.strip().lower()
    if name == "hostname":
        return _hostname(value)
    if name == "h2":
        return None if value.strip().lower() in {"true", "false"} else "unreadable line"
    return "setting not supported"


def _hostname(value: str) -> str | None:
    text = value.strip()
    upper = text.upper()
    if upper.startswith("%APPEND%"):
        text = text[len("%APPEND%") :].strip()
    elif upper.startswith("%INSERT%"):
        text = text[len("%INSERT%") :].strip()
    entries = [item.strip() for item in text.split(",") if item.strip()]
    if not entries or any(not _host_entry(item) for item in entries):
        return "invalid host"
    return None


def _host_entry(spelling: str) -> bool:
    text = spelling.strip()
    if text.startswith("-"):
        text = text[1:]
    if not text:
        return False
    if text.startswith("[") and "]" in text:
        close = text.index("]")
        address = text[1:close]
        rest = text[close + 1 :]
        if not _ipv6(address):
            return False
        if not rest:
            return True
        return rest.startswith(":") and _port(rest[1:])
    if text.count(":") > 1:
        return _ipv6(text)
    if ":" in text:
        host, _, port = text.rpartition(":")
        if not _port(port):
            return False
        text = host
    lowered = text.lower()
    if lowered in _HOST_SPECIALS:
        return True
    if not lowered or any(ch not in _HOST_CHARS for ch in lowered):
        return False
    while "**" in lowered:
        lowered = lowered.replace("**", "*")
    if lowered.endswith(".") and any(ch.isalnum() for ch in lowered[:-1]):
        lowered = lowered[:-1]
        if lowered.endswith("."):
            return False
    return bool(lowered)


def _ipv6(text: str) -> bool:
    return bool(text) and ":" in text and all(ch in "0123456789abcdefABCDEF:" for ch in text)


def _port(digits: str) -> bool:
    if digits == "*":
        return True
    if not digits.isdigit():
        return False
    return 0 <= int(digits) <= 65535


def _argument_line(line: str) -> str | None:
    return None if _argument(line) is not None else "unreadable line"


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
