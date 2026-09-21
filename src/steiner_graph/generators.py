"""Random graphs for the experiments.

Seed `random` once (`random.seed(...)`) if a run has to be reproducible.
"""

from __future__ import annotations

import random

from steiner_graph.graph import Edge, Graph
from steiner_graph.steiner_graph import SteinerGraph


def random_connected_graph(
    vertex_count: int,
    edge_probability: float,
    max_weight: int = 10,
) -> Graph:
    """A connected graph on the vertices `1..vertex_count` with random integer weights.

    A random spanning tree is drawn first, then every remaining vertex pair becomes an edge
    with probability `edge_probability`. Building the tree up front makes the graph
    connected by construction, instead of drawing graphs until one happens to be connected.
    """
    if vertex_count < 1:
        raise ValueError(f"A graph needs at least one vertex, got {vertex_count}.")
    if not 0.0 <= edge_probability <= 1.0:
        raise ValueError(f"Edge probability must be in [0, 1], got {edge_probability}.")

    vertices = list(range(1, vertex_count + 1))

    attached = [vertices[0]]
    pairs = set()
    for vertex in vertices[1:]:
        pairs.add(_pair(random.choice(attached), vertex))
        attached.append(vertex)

    for index, u in enumerate(vertices):
        for v in vertices[index + 1 :]:
            if random.random() < edge_probability:
                pairs.add(_pair(u, v))

    edges = {Edge(u, v, random.randint(1, max_weight)) for u, v in sorted(pairs)}
    return Graph(set(vertices), edges)


def random_steiner_graph(
    vertex_count: int,
    edge_probability: float,
    terminal_count: int,
    max_weight: int = 10,
) -> SteinerGraph:
    """A random connected graph with `terminal_count` of its vertices drawn as terminals."""
    if not 2 <= terminal_count <= vertex_count:
        raise ValueError(
            f"Terminal count must be between 2 and {vertex_count}, got {terminal_count}."
        )

    graph = random_connected_graph(vertex_count, edge_probability, max_weight)
    terminals = random.sample(sorted(graph.vertices), terminal_count)
    return SteinerGraph(graph, set(terminals))


def _pair(u: int, v: int) -> tuple[int, int]:
    """The vertex pair ordered the same way as in `Edge`, so pairs deduplicate."""
    return (u, v) if u < v else (v, u)
