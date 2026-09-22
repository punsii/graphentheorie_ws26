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

    distances = {(u, v): 0.0 if u == v else float("inf") for u in vertices for v in vertices}
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
    """Regenerates the path from u to v given the predecessors returned by floyd."""
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


def prim(vertices: set[int], distances: Distances) -> tuple[set[Edge], float]:
    """A minimum spanning tree of a connected graph, as its set of edges.
    Instead of a Graph, this implementation expects as its inputs vertices and
    the already precomputed distances between all of them as returned by `floyd()`.
    Returns a set of Edges plus the sum of all weights of the resulting MST.
    """
    # choose a random starting vertex
    start = next(iter(vertices))
    mst_edges: set[Edge] = set()
    total_weight = 0.0

    # track which vertex inside the tree is the closest for each of the unvisited vertices
    closest_vertex_in_tree = {v: start for v in vertices if v != start}
    # track the distance between each unvisited vertices to the tree
    shortest_path_to_tree = {v: distances[start, v] for v in vertices if v != start}

    # track visited vertices in order to determine end condition
    visited = {start}
    # also track unvisited vertices for convenience
    unvisited = {v for v in vertices if v != start}

    while len(visited) < len(vertices):
        # select the vertex 'v' that is currently closest to the tree
        v, weight = min(shortest_path_to_tree.items(), key=lambda item: item[1])
        unvisited.remove(v)
        visited.add(v)

        # connect 'v' to its closest tree vertex 't'
        # since all edges have a weight > 0, this shortest path must correspond to a direct edge
        t = closest_vertex_in_tree[v]
        mst_edges.add(Edge(v, t, weight))
        total_weight += weight

        # update the shortest path for the remaining unvisited vertices
        for u in unvisited:
            if distances[u, v] < shortest_path_to_tree[u]:
                shortest_path_to_tree[u] = distances[u, v]
                closest_vertex_in_tree[u] = v
        del shortest_path_to_tree[v]
        del closest_vertex_in_tree[v]

    return (mst_edges, total_weight)


def steiner(steiner_graph: SteinerGraph) -> set[Edge]:
    """A minimum weight tree connecting all terminals.

    Non-terminal vertices may be used when they make the tree lighter, but need not appear.
    """
    raise NotImplementedError
