"""Plotting graphs with plotly.

Colours and marks follow the hand-drawn SVG figures used in the slides: terminals teal,
Steiner vertices orange, selected edges orange and thick, everything else a faint warm grey.
"""

from __future__ import annotations

from collections.abc import Iterable

import networkx as nx
import plotly.graph_objects as go

from steiner_graph.graph import Edge, Graph

Positions = dict[int, tuple[float, float]]

TERMINAL_FILL = "#E1F5EE"
TERMINAL_LINE = "#0F6E56"
TERMINAL_TEXT = "#085041"

STEINER_FILL = "#FAEEDA"
STEINER_LINE = "#854F0B"
STEINER_TEXT = "#633806"

TREE_COLOUR = "#BA7517"
EDGE_COLOUR = "#888780"
CLOSURE_COLOUR = "#B4B2A9"
LABEL_COLOUR = "#2C2C2A"

WEIGHT_COLOUR = "#3D5A80"
"""Edge weights get their own colour so they cannot be read as vertex numbers."""

FONT = "Helvetica, Arial, sans-serif"

TERMINAL_SIZE = 30
STEINER_SIZE = 26
TREE_WIDTH = 4.0
EDGE_WIDTH = 2.5

EDGE_OPACITY_PLAIN = 0.35
"""Edges carry the drawing when nothing is highlighted, so they stay readable."""

EDGE_OPACITY_BEHIND_TREE = 0.12
"""Once a tree is drawn, the remaining edges recede to context, as in the slide figures."""


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

    Terminals differ from the other vertices in colour and size, tree edges from the other
    edges in colour, width and opacity.
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
    edge_opacity = EDGE_OPACITY_BEHIND_TREE if tree else EDGE_OPACITY_PLAIN

    figure = go.Figure()
    figure.add_trace(
        _edge_trace(
            graph.edges - tree, positions, EDGE_COLOUR, EDGE_WIDTH, "edge", opacity=edge_opacity
        )
    )
    if tree:
        figure.add_trace(_edge_trace(tree, positions, TREE_COLOUR, TREE_WIDTH, "tree edge"))

    figure.add_trace(
        _vertex_trace(
            graph.vertices - terminals,
            positions,
            STEINER_FILL,
            STEINER_LINE,
            STEINER_TEXT,
            STEINER_SIZE,
            "Steiner vertex",
        )
    )
    if terminals:
        figure.add_trace(
            _vertex_trace(
                terminals,
                positions,
                TERMINAL_FILL,
                TERMINAL_LINE,
                TERMINAL_TEXT,
                TERMINAL_SIZE,
                "terminal",
            )
        )

    figure.update_layout(
        showlegend=True,
        hovermode="closest",
        font=dict(family=FONT, color=LABEL_COLOUR),
        margin=dict(l=20, r=20, t=30, b=20),
        plot_bgcolor="white",
        paper_bgcolor="white",
        xaxis=dict(visible=False),
        yaxis=dict(visible=False, scaleanchor="x"),
        annotations=_weight_labels(graph.edges, positions) if show_weights else [],
    )
    return figure


def _edge_trace(
    edges: Iterable[Edge],
    positions: Positions,
    colour: str,
    width: float,
    name: str,
    opacity: float = 1.0,
) -> go.Scatter:
    """One trace for a group of edges; `None` between segments breaks the line."""
    x: list[float | None] = []
    y: list[float | None] = []
    for edge in edges:
        start, end = positions[edge.u], positions[edge.v]
        x.extend([start[0], end[0], None])
        y.extend([start[1], end[1], None])
    return go.Scatter(
        x=x,
        y=y,
        mode="lines",
        line=dict(color=colour, width=width),
        opacity=opacity,
        name=name,
        hoverinfo="skip",
    )


def _vertex_trace(
    vertices: Iterable[int],
    positions: Positions,
    fill: str,
    outline: str,
    text_colour: str,
    size: int,
    name: str,
) -> go.Scatter:
    ordered = sorted(vertices)
    return go.Scatter(
        x=[positions[vertex][0] for vertex in ordered],
        y=[positions[vertex][1] for vertex in ordered],
        mode="markers+text",
        marker=dict(color=fill, symbol="circle", size=size, line=dict(color=outline, width=1.5)),
        text=[str(vertex) for vertex in ordered],
        textfont=dict(color=text_colour, family=FONT, size=18),
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
                text=f"<i>{edge.weight:g}</i>",
                showarrow=False,
                font=dict(size=17, family=FONT, color=WEIGHT_COLOUR),
                bgcolor="rgba(255,255,255,0.85)",
            )
        )
    return labels
