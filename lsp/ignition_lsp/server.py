"""Main LSP server implementation."""

import logging
import sys
from pathlib import Path
from typing import Optional

import lsprotocol.types
from lsprotocol.types import (
    TEXT_DOCUMENT_COMPLETION,
    TEXT_DOCUMENT_HOVER,
    TEXT_DOCUMENT_DEFINITION,
    TEXT_DOCUMENT_DID_OPEN,
    TEXT_DOCUMENT_DID_CHANGE,
    TEXT_DOCUMENT_DID_SAVE,
    TEXT_DOCUMENT_DID_CLOSE,
    TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS,
    CompletionItem,
    CompletionList,
    CompletionParams,
    DefinitionParams,
    DidOpenTextDocumentParams,
    DidChangeTextDocumentParams,
    DidSaveTextDocumentParams,
    DidCloseTextDocumentParams,
    Diagnostic,
    PublishDiagnosticsParams,
    Hover,
    HoverParams,
    Location,
    MarkupContent,
    MarkupKind,
    Position,
    Range,
    DiagnosticSeverity,
)
from pygls.lsp.server import LanguageServer
from pygls.workspace import TextDocument

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/tmp/ignition-lsp.log'),
        logging.StreamHandler(sys.stderr)
    ]
)
logger = logging.getLogger(__name__)


class IgnitionLanguageServer(LanguageServer):
    """Language server for Ignition development."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.diagnostics_enabled = True
        logger.info("Ignition LSP Server initialized")


server = IgnitionLanguageServer("ignition-lsp", "v0.1.0")


# Document Synchronization Handlers

@server.feature(TEXT_DOCUMENT_DID_OPEN)
async def did_open(ls: IgnitionLanguageServer, params: DidOpenTextDocumentParams):
    """Handle document open event."""
    logger.info(f"Document opened: {params.text_document.uri}")

    # Run diagnostics on open
    if ls.diagnostics_enabled:
        await run_diagnostics(ls, params.text_document.uri)


@server.feature(TEXT_DOCUMENT_DID_CHANGE)
async def did_change(ls: IgnitionLanguageServer, params: DidChangeTextDocumentParams):
    """Handle document change event."""
    logger.debug(f"Document changed: {params.text_document.uri}")

    # Run diagnostics on change (with debouncing in production)
    if ls.diagnostics_enabled:
        await run_diagnostics(ls, params.text_document.uri)


@server.feature(TEXT_DOCUMENT_DID_SAVE)
async def did_save(ls: IgnitionLanguageServer, params: DidSaveTextDocumentParams):
    """Handle document save event."""
    logger.info(f"Document saved: {params.text_document.uri}")

    # Run diagnostics on save
    if ls.diagnostics_enabled:
        await run_diagnostics(ls, params.text_document.uri)


@server.feature(TEXT_DOCUMENT_DID_CLOSE)
def did_close(ls: IgnitionLanguageServer, params: DidCloseTextDocumentParams):
    """Handle document close event."""
    logger.info(f"Document closed: {params.text_document.uri}")

    # Clear diagnostics for closed document
    ls.text_document_publish_diagnostics(
        PublishDiagnosticsParams(
            uri=params.text_document.uri,
            diagnostics=[],
        )
    )


async def run_diagnostics(ls: IgnitionLanguageServer, uri: str):
    """Run diagnostics on a document."""
    try:
        # Use absolute import to avoid package issues when running as __main__
        from ignition_lsp.diagnostics import get_diagnostics

        doc = ls.workspace.get_text_document(uri)
        diagnostics = get_diagnostics(doc)

        # Publish diagnostics using pygls 2.0 API
        ls.text_document_publish_diagnostics(
            PublishDiagnosticsParams(
                uri=uri,
                diagnostics=diagnostics,
            )
        )
        logger.info(f"Published {len(diagnostics)} diagnostics for {uri}")

    except Exception as e:
        logger.error(f"Error running diagnostics: {e}", exc_info=True)
        # Don't crash the server on diagnostic errors
        try:
            ls.text_document_publish_diagnostics(
                PublishDiagnosticsParams(
                    uri=uri,
                    diagnostics=[],
                )
            )
        except:
            pass


# LSP Feature Handlers

@server.feature(TEXT_DOCUMENT_COMPLETION)
def completion(params: CompletionParams) -> Optional[CompletionList]:
    """Provide completion items for Ignition APIs."""
    logger.info(f"Completion requested at {params.position}")

    # TODO: Implement Ignition API completion with api_loader
    items = [
        CompletionItem(
            label="system.tag.read",
            detail="Read a tag value",
            documentation="Reads the value of a tag from the tag provider.",
        ),
        CompletionItem(
            label="system.tag.write",
            detail="Write a tag value",
            documentation="Writes a value to a tag in the tag provider.",
        ),
        CompletionItem(
            label="system.db.runQuery",
            detail="Execute a database query",
            documentation="Executes a SQL query against a database connection.",
        ),
    ]

    return CompletionList(is_incomplete=False, items=items)


@server.feature(TEXT_DOCUMENT_HOVER)
def hover(params: HoverParams) -> Optional[Hover]:
    """Provide hover information for Ignition functions."""
    logger.info(f"Hover requested at {params.position}")

    # TODO: Implement hover documentation lookup
    return Hover(
        contents=MarkupContent(
            kind=MarkupKind.Markdown,
            value="**Ignition Function**\n\nHover documentation coming soon!",
        )
    )


@server.feature(TEXT_DOCUMENT_DEFINITION)
def definition(params: DefinitionParams) -> Optional[Location]:
    """Navigate to definition of Ignition resources."""
    logger.info(f"Definition requested at {params.position}")

    # TODO: Implement go-to-definition for project scripts
    return None


def main():
    """Start the Ignition LSP server."""
    logger.info("Starting Ignition LSP Server...")
    logger.info(f"Python version: {sys.version}")
    logger.info(f"Server version: v0.1.0")

    try:
        # Start the server using stdio
        server.start_io()
    except Exception as e:
        logger.error(f"Server crashed: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
