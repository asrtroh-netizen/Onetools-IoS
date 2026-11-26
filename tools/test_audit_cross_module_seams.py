from tools.audit_cross_module_seams import check_redos_in_plugin_text, run_all_checks


def test_workspace_cross_module_seams_clean():
    assert run_all_checks() == []


def test_redos_detector_flags_nested_quantifiers():
    safe = "DOMAIN-SUFFIX,gdt.qq.com,REJECT\nURL-REGEX,^https?://ad\\.example\\.com/v1/[0-9]+$,REJECT\n"
    assert check_redos_in_plugin_text(safe) == []

    unsafe = "URL-REGEX,^https://example\\.com/(a+)+$,REJECT\n"
    issues = check_redos_in_plugin_text(unsafe)
    assert len(issues) == 1
    assert "nested quantifier" in issues[0]
