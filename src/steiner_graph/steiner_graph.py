"""Problem instance for the Steiner tree problem in graphs."""

from __future__ import annotations

from dataclasses import dataclass

from steiner_graph.graph import Graph


@dataclass(frozen=True)
class SteinerGraph:
    """A connected graph together with the terminals that have to be connected.

    The remaining vertices may be used to shorten the tree, but don't need to appear in it.
    """

    graph: Graph
    terminals: set[int]

    def __post_init__(self) -> None:
        outside = self.terminals - self.graph.vertices
        if outside:
            raise ValueError(f"Terminals outside the graph: {sorted(outside)}.")
        if len(self.terminals) < 2:
            raise ValueError("At least two terminals are required.")
        if not self.graph.is_connected():
            raise ValueError("The graph must be connected.")

    @property
    def steiner_vertices(self) -> set[int]:
        """Vertices that are not terminals."""
        return self.graph.vertices - self.terminals
