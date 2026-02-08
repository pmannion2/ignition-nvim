"""Tests for hover.py — word detection, function lookup, module hover."""

import pytest
from lsprotocol.types import MarkupKind

from ignition_lsp.hover import get_word_at_position, get_hover_info


# ── Word Detection Tests ──────────────────────────────────────────────


class TestGetWordAtPosition:
    def test_simple_identifier(self, mock_document, position):
        doc = mock_document("readBlocking")
        word = get_word_at_position(doc, position(0, 5))
        assert word == "readBlocking"

    def test_dotted_identifier(self, mock_document, position):
        doc = mock_document("system.tag.readBlocking")
        word = get_word_at_position(doc, position(0, 15))
        assert word == "system.tag.readBlocking"

    def test_module_only(self, mock_document, position):
        doc = mock_document("system.tag")
        word = get_word_at_position(doc, position(0, 8))
        assert word == "system.tag"

    def test_at_start_of_line(self, mock_document, position):
        doc = mock_document("system.tag.readBlocking()")
        word = get_word_at_position(doc, position(0, 0))
        assert word == "system.tag.readBlocking"

    def test_after_open_paren(self, mock_document, position):
        doc = mock_document("system.tag.readBlocking(paths)")
        # Cursor on 'p' of 'paths' at index 24
        word = get_word_at_position(doc, position(0, 24))
        assert word == "paths"

    def test_empty_line(self, mock_document, position):
        doc = mock_document("")
        word = get_word_at_position(doc, position(0, 0))
        assert word == ""

    def test_multiline(self, mock_document, position):
        doc = mock_document("first_line\nsystem.db.runPrepQuery(sql)")
        word = get_word_at_position(doc, position(1, 15))
        assert word == "system.db.runPrepQuery"

    def test_with_assignment(self, mock_document, position):
        doc = mock_document("result = system.util.getLogger(name)")
        word = get_word_at_position(doc, position(0, 25))
        assert word == "system.util.getLogger"


# ── Hover Info Tests ──────────────────────────────────────────────────


class TestGetHoverInfo:
    def test_hover_full_function_name(self, mock_document, position, api_loader):
        doc = mock_document("system.tag.readBlocking(paths)")
        hover = get_hover_info(doc, position(0, 15), api_loader)

        assert hover is not None
        assert hover.contents.kind == MarkupKind.Markdown
        assert "readBlocking" in hover.contents.value
        assert "system.tag.readBlocking" in hover.contents.value

    def test_hover_module(self, mock_document, position, api_loader):
        doc = mock_document("system.tag")
        hover = get_hover_info(doc, position(0, 8), api_loader)

        assert hover is not None
        assert "system.tag" in hover.contents.value
        assert "functions" in hover.contents.value

    def test_hover_bare_function_name(self, mock_document, position, api_loader):
        """Hovering over just 'readBlocking' without module prefix should still resolve."""
        doc = mock_document("readBlocking")
        hover = get_hover_info(doc, position(0, 5), api_loader)

        assert hover is not None
        assert "readBlocking" in hover.contents.value

    def test_hover_no_match(self, mock_document, position, api_loader):
        doc = mock_document("myCustomFunction()")
        hover = get_hover_info(doc, position(0, 5), api_loader)

        assert hover is None

    def test_hover_empty_word(self, mock_document, position, api_loader):
        doc = mock_document("")
        hover = get_hover_info(doc, position(0, 0), api_loader)

        assert hover is None

    def test_hover_different_modules(self, mock_document, position, api_loader):
        """Test hover works across all loaded modules."""
        test_cases = [
            ("system.tag.readBlocking(paths)", 15, "readBlocking"),
            ("system.db.runPrepQuery(sql, args)", 14, "runPrepQuery"),
            ("system.util.getLogger(name)", 18, "getLogger"),
        ]

        for source, char, expected_name in test_cases:
            doc = mock_document(source)
            hover = get_hover_info(doc, position(0, char), api_loader)
            assert hover is not None, f"No hover for {expected_name}"
            assert expected_name in hover.contents.value

    def test_hover_module_shows_function_list(self, mock_document, position, api_loader):
        doc = mock_document("system.util")
        hover = get_hover_info(doc, position(0, 8), api_loader)

        assert hover is not None
        content = hover.contents.value
        assert "system.util" in content
        assert "`getLogger`" in content

    def test_hover_returns_markdown(self, mock_document, position, api_loader):
        doc = mock_document("system.tag.readBlocking(paths)")
        hover = get_hover_info(doc, position(0, 15), api_loader)

        assert hover is not None
        assert hover.contents.kind == MarkupKind.Markdown
        assert "```python" in hover.contents.value
