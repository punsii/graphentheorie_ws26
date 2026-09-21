"""Core graph types."""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass
from functools import cached_property

import networkx as nx


@dataclass(frozen=True)
class Edge:
    """An undirected weighted edge, normalised so that the smaller vertex comes first."""

    u: int
    v: int
    weight: float

    def __post_init__(self) -> None:
        if self.u == self.v:
            raise ValueError("First and second vertex of the edge must differ.")
        if self.weight <= 0:
            raise ValueError(f"Edge weight must be positive, got {self.weight}.")
        if self.u > self.v:
            smaller, larger = self.v, self.u
            object.__setattr__(self, "u", smaller)
            object.__setattr__(self, "v", larger)

    @property
    def endpoints(self) -> frozenset[int]:
        return frozenset((self.u, self.v))


@dataclass(frozen=True)
class Graph:
    """A weighted undirected graph."""

    vertices: frozenset[int]
    edges: frozenset[Edge]

    def __post_init__(self) -> None:
        seen: set[frozenset[int]] = set()
        for edge in self.edges:
            if edge.u not in self.vertices or edge.v not in self.vertices:
                raise ValueError(f"Edge {edge.u}--{edge.v} has an endpoint outside the graph.")
            if edge.endpoints in seen:
                raise ValueError(f"Edge {edge.u}--{edge.v} occurs twice with different weights.")
            seen.add(edge.endpoints)

    @cached_property
    def adjacency(self) -> Mapping[int, frozenset[int]]:
        """Track adjacecny of nodes via adjacecny list per node"""
        neighbours: dict[int, set[int]] = {v: set() for v in self.vertices}
        for edge in self.edges:
            neighbours[edge.u].add(edge.v)
            neighbours[edge.v].add(edge.u)
        return {v: frozenset(adjacent) for v, adjacent in neighbours.items()}

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
        edges = frozenset(
            Edge(u, v, data.get("weight", default_weight)) for u, v, data in graph.edges(data=True)
        )
        return cls(frozenset(graph.nodes), edges)
