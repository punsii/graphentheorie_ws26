"""Core graph types."""

from __future__ import annotations

from dataclasses import dataclass
from functools import cached_property
from typing import NamedTuple

import networkx as nx


class _Edge(NamedTuple):
    """Helper type for easier iterator usage on the Edge class"""

    u: int
    v: int
    weight: float


class Edge(_Edge):
    """An undirected weighted edge, normalised so that the smaller vertex comes first.

    Unpacks as `for u, v, weight in edges` with the field types kept. The
    validation lives in this subclass because `NamedTuple` does not
    allow its own `__new__` to be replaced.
    """

    def __new__(cls, u: int, v: int, weight: float) -> Edge:
        if u == v:
            raise ValueError("First and second vertex of the edge must differ.")
        if weight <= 0:
            raise ValueError(f"Edge weight must be positive, got {weight}.")
        if u > v:
            u, v = v, u
        return _Edge.__new__(cls, u, v, weight)

    @property
    def endpoints(self) -> tuple[int, int]:
        return (self.u, self.v)


@dataclass(frozen=True)
class Graph:
    """A weighted undirected graph."""

    vertices: set[int]
    edges: set[Edge]

    def __post_init__(self) -> None:
        seen: set[tuple[int, int]] = set()
        for edge in self.edges:
            if edge.u not in self.vertices or edge.v not in self.vertices:
                raise ValueError(f"Edge {edge.u}--{edge.v} has an endpoint outside the graph.")
            if edge.endpoints in seen:
                raise ValueError(f"Edge {edge.u}--{edge.v} occurs twice with different weights.")
            seen.add(edge.endpoints)

    @cached_property
    def adjacency(self) -> dict[int, set[int]]:
        """Track adjacency of nodes via adjacency list per node"""
        neighbours: dict[int, set[int]] = {v: set() for v in self.vertices}
        for edge in self.edges:
            neighbours[edge.u].add(edge.v)
            neighbours[edge.v].add(edge.u)
        return neighbours

    def is_connected(self) -> bool:
        """Check if all vertices are reachable from the a start node."""
        if not self.vertices:
            return True
        start = next(iter(self.vertices))
        seen = {start}
        queue = [start]
        while queue:
            for v in self.adjacency[queue.pop()]:
                if v not in seen:
                    seen.add(v)
                    queue.append(v)
        return len(seen) == len(self.vertices)

    def to_networkx(self) -> nx.Graph:
        """The same graph for networkx, which provides the layouts and the drawing."""
        converted = nx.Graph()
        converted.add_nodes_from(sorted(self.vertices))
        converted.add_weighted_edges_from((edge.u, edge.v, edge.weight) for edge in self.edges)
        return converted

    @classmethod
    def from_networkx(cls, graph: nx.Graph, default_weight: float = 1.0) -> Graph:
        """Build from a networkx graph, e.g. one of its generators."""
        edges = {
            Edge(u, v, data.get("weight", default_weight)) for u, v, data in graph.edges(data=True)
        }
        return cls(set(graph.nodes), edges)
