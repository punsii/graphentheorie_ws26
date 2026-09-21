# Coursework Graphentheorie SS2026
## Quickstart

With Nix (direnv users get this automatically via `.envrc`):

```sh
nix develop
pytest
```

Without Nix e.g. with `venv`:

```sh
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
pytest
```

The Nix shell does not install the project; it puts `src/` on `PYTHONPATH` instead. Both
paths therefore run the same code from the working tree.

## Layout

| Path                  | Contents                                              |
| --------------------- | ----------------------------------------------------- |
| `src/steiner_graph/`  | Library: types, generators, drawing, benchmarks        |
| `tests/`              | Test suite, including instances with known optima      |
| `slides/`             | Lecture slides (course material)                       |
| `results/`            | Benchmark CSVs and generated figures                   |
