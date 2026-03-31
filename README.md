# LibreOffice Headless Document Converter

A lightweight Docker image for converting documents to PDF using LibreOffice in headless mode.

- **Base image:** `debian:bookworm-slim`
- **LibreOffice components:** Writer, Calc, Impress (headless, no GUI)
- **Runs as:** non-root user (`converter`) for security
- **Version:** 0.1
- **Author:** Sidney Curron <sidney.curron@oligos.fr>
- **Copyright:** Oligos - Magellan

## Quick Start

```bash
# Build the image
docker build -t libreoffice .

# Convert a single file
docker run --rm -v $(pwd):/workspace libreoffice document.docx

# Convert with custom output name
docker run --rm -v $(pwd):/workspace libreoffice document.docx output.pdf

# Batch convert
docker run --rm -v $(pwd):/workspace libreoffice "*.docx"
```

## Supported Input Formats

| Input | Default Output |
|-------|---------------|
| DOC, DOCX | PDF |
| XLS, XLSX | PDF |
| PPT, PPTX | PDF |
| ODT, ODS, ODP | PDF |
| RTF, TXT | PDF |

Any format supported by LibreOffice can be used as input. The output format is determined by the extension of the output file argument.

## Usage

```
convert <input-file> [output-file]
```

The entrypoint inside the container is `/usr/local/bin/convert`.  
The working directory is `/workspace` — mount your files there.

### Basic Conversion (DOCX → PDF)

```bash
docker run --rm -v $(pwd):/workspace libreoffice report.docx
# Creates: /workspace/report.pdf
```

### Custom Output Name

```bash
docker run --rm -v $(pwd):/workspace libreoffice input.docx final-report.pdf
```

### Custom Output Format

The output format is inferred from the output file extension. Any format LibreOffice can export to is supported.

```bash
docker run --rm -v $(pwd):/workspace libreoffice document.docx document.html
```

### Batch Convert (Wildcard)

Supports `*` and `?` wildcard patterns. All matching files are converted to PDF in `/workspace`.

```bash
docker run --rm -v $(pwd):/workspace libreoffice "*.docx"
```

### Convert Excel to PDF

```bash
docker run --rm -v $(pwd):/workspace libreoffice spreadsheet.xlsx
```

### Convert PowerPoint to PDF

```bash
docker run --rm -v $(pwd):/workspace libreoffice presentation.pptx
```

## Docker Compose

```yaml
version: '3'
services:
  convert:
    build: .
    volumes:
      - ./documents:/workspace
```

```bash
docker-compose run --rm convert document.docx
```

## Notes

- The image runs as a non-root `converter` user.
- LibreOffice always writes output using the input filename; the script handles renaming automatically when a custom output name is provided.
- Fonts included: `fonts-liberation2`, `fonts-dejavu-core`.
- LibreOffice packages used are the `*-nogui` variants (`libreoffice-writer-nogui`, `libreoffice-calc-nogui`, `libreoffice-impress-nogui`), which are sufficient for headless conversion and exclude all GUI dependencies.
