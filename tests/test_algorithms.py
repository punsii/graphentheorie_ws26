from steiner_graph.algorithms import floyd, prim, steiner
from steiner_graph.graph import Edge, Graph
from steiner_graph.steiner_graph import SteinerGraph

# A path 1--2--3--4 of cheap edges, plus one expensive shortcut from 1 to 4.
PATH = Edge(1, 2, 1.0), Edge(2, 3, 1.0), Edge(3, 4, 1.0)
SHORTCUT = Edge(1, 4, 10.0)
GRAPH = Graph({1, 2, 3, 4}, {*PATH, SHORTCUT})


def test_floyd_finds_the_cheap_way_around():
    distances, _ = floyd(GRAPH)
    assert distances[(1, 4)] == 3.0


def test_prim_leaves_out_the_shortcut():
    assert prim(GRAPH) == set(PATH)


def test_steiner_tree_stops_at_the_terminals():
    assert steiner(SteinerGraph(GRAPH, {1, 3})) == {Edge(1, 2, 1.0), Edge(2, 3, 1.0)}
