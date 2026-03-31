#!/bin/bash

# -----------------------------------------------------------------------------
# @file convert.sh
# @brief LibreOffice headless document converter script
# @description Converts various document formats to PDF using LibreOffice in headless mode.
# Supports batch conversion via wildcards and custom output naming.
#
# @author Sidney Curron <sidney.curron@oligos.fr>
# @version 0.1
# @date 2026
#
# @copyright Oligos - Magellan
#
# @pre LibreOffice must be installed and available in PATH
# @pre Script must have execute permissions
#
# @note This script is designed to run inside a Docker container
# @note The workspace directory is expected to be mounted at /workspace
#
# Usage: docker run --rm -v $(pwd):/workspace libreoffice input.docx [output.pdf]
# -----------------------------------------------------------------------------

set -e

# -----------------------------------------------------------------------------
# @var INPUT_FILE {string}
# @brief Path to the input document file
# @description First command-line argument specifying the file to convert
# -----------------------------------------------------------------------------
INPUT_FILE="$1"

# -----------------------------------------------------------------------------
# @var OUTPUT_FILE {string}
# @brief [Optional] Path for the output file
# @description Second command-line argument specifying custom output location
# @default If not provided, defaults to PDF with same name as input
# -----------------------------------------------------------------------------
OUTPUT_FILE="$2"

# -----------------------------------------------------------------------------
# @brief Validates input arguments and displays usage information
# @description Checks if input file parameter is provided and shows help text
# if no arguments are given.
#
# @param $1 {string} Input file path or wildcard pattern
# @param $2 {string} [Optional] Output file path
#
# @exit 1 If no input file is provided
# @output Displays usage examples and help text
# -----------------------------------------------------------------------------
if [ -z "$INPUT_FILE" ]; then
    echo "Usage: convert <input-file> [output-file]"
    echo ""
    echo "Examples:"
    echo "  convert document.docx                    # outputs document.pdf"
    echo "  convert document.docx output.pdf         # custom output name"
    echo "  convert *.docx                           # batch convert all docx files"
    exit 1
fi

# -----------------------------------------------------------------------------
# @brief Handles batch conversion using wildcard patterns
# @description We can processes multiple files matching a wildcard pattern (e.g., *.docx).
# Converts each matching file to PDF format.
#
# @param INPUT_FILE {string} Wildcard pattern for file matching
#
# @note Supports * and ? wildcard characters
# @note Only processes regular files (skips directories)
# @exit 0 After successful batch conversion
# -----------------------------------------------------------------------------
# Handle wildcard patterns (batch conversion)
if [[ "$INPUT_FILE" == *"*"* ]] || [[ "$INPUT_FILE" == *"?"* ]]; then
    echo "Converting files matching: $INPUT_FILE"
    for file in $INPUT_FILE; do
        if [ -f "$file" ]; then
            echo "  → Converting: $file"
            libreoffice --headless --convert-to pdf --outdir /workspace "$file"
        fi
    done
    echo "Done!"
    exit 0
fi

# -----------------------------------------------------------------------------
# @brief Validates that input file exists
# @description Checks if the specified input file is a regular file that exists.
#
# @param INPUT_FILE {string} Path to the input file
#
# @exit 1 If file does not exist or is not a regular file
# @output Error message to stderr if file not found
# -----------------------------------------------------------------------------
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File not found: $INPUT_FILE"
    exit 1
fi

# -----------------------------------------------------------------------------
# @brief Performs document conversion using LibreOffice
# @description Converts the input document to the specified output format.
# Handles both custom output paths and default PDF conversion.
#
# @param INPUT_FILE {string} Path to the input document
# @param OUTPUT_FILE {string} [Optional] Desired output path
#
# @details
# - If OUTPUT_FILE is specified, extracts directory and extension
# - Uses LibreOffice's headless mode for conversion
# - Renames output file if custom name differs from input name
# - Defaults to PDF format in /workspace if no output specified
#
# @note LibreOffice always creates output with input filename, so renaming may be needed
# @note Supports any format LibreOffice can export to
# -----------------------------------------------------------------------------
# Determine output format and directory
if [ -n "$OUTPUT_FILE" ]; then
    OUTDIR=$(dirname "$OUTPUT_FILE")
    OUTFILE=$(basename "$OUTPUT_FILE")
    EXT="${OUTFILE##*.}"

    # Extract filename without extension for --outdir handling
    OUTNAME="${OUTFILE%.*}"

    libreoffice --headless --convert-to "$EXT" --outdir "$OUTDIR" "$INPUT_FILE"

    # Rename if output name differs from input
    INPUT_BASENAME=$(basename "$INPUT_FILE")
    INPUT_NAME="${INPUT_BASENAME%.*}"
    if [ "$INPUT_NAME" != "$OUTNAME" ]; then
        mv "$OUTDIR/${INPUT_NAME}.${EXT}" "$OUTPUT_FILE" 2>/dev/null || true
    fi
else
    # Default to PDF in same directory
    libreoffice --headless --convert-to pdf --outdir /workspace "$INPUT_FILE"
fi

# -----------------------------------------------------------------------------
# @brief Displays completion message
# @description Prints a success message after conversion is complete.
# @output "Conversion complete!" to stdout
# -----------------------------------------------------------------------------
echo "Conversion complete!"
