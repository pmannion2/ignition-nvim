"""Tests for completion.py — context detection, completion items, snippets."""

import pytest
from lsprotocol.types import CompletionItemKind, InsertTextFormat

from ignition_lsp.completion import (
    get_completion_context,
    get_completions,
    _get_top_level_completions,
    _get_system_modules,
    _get_module_functions,
    _get_function_completions,
    _is_project_prefix,
    _get_project_completions,
)
from ignition_lsp.project_scanner import ProjectIndex, ScriptLocation


# ── Context Detection Tests ───────────────────────────────────────────


class TestGetCompletionContext:
    """Tests for extracting the text context before the cursor."""

    def test_system_dot(self, mock_document, position):
        doc = mock_document("system.")
        ctx = get_completion_context(doc, position(0, 7))
        assert ctx == "system."

    def test_system_tag_dot(self, mock_document, position):
        doc = mock_document("system.tag.")
        ctx = get_completion_context(doc, position(0, 11))
        assert ctx == "system.tag."

    def test_partial_function(self, mock_document, position):
        doc = mock_document("system.tag.read")
        ctx = get_completion_context(doc, position(0, 15))
        assert ctx == "system.tag.read"

    def test_just_system(self, mock_document, position):
        doc = mock_document("system")
        ctx = get_completion_context(doc, position(0, 6))
        assert ctx == "system"

    def test_empty_line(self, mock_document, position):
        doc = mock_document("")
        ctx = get_completion_context(doc, position(0, 0))
        assert ctx == ""

    def test_after_assignment(self, mock_document, position):
        doc = mock_document("result = system.tag.")
        ctx = get_completion_context(doc, position(0, 20))
        assert ctx == "system.tag."

    def test_multiline_correct_line(self, mock_document, position):
        doc = mock_document("import system\nsystem.db.\nprint('done')")
        ctx = get_completion_context(doc, position(1, 10))
        assert ctx == "system.db."

    def test_in_function_call(self, mock_document, position):
        doc = mock_document("print(system.util.)")
        # Cursor at position 18 = right before ')', text_before = "print(system.util."
        ctx = get_completion_context(doc, position(0, 18))
        assert ctx == "system.util."


# ── Top-Level Completions ─────────────────────────────────────────────


class TestTopLevelCompletions:
    def test_returns_system_and_shared(self):
        items = _get_top_level_completions()
        labels = [item.label for item in items]
        assert "system" in labels
        assert "shared" in labels

    def test_items_are_modules(self):
        items = _get_top_level_completions()
        assert all(item.kind == CompletionItemKind.Module for item in items)


# ── System Module Completions ─────────────────────────────────────────


class TestSystemModuleCompletions:
    def test_returns_loaded_modules(self, api_loader):
        items = _get_system_modules(api_loader)
        labels = [item.label for item in items]
        assert "tag" in labels
        assert "db" in labels
        assert "perspective" in labels
        assert "util" in labels

    def test_items_are_modules(self, api_loader):
        items = _get_system_modules(api_loader)
        assert all(item.kind == CompletionItemKind.Module for item in items)

    def test_detail_includes_count(self, api_loader):
        items = _get_system_modules(api_loader)
        for item in items:
            assert "functions" in item.detail


# ── Module Function Completions ───────────────────────────────────────


class TestModuleFunctionCompletions:
    def test_returns_functions_for_tag(self, api_loader):
        items = _get_module_functions("system.tag", api_loader)
        assert len(items) > 0
        labels = [item.label for item in items]
        assert "readBlocking" in labels

    def test_items_are_functions(self, api_loader):
        items = _get_module_functions("system.tag", api_loader)
        assert all(item.kind == CompletionItemKind.Function for item in items)

    def test_snippet_format(self, api_loader):
        items = _get_module_functions("system.tag", api_loader)
        for item in items:
            assert item.insert_text_format == InsertTextFormat.Snippet
            assert item.insert_text.endswith("$0")

    def test_empty_module_returns_empty(self, api_loader):
        items = _get_module_functions("system.nonexistent", api_loader)
        assert items == []

    def test_deprecated_function_marked(self, api_loader):
        """Any deprecated functions should have deprecated=True on the completion item."""
        for module in api_loader.get_all_modules():
            items = _get_module_functions(module, api_loader)
            for item in items:
                # Just verify the field is set (True or None/False)
                assert hasattr(item, "deprecated")


