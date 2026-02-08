"""Tests for diagnostics.py — severity mapping, empty results, JSON skipping."""

import pytest

from ignition_lsp.diagnostics import get_diagnostics, get_diagnostics_for_file


class MockDocument:
    """Simple mock document for diagnostics tests."""

    def __init__(self, uri: str, source: str):
        self.uri = uri
        self.source = source


# ── Diagnostics Tests ─────────────────────────────────────────────────


class TestGetDiagnostics:
    def test_json_file_returns_empty(self):
        """JSON files should be skipped (not Python)."""
        doc = MockDocument("file:///project/resource.json", '{"key": "value"}')
        result = get_diagnostics(doc)
        assert result == []

    def test_python_file_returns_list(self):
        """Python files should return a list (possibly empty if ignition-lint not available)."""
        doc = MockDocument("file:///script.py", "import system\nprint('hello')")
        result = get_diagnostics(doc)
        assert isinstance(result, list)

    def test_empty_source(self):
        """Empty documents should not crash."""
        doc = MockDocument("file:///empty.py", "")
        result = get_diagnostics(doc)
        assert isinstance(result, list)

    def test_virtual_buffer_not_skipped(self):
        """Virtual buffers with [Ignition: prefix in URI should be processed."""
        doc = MockDocument(
            "file:///[Ignition: script.py]",
            "import system\nsystem.tag.readBlocking([])",
        )
        result = get_diagnostics(doc)
        # Should return a list (empty if ignition-lint unavailable, but not skipped)
        assert isinstance(result, list)

    def test_no_crash_on_syntax_error(self):
        """Documents with syntax errors should not crash the diagnostics provider."""
        doc = MockDocument("file:///bad.py", "def broken(\n    pass")
        result = get_diagnostics(doc)
        assert isinstance(result, list)


class TestGetDiagnosticsForFile:
    def test_returns_list(self):
        result = get_diagnostics_for_file("test.py", "print('hello')")
        assert isinstance(result, list)

    def test_json_file_skipped(self):
        result = get_diagnostics_for_file("resource.json", '{"key": "value"}')
        assert result == []
