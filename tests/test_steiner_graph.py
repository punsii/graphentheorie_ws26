import pytest

from steiner_graph.graph import Edge, Graph
from steiner_graph.steiner_graph import SteinerGraph

PATH = Graph(frozenset({1, 2, 3}), frozenset({Edge(1, 2, 1.0), Edge(2, 3, 2.0)}))


def test_steiner_vertices_are_the_non_terminals():
    assert SteinerGraph(PATH, frozenset({1, 3})).steiner_vertices == frozenset({2})


def test_all_vertices_may_be_terminals():
    assert SteinerGraph(PATH, frozenset({1, 2, 3})).steiner_vertices == frozenset()


def test_rejects_terminal_outside_the_graph():
    with pytest.raises(ValueError, match="outside the graph"):
        SteinerGraph(PATH, frozenset({1, 9}))


def test_rejects_fewer_than_two_terminals():
    with pytest.raises(ValueError, match="two terminals"):
        SteinerGraph(PATH, frozenset({1}))


def test_rejects_disconnected_graph():
    disconnected = Graph(frozenset({1, 2, 3}), frozenset({Edge(1, 2, 1.0)}))
    with pytest.raises(ValueError, match="connected"):
        SteinerGraph(disconnected, frozenset({1, 2}))
