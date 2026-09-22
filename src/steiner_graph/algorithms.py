"""The algorithms themselves. To be implemented by hand."""

from __future__ import annotations

from steiner_graph.graph import Edge, Graph
from steiner_graph.steiner_graph import SteinerGraph

Distances = dict[tuple[int, int], float]
"""Shortest path length for every ordered pair of vertices."""

Predecessors = dict[tuple[int, int], int | None]
"""For a pair `(u, v)`, the vertex before `v` on a shortest path from `u`."""


def floyd(graph: Graph) -> tuple[Distances, Predecessors]:
    """Shortest paths between all pairs of vertices.

    Returns the distances and the predecessors; the predecessors are what allows a shortest
    path to be rebuilt vertex by vertex, not just its length.
    """
    raise NotImplementedError


def prim(graph: Graph) -> set[Edge]:
    """A minimum spanning tree of a connected graph, as its set of edges.

    Prim rather than Kruskal because it runs on the complete distance graph, where scanning
    the distances costs less than sorting all of its edges.
    """
    raise NotImplementedError


def steiner(steiner_graph: SteinerGraph) -> set[Edge]:
    """A minimum weight tree connecting all terminals.

    Non-terminal vertices may be used when they make the tree lighter, but need not appear.
    """
    raise NotImplementedError
