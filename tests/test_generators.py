import random

import pytest

from steiner_graph.generators import random_connected_graph, random_steiner_graph


def test_same_seed_gives_the_same_graph():
    random.seed(1)
    first = random_connected_graph(10, 0.3)
    random.seed(1)
    second = random_connected_graph(10, 0.3)
    assert first == second


def test_different_seeds_give_different_graphs():
    random.seed(1)
    first = random_connected_graph(10, 0.3)
    random.seed(2)
    second = random_connected_graph(10, 0.3)
    assert first != second


@pytest.mark.parametrize("seed", range(5))
def test_generated_graphs_are_connected(seed):
    random.seed(seed)
    assert random_connected_graph(12, 0.1).is_connected()


def test_vertices_are_numbered_from_one():
    assert random_connected_graph(4, 0.5).vertices == {1, 2, 3, 4}


def test_probability_zero_gives_a_spanning_tree():
    graph = random_connected_graph(8, 0.0)
    assert len(graph.edges) == len(graph.vertices) - 1


def test_probability_one_gives_a_complete_graph():
    graph = random_connected_graph(6, 1.0)
    assert len(graph.edges) == 6 * 5 // 2


def test_weights_stay_within_the_limit():
    graph = random_connected_graph(10, 0.4, max_weight=3)
    assert all(1 <= edge.weight <= 3 for edge in graph.edges)


@pytest.mark.parametrize("vertex_count", [0, -1])
def test_rejects_empty_graphs(vertex_count):
    with pytest.raises(ValueError, match="at least one vertex"):
        random_connected_graph(vertex_count, 0.5)


@pytest.mark.parametrize("probability", [-0.1, 1.1])
def test_rejects_probabilities_outside_the_unit_interval(probability):
    with pytest.raises(ValueError, match="in \\[0, 1\\]"):
        random_connected_graph(5, probability)


def test_steiner_graph_has_the_requested_number_of_terminals():
    steiner_graph = random_steiner_graph(10, 0.3, 4)
    assert len(steiner_graph.terminals) == 4
    assert steiner_graph.terminals <= steiner_graph.graph.vertices


@pytest.mark.parametrize("terminal_count", [1, 11])
def test_rejects_impossible_terminal_counts(terminal_count):
    with pytest.raises(ValueError, match="between 2 and 10"):
        random_steiner_graph(10, 0.3, terminal_count)