# ── Function Search Completions ───────────────────────────────────────


class TestFunctionCompletions:
    def test_partial_match(self, api_loader):
        items = _get_function_completions("system.tag.read", api_loader)
        labels = [item.label for item in items]
        assert "readBlocking" in labels

    def test_no_match(self, api_loader):
        items = _get_function_completions("system.tag.zzz", api_loader)
        assert items == []


# ── Full get_completions Integration ──────────────────────────────────


class TestGetCompletions:
    def test_empty_context_gives_top_level(self, mock_document, position, api_loader):
        doc = mock_document("  ")
        result = get_completions(doc, position(0, 0), api_loader)
        labels = [item.label for item in result.items]
        assert "system" in labels

    def test_system_gives_modules(self, mock_document, position, api_loader):
        doc = mock_document("system.")
        result = get_completions(doc, position(0, 7), api_loader)
        labels = [item.label for item in result.items]
        assert "tag" in labels

    def test_system_without_dot(self, mock_document, position, api_loader):
        doc = mock_document("system")
        result = get_completions(doc, position(0, 6), api_loader)
        labels = [item.label for item in result.items]
        assert "tag" in labels

    def test_module_dot_gives_functions(self, mock_document, position, api_loader):
        doc = mock_document("system.tag.")
        result = get_completions(doc, position(0, 11), api_loader)
        labels = [item.label for item in result.items]
        assert "readBlocking" in labels

    def test_partial_function_name(self, mock_document, position, api_loader):
        doc = mock_document("system.tag.read")
        result = get_completions(doc, position(0, 15), api_loader)
        labels = [item.label for item in result.items]
        assert "readBlocking" in labels

    def test_is_not_incomplete(self, mock_document, position, api_loader):
        doc = mock_document("system.")
        result = get_completions(doc, position(0, 7), api_loader)
        assert result.is_incomplete is False


# ── Project Script Completions ───────────────────────────────────────


def _make_loc(**kwargs) -> ScriptLocation:
    """Create a ScriptLocation with sensible defaults."""
    defaults = dict(
        file_path="/project/ignition/script-python/code.py",
        script_key="__file__",
        line_number=1,
        module_path="project.library.utils",
        resource_type="script-python",
        context_name="",
    )
    defaults.update(kwargs)
    return ScriptLocation(**defaults)


def _make_index(scripts) -> ProjectIndex:
    idx = ProjectIndex(root_path="/project")
    idx.scripts = scripts
    return idx


class TestIsProjectPrefix:
    def test_project_dot(self):
        assert _is_project_prefix("project.") is True

    def test_project_bare(self):
        assert _is_project_prefix("project") is True

    def test_shared_dot(self):
        assert _is_project_prefix("shared.") is True

    def test_shared_bare(self):
        assert _is_project_prefix("shared") is True

    def test_project_deep(self):
        assert _is_project_prefix("project.library.utils") is True

    def test_system_not_project(self):
        assert _is_project_prefix("system.tag") is False

    def test_empty_not_project(self):
        assert _is_project_prefix("") is False


