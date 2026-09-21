import networkx as nx
import pytest

from steiner_graph.graph import Edge, Graph


def test_edge_is_normalised():
    assert Edge(3, 1, 2.0) == Edge(1, 3, 2.0)


def test_edge_rejects_loop():
    with pytest.raises(ValueError, match="must differ"):
        Edge(2, 2, 1.0)


@pytest.mark.parametrize("weight", [0.0, -1.5])
def test_edge_rejects_non_positive_weight(weight):
    with pytest.raises(ValueError, match="positive"):
        Edge(1, 2, weight)


def test_graph_rejects_endpoint_outside_vertices():
    with pytest.raises(ValueError, match="outside the graph"):
        Graph({1, 2}, {Edge(2, 3, 1.0)})


def test_graph_rejects_same_edge_with_two_weights():
    with pytest.raises(ValueError, match="twice"):
        Graph({1, 2}, {Edge(1, 2, 1.0), Edge(2, 1, 5.0)})


def test_adjacency_is_symmetric_and_covers_isolated_vertices():
    graph = Graph({1, 2, 3}, {Edge(1, 2, 1.0)})
    assert graph.adjacency == {1: {2}, 2: {1}, 3: set()}


def test_is_connected():
    path = Graph({1, 2, 3}, {Edge(1, 2, 1.0), Edge(2, 3, 1.0)})
    assert path.is_connected()


def test_is_connected_false_for_isolated_vertex():
    graph = Graph({1, 2, 3}, {Edge(1, 2, 1.0)})
    assert not graph.is_connected()


def test_empty_graph_is_connected():
    assert Graph(set(), set()).is_connected()


def test_networkx_round_trip_keeps_vertices_edges_and_weights():
    graph = Graph({1, 2, 3, 4}, {Edge(1, 2, 1.5), Edge(2, 3, 4.0)})
    assert Graph.from_networkx(graph.to_networkx()) == graph


def test_to_networkx_stores_the_weight_attribute():
    graph = Graph({1, 2}, {Edge(1, 2, 2.5)})
    assert graph.to_networkx()[1][2]["weight"] == 2.5


def test_from_networkx_uses_the_default_weight_for_unweighted_edges():
    unweighted_nx_graph = nx.path_graph([1, 2, 3])
    graph = Graph.from_networkx(unweighted_nx_graph, default_weight=3.0)
    assert all(edge.weight == 3.0 for edge in graph.edges)
