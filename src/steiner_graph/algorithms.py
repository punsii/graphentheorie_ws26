"""The algorithms themselves. To be implemented by hand."""

from __future__ import annotations

import itertools

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


def reconstruct_floyd_path_edges(
    u: int, v: int, distances: Distances, predecessors: Predecessors
) -> set[Edge]:
    """Regenerates the path from u to v given the predecessors returned by floyd."""
    edges: set[Edge] = set()
    while u != v:
        prev = predecessors[(u, v)]
        if prev is None:
            raise Exception(
                "Subpath of floyd reconstruction is not defined. This should not be possible..."
            )
        else:
            edges.add(Edge(prev, v, distances[(prev, v)]))
            v = prev
    return edges


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


def steiner(steiner_graph: SteinerGraph) -> tuple[set[Edge], float]:
    """A minimum weight tree connecting all terminals.

    Non-terminal vertices may be used when they make the tree lighter, but need not appear.
    Returns a set of the resulting edges and the sum of their weights.
    """
    terminals = steiner_graph.terminals
    steiner_vertices = steiner_graph.steiner_vertices
    graph = steiner_graph.graph

    best_weight = float("inf")
    best_tree_edges: set[Edge] = set()

    # precalculate all vertex to vertex shortest paths
    distances, predecessors = floyd(graph)

    # search over all subset sizes of steiner vertices up to (number of terminals) - 2
    max_steiner_count = min(len(terminals) - 2, len(steiner_vertices))
    for i in range(0, max_steiner_count + 1):
        for selected_steiner_vertices in itertools.combinations(steiner_vertices, i):
            vertex_subset = terminals | set(selected_steiner_vertices)

            ## XXX This entire block was initially implemented in order to track
            ## XXX the algorithm as printed in Jungnickel, Graphs, Networks and
            ## XXX Algorithms, Springer 2002, Algorithm 4.6.3, as closely as
            ## XXX possible, but it is not actually needed.
            ## XXX Simply passing the full distances set to prim() works
            ## XXX because the additional entries will never be accessed.
            ## XXX Filtering the distances set would have introduced
            ## XXX an additional O(n^2) factor to the runtime.
            # complete graph metric closure induced by vertex_subset
            # metric_closure_edges = {
            #     Edge(u, v, distances[(u, v)])
            #     for u in vertex_subset
            #     for v in vertex_subset
            #     if u < v
            # }
            # subgraph = Graph(vertices=vertex_subset, edges=metric_closure_edges)
            # subgraph_distances = {
            #     key: distances[key]
            #     for key in distances.keys()
            #     if key[0] in vertex_subset and key[1] in vertex_subset
            # }
            # tree_edges, cost = prim(subgraph.vertices, subgraph_distances)
            ## XXX
            tree_edges, cost = prim(vertex_subset, distances)

            if cost < best_weight:
                best_weight = cost
                best_tree_edges = tree_edges

    # reconstruct shortest path edges in the original graph
    final_edges: set[Edge] = set()
    for u, v, _ in best_tree_edges:
        final_edges |= reconstruct_floyd_path_edges(u, v, distances, predecessors)

    return final_edges, best_weight
