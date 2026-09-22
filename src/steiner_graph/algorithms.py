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
    vertices = graph.vertices
    edges = graph.edges

    distances = {(u, v): 0 if u == v else float("inf") for u in vertices for v in vertices}
    predecessors = {(u, v): u if u == v else None for u in vertices for v in vertices}

    for u, v, weight in edges:
        distances[(u, v)] = weight
        distances[(v, u)] = weight
        predecessors[(u, v)] = u
        predecessors[(v, u)] = v

    for k in vertices:
        for i in vertices:
            for j in vertices:
                # Check if the currently known shortest path (i => j)
                # can be 'shortcutted' by visiting another node (k) first.
                if distances[(i, k)] + distances[(k, j)] < distances[(i, j)]:
                    distances[(i, j)] = distances[(i, k)] + distances[(k, j)]
                    predecessors[(i, j)] = predecessors[(k, j)]

    return distances, predecessors


def reconstruct_floyd_path(u: int, v: int, predecessors: Predecessors) -> list[int]:
    path = [v]
    while u != v:
        prev = predecessors[(u, v)]
        if prev is None:
            raise Exception(
                "Subpath of floyd reconstruction is not defined. This should not be possible..."
            )
        else:
            v = prev
        path.append(v)
    # currently the path collected predecessors, so we need
    # to reverse it in order to find the actual path from u => v
    path.reverse()
    return path


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
