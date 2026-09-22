import random

import pytest

from steiner_graph.algorithms import (
    approximate_steiner,
    floyd,
    prim,
    reconstruct_floyd_path_edges,
    steiner,
)
from steiner_graph.generators import random_steiner_graph
from steiner_graph.graph import Edge, Graph
from steiner_graph.steiner_graph import SteinerGraph

# A path 1--2--3--4 of cheap edges, plus one expensive shortcut from 1 to 4.
PATH = Edge(1, 2, 1.0), Edge(2, 3, 1.0), Edge(3, 4, 1.0)
SHORTCUT = Edge(1, 4, 10.0)
GRAPH = Graph({1, 2, 3, 4}, {*PATH, SHORTCUT})

# The cheap way from 1 to 4 is 1--3--2--4, which has to step from 3 down to 2. The
# expensive direct edge is the only route that never decreases the vertex number.
DETOUR = Graph(
    {1, 2, 3, 4},
    {Edge(1, 3, 1.0), Edge(2, 3, 1.0), Edge(2, 4, 1.0), Edge(1, 4, 10.0)},
)


def test_floyd_finds_the_cheap_way_around():
    distances, _ = floyd(GRAPH)
    assert distances[(1, 4)] == 3.0


def test_floyd_path_edges_are_the_cheap_ones():
    distances, predecessors = floyd(GRAPH)
    assert reconstruct_floyd_path_edges(1, 4, distances, predecessors) == set(PATH)


def test_floyd_does_not_care_about_vertex_numbering():
    distances, predecessors = floyd(DETOUR)
    assert distances[(1, 4)] == 3.0
    # the cheap way from 1 to 4 is 1--3--2--4
    assert reconstruct_floyd_path_edges(1, 4, distances, predecessors) == {
        Edge(1, 3, 1.0),
        Edge(2, 3, 1.0),
        Edge(2, 4, 1.0),
    }


def test_prim_leaves_out_the_shortcut():
    distances, _ = floyd(GRAPH)
    tree, total_weight = prim(GRAPH.vertices, distances)
    assert tree == set(PATH)
    assert total_weight == 3.0


def test_steiner_tree_stops_at_the_terminals():
    tree, total_weight = steiner(SteinerGraph(GRAPH, {1, 3}))
    assert tree == {Edge(1, 2, 1.0), Edge(2, 3, 1.0)}
    assert total_weight == 2.0
    # the expanded tree has to weigh exactly what the search reported
    assert sum(edge.weight for edge in tree) == total_weight


def test_approximation_finds_the_optimum_on_the_fixture():
    tree, total_weight = approximate_steiner(SteinerGraph(GRAPH, {1, 3}))
    assert tree == {Edge(1, 2, 1.0), Edge(2, 3, 1.0)}
    assert total_weight == 2.0


@pytest.mark.parametrize("seed", range(10))
def test_approximation_stays_within_twice_the_optimum(seed):
    random.seed(seed)
    instance = random_steiner_graph(12, 0.25, 4)

    _, optimum = steiner(instance)
    approximate_tree, approximate_weight = approximate_steiner(instance)

    assert optimum <= approximate_weight <= 2 * optimum
    # every terminal has to show up in the approximate tree as well
    assert instance.terminals <= {vertex for edge in approximate_tree for vertex in edge.endpoints}
