# AGENTS.md - Developer Guide for word-embedding-golf

## Project Overview

This is a Nix-based Python project for word embedding golf. It generates word similarity graphs from GloVe embeddings and renders them as a webapp.

## Project Structure

```
.
├── flake.nix                           # Nix flake entry point
├── flake.lock                          # Nix dependency lock file
├── word_emb_golf_graph/                # Core Python package
│   ├── default.nix                     # Nix package definition
│   ├── setup.py                        # Package setup
│   └── word_emb_golf_graph/
│       ├── __init__.py
│       └── graph.py                    # Graph data structures
├── word_emb_golf_preprocess/           # Graph generation scripts
│   ├── default.nix
│   └── gen_graph.py                    # Generates word graph from embeddings
└── word_emb_golf_webapp/               # Webapp renderer
    ├── default.nix
    ├── render_webapp.py                # Renders HTML from template
    └── word_emb_golf_webapp.html       # HTML template
```

## Build/Lint/Test Commands

### Enter Development Shell
```bash
nix develop
```

### Build the Project
```bash
nix build
```
Build output goes to `result/`.

### Run the Webapp
```bash
nix run
```
This serves the webapp on port 8080.

### Single Test Execution
Tests are in `word_emb_golf_graph/tests/`:
```bash
nix develop --command bash -c "python -m pytest word_emb_golf_graph/tests/ -v"
```

### Type Checking
```bash
python -m mypy word_emb_golf_graph/
```

### Linting
```bash
python -m ruff check word_emb_golf_graph/
```

### Format Code
```bash
python -m ruff format word_emb_golf_graph/
```

## Code Style Guidelines

### General Principles
- Follow PEP 8 with 100-character line limit
- Use 4-space indentation (no tabs)
- Use descriptive names (snake_case for functions/variables, PascalCase for classes)

### Imports
Order imports in each file:
1. Standard library
2. Third-party packages
3. Local packages

Example:
```python
import os
import json
from dataclasses import dataclass, field, asdict

import numpy as np
import networkx as nx
from sklearn.metrics.pairwise import cosine_similarity

from word_emb_golf_graph import load_graph_as_gzip_base64
```

### Type Hints
Use type hints for all function signatures:
```python
def save_graph_gzip(graph_dict: dict, fpath: str) -> None:
    ...
```

Use built-in generic types from `typing`:
```python
from typing import Optional

def process_words(words: list[str]) -> Optional[dict[str, list[float]]]:
    ...
```

### Dataclasses
Use `@dataclass` for data containers:
```python
from dataclasses import dataclass, field

@dataclass
class WordEmbEntry:
    neighbors: list[str] = field(default_factory=list)
    emb: list[float] = field(default_factory=list)
    tsne_emb: list[float] = field(default_factory=list)
```

### Naming Conventions
- Functions/variables: `snake_case` (e.g., `save_graph_gzip`, `graph_dict`)
- Classes: `PascalCase` (e.g., `WordEmbEntry`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_NEIGHBORS`)
- Private functions: prefix with underscore (e.g., `_get_embedding_dict`)

### Error Handling
- Use exceptions for exceptional cases
- Catch specific exceptions, not bare `except:`
- Let exceptions propagate when caller should handle them:
```python
def import_embedding_dict() -> dict:
    embedding_fpath = os.environ['GLOVE_DATA']
    if not os.path.exists(embedding_fpath):
        raise FileNotFoundError(f"GLOVE_DATA not found: {embedding_fpath}")
    return _get_embedding_dict(embedding_fpath, ...)
```

### Docstrings
Use Google-style docstrings for public functions:
```python
def load_graph_as_gzip_base64(fpath: str) -> str:
    """Load graph from a gzip+base64 encoded file.

    Args:
        fpath: Path to the encoded graph file.

    Returns:
        Base64-encoded gzip string of the graph.
    """
    with open(fpath, 'r') as ifile:
        return ifile.read()
```

### Performance Considerations
- Use numpy vectorized operations over Python loops
- Use `heapq` for top-k selections
- Pre-allocate arrays where possible

## Environment Variables

The project uses these environment variables (set automatically by Nix):
- `GRAPH_DATA`: Output path for generated graph (set by flake.nix shellHook)
- `GLOVE_DATA`: Path to GloVe embeddings file
- `COMMON_WORD_DATA`: Path to common words list

## Dependencies

Core dependencies (defined in flake.nix):
- numpy
- networkx
- scikit-learn
- flask
- jinja2
- setuptools (for package building)

## Adding New Features

1. **New Python module**: Add to appropriate directory and update `default.nix` if it needs to be in the Nix package
2. **New dependency**: Add to `flake.nix` in `buildInputs` and update relevant `default.nix` files
3. **New test**: Create `tests/` directory and add pytest configuration
