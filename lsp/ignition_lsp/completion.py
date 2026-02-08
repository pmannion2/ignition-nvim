"""Completion provider for Ignition APIs."""

import logging
import re
from typing import Dict, List, Optional

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
from .project_scanner import ProjectIndex

logger = logging.getLogger(__name__)

# Prefixes that trigger project-level completions
PROJECT_PREFIXES = ("project.", "shared.")


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
    api_loader: IgnitionAPILoader,
    project_index: Optional[ProjectIndex] = None,
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
    elif _is_project_prefix(context) and project_index is not None:
        # Typed "project." or "shared." - show project script modules
        items.extend(_get_project_completions(context, project_index))

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


# ── Project Script Completions ───────────────────────────────────────


def _is_project_prefix(context: str) -> bool:
    """Check if the context starts with a project-level prefix."""
    return any(context == p.rstrip(".") or context.startswith(p) for p in PROJECT_PREFIXES)


def _get_project_completions(
    context: str, project_index: ProjectIndex
) -> List[CompletionItem]:
    """Get completions for project-level script references.

    Handles contexts like:
        "project."         -> list top-level children (e.g., "library")
        "project.library." -> list children at that level (e.g., "utils", "config")
        "project.library.u" -> filter children matching "u" prefix
        "shared."          -> list shared script modules
    """
    # Strip trailing dot for prefix search
    if context.endswith("."):
        prefix = context.rstrip(".")
        partial = ""
    else:
        # "project.library.ut" -> prefix="project.library", partial="ut"
        parts = context.rsplit(".", 1)
        if len(parts) == 2:
            prefix = parts[0]
            partial = parts[1]
        else:
            prefix = context
            partial = ""

    # Find all scripts whose module_path starts with our prefix
    matching = project_index.search_module_paths(prefix)

    if not matching:
        return []

    # Collect the next path segment after the prefix
    prefix_depth = prefix.count(".") + 1
    seen: Dict[str, str] = {}  # segment -> full module_path (for detail)

    for loc in matching:
        parts = loc.module_path.split(".")
        if len(parts) <= prefix_depth:
            continue

        segment = parts[prefix_depth]

        # If there's a partial, filter by it
        if partial and not segment.lower().startswith(partial.lower()):
            continue

        if segment not in seen:
            # Track the resource type for the detail string
            seen[segment] = loc.resource_type

    items = []
    for segment, resource_type in sorted(seen.items()):
        # Check if this segment is a leaf (final module) or intermediate package
        full_path = f"{prefix}.{segment}"
        children = [
            s for s in project_index.search_module_paths(full_path)
            if s.module_path != full_path
        ]
        is_package = len(children) > 0
        exact_match = project_index.find_by_module_path(full_path)

        if exact_match and not is_package:
            # Leaf module — show as a script reference
            items.append(
                CompletionItem(
                    label=segment,
                    kind=CompletionItemKind.Module,
                    detail=f"{full_path} ({resource_type})",
                    documentation=MarkupContent(
                        kind=MarkupKind.Markdown,
                        value=f"**{full_path}**\n\nProject script module\n\nSource: `{exact_match.file_path}`",
                    ),
                )
            )
        else:
            # Intermediate package — show as a namespace
            child_count = len(set(
                s.module_path.split(".")[prefix_depth]
                for s in project_index.search_module_paths(full_path)
                if len(s.module_path.split(".")) > prefix_depth
            ))
            items.append(
                CompletionItem(
                    label=segment,
                    kind=CompletionItemKind.Module,
                    detail=f"{full_path} ({child_count} children)" if child_count else full_path,
                )
            )

    return items
