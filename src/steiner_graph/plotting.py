"""Plotting graphs with plotly."""

from __future__ import annotations

from collections.abc import Iterable

import networkx as nx
import plotly.graph_objects as go

from steiner_graph.graph import Edge, Graph

Positions = dict[int, tuple[float, float]]

TERMINAL_COLOUR = "#1b3a6b"
VERTEX_COLOUR = "#e9ecef"
TREE_COLOUR = "#e8590c"
EDGE_COLOUR = "#adb5bd"


def layout(graph: Graph) -> Positions:
    """Vertex positions, reusable so that several plots of one graph stay comparable."""
    placed = nx.spring_layout(graph.to_networkx())
    return {vertex: (float(x), float(y)) for vertex, (x, y) in placed.items()}


def plot(
    graph: Graph,
    terminals: set[int] | None = None,
    tree: set[Edge] | None = None,
    positions: Positions | None = None,
    show_weights: bool = True,
) -> go.Figure:
    """Plot a graph, highlighting the terminals and the edges of a tree.

    Terminals differ from the other vertices in shape, size and colour, and tree edges from
    the other edges in width and colour, so the plot still works printed in grey.
    """
    terminals = terminals or set()
    tree = tree or set()

    unknown_terminals = terminals - graph.vertices
    if unknown_terminals:
        raise ValueError(f"Terminals outside the graph: {sorted(unknown_terminals)}.")
    unknown_edges = tree - graph.edges
    if unknown_edges:
        outside = sorted(edge.endpoints for edge in unknown_edges)
        raise ValueError(f"Tree edges outside the graph: {outside}.")

    positions = positions or layout(graph)

    figure = go.Figure()
    figure.add_trace(_edge_trace(graph.edges - tree, positions, EDGE_COLOUR, 1.0, "edge"))
    if tree:
        figure.add_trace(_edge_trace(tree, positions, TREE_COLOUR, 4.0, "tree edge"))
    figure.add_trace(
        _vertex_trace(graph.vertices - terminals, positions, VERTEX_COLOUR, "circle", "vertex")
    )
    if terminals:
        figure.add_trace(_vertex_trace(terminals, positions, TERMINAL_COLOUR, "square", "terminal"))

    figure.update_layout(
        showlegend=True,
        hovermode="closest",
        margin=dict(l=20, r=20, t=30, b=20),
        plot_bgcolor="white",
        xaxis=dict(visible=False),
        yaxis=dict(visible=False, scaleanchor="x"),
        annotations=_weight_labels(graph.edges, positions) if show_weights else [],
    )
    return figure


def _edge_trace(
    edges: Iterable[Edge], positions: Positions, colour: str, width: float, name: str
) -> go.Scatter:
    """One trace for a group of edges; `None` between segments breaks the line."""
    x: list[float | None] = []
    y: list[float | None] = []
    for edge in edges:
        start, end = positions[edge.u], positions[edge.v]
        x.extend([start[0], end[0], None])
        y.extend([start[1], end[1], None])
    return go.Scatter(x=x, y=y, mode="lines", line=dict(color=colour, width=width), name=name)


def _vertex_trace(
    vertices: Iterable[int], positions: Positions, colour: str, symbol: str, name: str
) -> go.Scatter:
    ordered = sorted(vertices)
    return go.Scatter(
        x=[positions[vertex][0] for vertex in ordered],
        y=[positions[vertex][1] for vertex in ordered],
        mode="markers+text",
        marker=dict(color=colour, symbol=symbol, size=26, line=dict(color=EDGE_COLOUR, width=1)),
        text=[str(vertex) for vertex in ordered],
        textfont=dict(color="white" if colour == TERMINAL_COLOUR else "black"),
        textposition="middle center",
        name=name,
        hoverinfo="text",
    )


def _weight_labels(edges: Iterable[Edge], positions: Positions) -> list[dict]:
    """Edge weights, written at the middle of each edge."""
    labels = []
    for edge in edges:
        start, end = positions[edge.u], positions[edge.v]
        labels.append(
            dict(
                x=(start[0] + end[0]) / 2,
                y=(start[1] + end[1]) / 2,
                text=str(edge.weight),
                showarrow=False,
                font=dict(size=11),
                bgcolor="white",
            )
        )
    return labels
