"""Runtime and quality measurements, written to a CSV that the figures are built from."""

from __future__ import annotations

import random
import time
from collections.abc import Iterator
from math import comb
from pathlib import Path

import pandas as pd

from steiner_graph.algorithms import approximate_steiner, steiner
from steiner_graph.generators import random_steiner_graph
from steiner_graph.steiner_graph import SteinerGraph

CSV_PATH = Path("results/benchmarks.csv")

ALGORITHMS = {"exact": steiner, "approximation": approximate_steiner}

SEEDS = range(5)
"""Repetitions per parameter point; the seed also makes every row reproducible."""

MAX_SUBSETS = 60_000
"""Parameter points whose enumeration is larger than this are not run exactly.

Deciding by the predicted amount of work rather than by a measured timeout keeps the sweep
reproducible across machines. It also keeps measuring the exact algorithm wherever it is
cheap again: for a fixed graph, many terminals mean few remaining vertices to enumerate,
so the cost grows and falls as the terminal count rises.
"""


def predicted_subsets(vertex_count: int, terminal_count: int) -> int:
    """How many vertex subsets the exact algorithm enumerates for these parameters."""
    steiner_count = vertex_count - terminal_count
    return sum(comb(steiner_count, i) for i in range(terminal_count - 1))


def measure(
    algorithm: str,
    instance: SteinerGraph,
    sweep: str,
    edge_probability: float,
    seed: int,
) -> dict:
    """Run one algorithm on one instance and describe the run as a row."""
    started = time.perf_counter()
    _, weight = ALGORITHMS[algorithm](instance)
    seconds = time.perf_counter() - started

    return {
        "sweep": sweep,
        "algorithm": algorithm,
        "vertex_count": len(instance.graph.vertices),
        "edge_count": len(instance.graph.edges),
        "edge_probability": edge_probability,
        "terminal_count": len(instance.terminals),
        "seed": seed,
        "weight": weight,
        "seconds": seconds,
    }


def build(vertex_count: int, edge_probability: float, terminal_count: int, seed: int):
    """The instance for one parameter point; the seed alone reproduces it."""
    random.seed(seed)
    return random_steiner_graph(vertex_count, edge_probability, terminal_count)


def _sweep(
    name: str,
    points: list[tuple[int, float, int]],
) -> Iterator[dict]:
    """Measure both algorithms over the given parameter points.

    The approximation runs everywhere; the exact algorithm is skipped wherever its
    enumeration would be too large, which is what lets the sweep reach terminal counts it
    could never solve exactly.
    """
    for vertex_count, edge_probability, terminal_count in points:
        affordable = predicted_subsets(vertex_count, terminal_count) <= MAX_SUBSETS

        for seed in SEEDS:
            instance = build(vertex_count, edge_probability, terminal_count, seed)

            yield measure("approximation", instance, name, edge_probability, seed)

            if affordable:
                yield measure("exact", instance, name, edge_probability, seed)


def terminal_sweep(vertex_count: int = 30, edge_probability: float = 0.3) -> Iterator[dict]:
    """More and more terminals on a graph of fixed size."""
    points = [(vertex_count, edge_probability, r) for r in range(2, vertex_count + 1)]
    return _sweep("terminals", points)


def vertex_sweep(edge_probability: float = 0.3, terminal_count: int = 4) -> Iterator[dict]:
    """Bigger and bigger graphs with a fixed, small number of terminals."""
    points = [(n, edge_probability, terminal_count) for n in range(6, 81, 6)]
    return _sweep("vertices", points)


def density_sweep(vertex_count: int = 20, terminal_count: int = 5) -> Iterator[dict]:
    """The same graph size at increasing edge probability."""
    points = [(vertex_count, p / 10, terminal_count) for p in range(1, 11)]
    return _sweep("density", points)


def run_all() -> pd.DataFrame:
    rows = [*terminal_sweep(), *vertex_sweep(), *density_sweep()]
    return pd.DataFrame(rows)


def main() -> None:
    measurements = run_all()
    CSV_PATH.parent.mkdir(parents=True, exist_ok=True)
    measurements.to_csv(CSV_PATH, index=False)
    print(f"wrote {len(measurements)} rows to {CSV_PATH}")


if __name__ == "__main__":
    main()
