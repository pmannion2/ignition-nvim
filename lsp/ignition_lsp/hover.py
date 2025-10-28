"""Hover provider for Ignition APIs."""

import logging
import re
from typing import Optional

from lsprotocol.types import Hover, HoverParams, MarkupContent, MarkupKind
from pygls.workspace import TextDocument

from .api_loader import IgnitionAPILoader

logger = logging.getLogger(__name__)


def get_word_at_position(document: TextDocument, position: HoverParams.position) -> str:
    """Get the full identifier at the cursor position."""
    line = document.lines[position.line]
    character = position.character

    # Find the start of the identifier (go backwards)
    start = character
    while start > 0 and (line[start - 1].isalnum() or line[start - 1] in "._"):
        start -= 1

    # Find the end of the identifier (go forwards)
    end = character
    while end < len(line) and (line[end].isalnum() or line[end] in "._"):
        end += 1

    word = line[start:end]
    return word


def get_hover_info(
    document: TextDocument,
    position: HoverParams.position,
    api_loader: IgnitionAPILoader
) -> Optional[Hover]:
    """Get hover information for the word at position."""
    word = get_word_at_position(document, position)
    logger.info(f"Hover requested for: '{word}'")

    if not word:
        return None

    # Try to find the function in the API database
    func = api_loader.get_function(word)

    if func:
        # Found a function - return full documentation
        markdown = func.get_markdown_doc()

        return Hover(
            contents=MarkupContent(
                kind=MarkupKind.Markdown,
                value=markdown,
            )
        )

    # Check if it's a module (e.g., hovering over "system" or "system.tag")
    if word.startswith("system."):
        module_funcs = api_loader.get_module_functions(word)
        if module_funcs:
            func_names = [f.name for f in module_funcs[:10]]
            if len(module_funcs) > 10:
                func_names.append("...")

            markdown = f"**{word}**\n\nIgnition module with {len(module_funcs)} functions:\n\n"
            markdown += ", ".join(f"`{name}`" for name in func_names)

            return Hover(
                contents=MarkupContent(
                    kind=MarkupKind.Markdown,
                    value=markdown,
                )
            )

    # Check for partial matches (e.g., hovering over just "readBlocking" without "system.tag.")
    if "." not in word and word:
        # Search all functions for this name
        for full_name, func in api_loader.api_db.items():
            if func.name == word:
                markdown = func.get_markdown_doc()
                return Hover(
                    contents=MarkupContent(
                        kind=MarkupKind.Markdown,
                        value=markdown,
                    )
                )

    # No match found
    logger.debug(f"No hover info found for '{word}'")
    return None
