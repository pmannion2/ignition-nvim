"""Completion provider for Ignition APIs."""

import logging
import re
from typing import List, Optional

from lsprotocol.types import (
    CompletionItem,
    CompletionItemKind,
    CompletionList,
    CompletionParams,
    InsertTextFormat,
    MarkupContent,
    MarkupKind,
)
from pygls.workspace import TextDocument

from .api_loader import IgnitionAPILoader

logger = logging.getLogger(__name__)


def get_completion_context(document: TextDocument, position: CompletionParams.position) -> str:
    """Get the text context before cursor for completion."""
    line = document.lines[position.line]
    text_before_cursor = line[:position.character]

    # Extract the last partial identifier (e.g., "system.tag.")
    match = re.search(r'([\w\.]+)$', text_before_cursor)
    if match:
        return match.group(1)

    return ""


def get_completions(
    document: TextDocument,
    position: CompletionParams.position,
    api_loader: IgnitionAPILoader
) -> CompletionList:
    """Generate completion items based on context."""
    context = get_completion_context(document, position)
    logger.info(f"Completion context: '{context}'")

    items = []

    if not context:
        # No context - offer top-level modules
        items.extend(_get_top_level_completions())
    elif context == "system" or context == "system.":
        # Just typed "system" or "system." - show available modules
        items.extend(_get_system_modules(api_loader))
    elif context.startswith("system.") and context.endswith("."):
        # Typed "system.tag." (with trailing dot) - show functions for that module
        module = context.rstrip(".")  # "system.tag." -> "system.tag"
        items.extend(_get_module_functions(module, api_loader))
    elif context.startswith("system.") and context.count(".") == 1:
        # Typed "system.tag" (no trailing dot) - show functions for that module
        module = context
        items.extend(_get_module_functions(module, api_loader))
    elif context.startswith("system.") and context.count(".") >= 2:
        # Typed "system.tag.read" etc - show matching functions
        items.extend(_get_function_completions(context, api_loader))

    logger.info(f"Generated {len(items)} completion items")
    return CompletionList(is_incomplete=False, items=items)


def _get_top_level_completions() -> List[CompletionItem]:
    """Get completions for top-level Ignition objects."""
    return [
        CompletionItem(
            label="system",
            kind=CompletionItemKind.Module,
            detail="Ignition system functions",
            documentation="Ignition platform system functions and APIs",
        ),
        CompletionItem(
            label="shared",
            kind=CompletionItemKind.Module,
            detail="Project shared scripts",
            documentation="Access project-level shared scripts",
        ),
    ]


def _get_system_modules(api_loader: IgnitionAPILoader) -> List[CompletionItem]:
    """Get completions for system.* modules."""
    modules = api_loader.get_all_modules()
    items = []

    for module in modules:
        if module.startswith("system."):
            module_name = module.split(".")[-1]  # "system.tag" -> "tag"
            func_count = len(api_loader.get_module_functions(module))

            items.append(
                CompletionItem(
                    label=module_name,
                    kind=CompletionItemKind.Module,
                    detail=f"{module} ({func_count} functions)",
                    documentation=f"Ignition {module} module",
                    insert_text=module_name,
                )
            )

    return items


def _get_module_functions(module: str, api_loader: IgnitionAPILoader) -> List[CompletionItem]:
    """Get all functions for a module (e.g., system.tag)."""
    functions = api_loader.get_module_functions(module)
    items = []

    for func in functions:
        # Create completion item with full details
        doc_md = f"**{func.signature}**\n\n{func.description}"
        if func.deprecated:
            doc_md = "⚠️ **DEPRECATED**\n\n" + doc_md

        items.append(
            CompletionItem(
                label=func.name,
                kind=CompletionItemKind.Function,
                detail=func.signature,
                documentation=MarkupContent(
                    kind=MarkupKind.Markdown,
                    value=doc_md,
                ),
                insert_text=func.get_completion_snippet(),
                insert_text_format=InsertTextFormat.Snippet,
                deprecated=func.deprecated,
            )
        )

    return items


def _get_function_completions(prefix: str, api_loader: IgnitionAPILoader) -> List[CompletionItem]:
    """Get function completions matching a prefix (e.g., 'system.tag.read')."""
    matching_functions = api_loader.search_functions(prefix)
    items = []

    for func in matching_functions:
        doc_md = f"**{func.signature}**\n\n{func.description}"

        items.append(
            CompletionItem(
                label=func.name,
                kind=CompletionItemKind.Function,
                detail=func.signature,
                documentation=MarkupContent(
                    kind=MarkupKind.Markdown,
                    value=doc_md,
                ),
                insert_text=func.get_completion_snippet(),
                insert_text_format=InsertTextFormat.Snippet,
            )
        )

    return items
