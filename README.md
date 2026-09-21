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

## Plotting

```python
import random

from steiner_graph.generators import random_steiner_graph
from steiner_graph.plotting import layout, plot

random.seed(42)
steiner_graph = random_steiner_graph(vertex_count=10, edge_probability=0.3, terminal_count=3)

positions = layout(steiner_graph.graph)  # reuse to keep plots of one graph comparable
figure = plot(steiner_graph.graph, terminals=steiner_graph.terminals, positions=positions)
figure.write_image("results/instance.png")
```

Pass a set of edges as `tree=` to draw it on top of the graph.

## Layout

| Path                 | Contents                                          |
| -------------------- | ------------------------------------------------- |
| `src/steiner_graph/` | Library: types, generators, drawing, benchmarks   |
| `tests/`             | Test suite, including instances with known optima |
| `slides/`            | Lecture slides (course material)                  |
| `results/`           | Benchmark CSVs and generated figures              |