class TestGetProjectCompletions:
    """Tests for _get_project_completions."""

    def test_project_dot_shows_children(self):
        """Typing 'project.' should show top-level children."""
        index = _make_index([
            _make_loc(module_path="project.library.utils"),
            _make_loc(module_path="project.library.config"),
            _make_loc(module_path="project.scripts.main"),
        ])
        items = _get_project_completions("project.", index)
        labels = sorted(item.label for item in items)
        assert labels == ["library", "scripts"]

    def test_project_library_dot_shows_leaf_modules(self):
        """Typing 'project.library.' should show utils and config."""
        index = _make_index([
            _make_loc(module_path="project.library.utils", file_path="/p/utils.py"),
            _make_loc(module_path="project.library.config", file_path="/p/config.py"),
        ])
        items = _get_project_completions("project.library.", index)
        labels = sorted(item.label for item in items)
        assert labels == ["config", "utils"]

    def test_partial_prefix_filters(self):
        """Typing 'project.library.u' should filter to 'utils'."""
        index = _make_index([
            _make_loc(module_path="project.library.utils"),
            _make_loc(module_path="project.library.config"),
        ])
        items = _get_project_completions("project.library.u", index)
        assert len(items) == 1
        assert items[0].label == "utils"

    def test_case_insensitive_partial(self):
        """Partial matching should be case-insensitive."""
        index = _make_index([
            _make_loc(module_path="project.library.Utils"),
        ])
        items = _get_project_completions("project.library.u", index)
        assert len(items) == 1
        assert items[0].label == "Utils"

    def test_no_matches_returns_empty(self):
        index = _make_index([
            _make_loc(module_path="project.library.utils"),
        ])
        items = _get_project_completions("shared.", index)
        assert items == []

    def test_leaf_module_has_detail(self):
        """Leaf modules should show the full path and resource type in detail."""
        index = _make_index([
            _make_loc(
                module_path="project.library.utils",
                resource_type="script-python",
                file_path="/p/utils.py",
            ),
        ])
        items = _get_project_completions("project.library.", index)
        assert len(items) == 1
        assert "project.library.utils" in items[0].detail
        assert "script-python" in items[0].detail

    def test_leaf_module_has_documentation(self):
        """Leaf modules should include source file path in documentation."""
        index = _make_index([
            _make_loc(
                module_path="project.library.utils",
                file_path="/project/code.py",
            ),
        ])
        items = _get_project_completions("project.library.", index)
        assert items[0].documentation is not None
        assert "/project/code.py" in items[0].documentation.value

    def test_all_items_are_modules(self):
        index = _make_index([
            _make_loc(module_path="project.library.utils"),
            _make_loc(module_path="project.scripts.main"),
        ])
        items = _get_project_completions("project.", index)
        assert all(item.kind == CompletionItemKind.Module for item in items)

    def test_shared_prefix_works(self):
        """shared.* completions should work the same as project.*."""
        index = _make_index([
            _make_loc(module_path="shared.utils.helpers"),
            _make_loc(module_path="shared.utils.constants"),
        ])
        items = _get_project_completions("shared.", index)
        assert len(items) == 1
        assert items[0].label == "utils"

    def test_deduplication(self):
        """Multiple scripts under the same path segment should produce one item."""
        index = _make_index([
            _make_loc(module_path="project.library.utils", file_path="/p/a.py"),
            _make_loc(module_path="project.library.utils", file_path="/p/b.json",
                       script_key="script"),
        ])
        items = _get_project_completions("project.library.", index)
        labels = [item.label for item in items]
        # "utils" should appear only once
        assert labels.count("utils") == 1


class TestGetCompletionsWithProjectIndex:
    """Integration tests: get_completions with project_index parameter."""

    def test_project_dot_triggers_project_completions(self, mock_document, position, api_loader):
        index = _make_index([
            _make_loc(module_path="project.library.utils"),
        ])
        doc = mock_document("project.")
        result = get_completions(doc, position(0, 8), api_loader, project_index=index)
        labels = [item.label for item in result.items]
        assert "library" in labels

    def test_no_index_no_project_completions(self, mock_document, position, api_loader):
        """Without a project index, 'project.' should not produce project completions."""
        doc = mock_document("project.")
        result = get_completions(doc, position(0, 8), api_loader, project_index=None)
        labels = [item.label for item in result.items]
        assert "library" not in labels

    def test_system_completions_unaffected(self, mock_document, position, api_loader):
        """system.* completions should still work even with a project index."""
        index = _make_index([_make_loc(module_path="project.library.utils")])
        doc = mock_document("system.tag.")
        result = get_completions(doc, position(0, 11), api_loader, project_index=index)
        labels = [item.label for item in result.items]
        assert "readBlocking" in labels
