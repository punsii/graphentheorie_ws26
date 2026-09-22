from steiner_graph.algorithms import floyd, prim, reconstruct_floyd_path, steiner
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


def test_floyd_path_visits_every_vertex_on_the_way():
    _, predecessors = floyd(GRAPH)
    assert reconstruct_floyd_path(1, 4, predecessors) == [1, 2, 3, 4]


def test_floyd_does_not_care_about_vertex_numbering():
    distances, predecessors = floyd(DETOUR)
    assert distances[(1, 4)] == 3.0
    assert reconstruct_floyd_path(1, 4, predecessors) == [1, 3, 2, 4]


def test_prim_leaves_out_the_shortcut():
    distances, _ = floyd(GRAPH)
    tree, total_weight = prim(GRAPH.vertices, distances)
    assert tree == set(PATH)
    assert total_weight == 3.0


def test_steiner_tree_stops_at_the_terminals():
    assert steiner(SteinerGraph(GRAPH, {1, 3})) == {Edge(1, 2, 1.0), Edge(2, 3, 1.0)}
