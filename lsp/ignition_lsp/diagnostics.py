"""Diagnostics provider integrating ignition-lint validation."""

import logging
import sys
from pathlib import Path
from typing import List

from lsprotocol.types import Diagnostic, DiagnosticSeverity, Position, Range
from pygls.workspace import TextDocument

# Add ignition-lint to path
IGNITION_LINT_PATH = Path(__file__).parent.parent.parent.parent / "ignition-lint" / "src"
if IGNITION_LINT_PATH.exists():
    sys.path.insert(0, str(IGNITION_LINT_PATH))

logger = logging.getLogger(__name__)


def get_diagnostics(document: TextDocument) -> List[Diagnostic]:
    """Get diagnostics for a document using ignition-lint."""
    diagnostics = []

    # Only run Python diagnostics on Python files or virtual Python buffers
    # Skip JSON files (Ignition resource files)
    if document.uri.endswith('.json') and not '[Ignition:' in document.uri:
        logger.debug(f"Skipping Python diagnostics for JSON file: {document.uri}")
        return []

    try:
        # Import JythonValidator from ignition-lint
        from ignition_lint.validators.jython import JythonValidator
        from ignition_lint.reporting import LintSeverity

        # Create validator instance
        validator = JythonValidator()

        # Get document content
        content = document.source

        # Run validation
        issues = validator.validate_script(content, context=document.uri)

        # Convert ignition-lint issues to LSP diagnostics
        for issue in issues:
            # Map severity
            severity_map = {
                LintSeverity.ERROR: DiagnosticSeverity.Error,
                LintSeverity.WARNING: DiagnosticSeverity.Warning,
                LintSeverity.INFO: DiagnosticSeverity.Information,
            }

            severity = severity_map.get(issue.severity, DiagnosticSeverity.Warning)

            # Calculate position
            line_num = (issue.line_number or 1) - 1  # Convert to 0-indexed
            line_num = max(0, line_num)  # Ensure non-negative

            # Get the line length for end position
            lines = content.split('\n')
            if line_num < len(lines):
                line_length = len(lines[line_num])
            else:
                line_length = 0

            # Create diagnostic
            diagnostic = Diagnostic(
                range=Range(
                    start=Position(line=line_num, character=0),
                    end=Position(line=line_num, character=line_length),
                ),
                severity=severity,
                code=issue.code,
                source="ignition-lint",
                message=issue.message,
            )

            diagnostics.append(diagnostic)

        logger.info(f"Generated {len(diagnostics)} diagnostics for {document.uri}")

    except ImportError as e:
        logger.warning(f"Could not import ignition-lint: {e}")
        logger.warning(f"Tried path: {IGNITION_LINT_PATH}")
        # Return empty diagnostics if ignition-lint is not available
        return []

    except Exception as e:
        logger.error(f"Error generating diagnostics: {e}", exc_info=True)
        # Return empty diagnostics on error to avoid crashing
        return []

    return diagnostics


def get_diagnostics_for_file(file_path: str, content: str) -> List[Diagnostic]:
    """Get diagnostics for a file path and content."""
    # Create a mock document
    class MockDocument:
        def __init__(self, uri: str, source: str):
            self.uri = uri
            self.source = source

    doc = MockDocument(file_path, content)
    return get_diagnostics(doc)
