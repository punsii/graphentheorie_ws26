"""Figures built from the benchmark CSV.

Nothing here runs an algorithm, so plots can be restyled without measuring again.
"""

from __future__ import annotations

from math import comb
from pathlib import Path

import numpy as np
import pandas as pd
import plotly.graph_objects as go

from steiner_graph.benchmark import CSV_PATH

FIGURE_DIR = Path("results")

EXACT_COLOUR = "#1b3a6b"
APPROXIMATION_COLOUR = "#e8590c"
GRID_COLOUR = "#eef1f4"
GUIDE_COLOUR = "#adb5bd"

COLOURS = {"exact": EXACT_COLOUR, "approximation": APPROXIMATION_COLOUR}


def load(path: Path = CSV_PATH) -> pd.DataFrame:
    return pd.read_csv(path)


def predicted_operations(vertex_count: int, terminal_count: int) -> float:
    """Work the analysis predicts: Floyd, plus one spanning tree per enumerated subset."""
    steiner_count = vertex_count - terminal_count
    enumeration = sum(
        comb(steiner_count, i) * (terminal_count + i) ** 2 for i in range(terminal_count - 1)
    )
    return vertex_count**3 + enumeration


def _style(figure: go.Figure, caption: str, x_title: str, y_title: str) -> go.Figure:
    """Axis titles, legend above the plot, caption underneath it.

    The caption sits below the plot like a figure caption in a paper, and has to say on its
    own what is shown and what the symbols mean.
    """
    lines = caption.count("<br>") + 1

    figure.update_layout(
        xaxis_title=x_title,
        yaxis_title=y_title,
        plot_bgcolor="white",
        margin=dict(l=70, r=30, t=50, b=70 + 19 * lines),
        legend=dict(orientation="h", yanchor="bottom", y=1.0, xanchor="left", x=0.0),
    )
    figure.add_annotation(
        text=caption,
        xref="paper",
        yref="paper",
        x=0.0,
        y=-0.16,
        xanchor="left",
        yanchor="top",
        align="left",
        showarrow=False,
        font=dict(size=13),
    )
    figure.update_xaxes(gridcolor=GRID_COLOUR, zeroline=False)
    figure.update_yaxes(gridcolor=GRID_COLOUR, zeroline=False)
    return figure


def _rows_of(measurements: pd.DataFrame, sweep: str) -> pd.DataFrame:
    """The rows belonging to one sweep."""
    return pd.DataFrame(measurements[measurements["sweep"] == sweep])


def _median_by(measurements: pd.DataFrame, column: str) -> pd.DataFrame:
    """Median runtime per parameter value, which is what the curves show."""
    return pd.DataFrame(
        measurements.groupby(["algorithm", column], as_index=False)["seconds"].median()
    )


def runtime_by_terminals(measurements: pd.DataFrame) -> go.Figure:
    """Runtime against the number of terminals, the axis the exact algorithm struggles with."""
    sweep = _rows_of(measurements, "terminals")
    medians = _median_by(sweep, "terminal_count")
    vertex_count = int(sweep["vertex_count"].iloc[0])

    measured = sorted(set(sweep["terminal_count"]))

    figure = go.Figure()
    for algorithm, rows in medians.groupby("algorithm"):
        # reindex over every terminal count, so skipped points become gaps in the line
        # instead of being bridged by one that looks measured
        seconds = rows.set_index("terminal_count")["seconds"].reindex(measured)
        figure.add_trace(
            go.Scatter(
                x=measured,
                y=seconds,
                mode="lines+markers",
                name=algorithm,
                line=dict(color=COLOURS[str(algorithm)], width=2),
                marker=dict(size=8),
                connectgaps=False,
            )
        )

    missing = sorted(
        set(sweep["terminal_count"]) - set(sweep[sweep["algorithm"] == "exact"]["terminal_count"])
    )
    if missing:
        figure.add_vrect(
            x0=min(missing) - 0.5,
            x1=max(missing) + 0.5,
            fillcolor=GUIDE_COLOUR,
            opacity=0.15,
            line_width=0,
            annotation_text="too large to solve exactly",
            annotation_position="top left",
        )

    figure.update_yaxes(type="log")
    return _style(
        figure,
        "<b>Runtime of the exact algorithm and of the 2-approximation</b><br>"
        "<b>against the number of terminals</b><br>"
        f"<sub>Random graphs with n={vertex_count} vertices and edge probability p=0.3.<br>"
        "r = number of terminals the tree has to connect; points are medians of 5 graphs.<br>"
        "The exact algorithm is missing where it would enumerate more than 60,000 subsets."
        "</sub>",
        "number of terminals r",
        "seconds (log scale)",
    )


def runtime_by_vertices(measurements: pd.DataFrame) -> go.Figure:
    """Runtime against graph size, with the fitted exponent of each curve."""
    sweep = _rows_of(measurements, "vertices")
    medians = _median_by(sweep, "vertex_count")

    figure = go.Figure()
    # set the scales first: shapes added to a linear axis keep their coordinates when the
    # axis later turns logarithmic, which reinterprets them as exponents
    figure.update_xaxes(type="log")
    figure.update_yaxes(type="log")

    for algorithm, rows in medians.groupby("algorithm"):
        slope, intercept = np.polyfit(np.log(rows["vertex_count"]), np.log(rows["seconds"]), 1)

        figure.add_trace(
            go.Scatter(
                x=rows["vertex_count"],
                y=rows["seconds"],
                mode="markers",
                name=f"{algorithm} (measured)",
                marker=dict(color=COLOURS[str(algorithm)], size=9),
            )
        )
        figure.add_trace(
            go.Scatter(
                x=rows["vertex_count"],
                y=np.exp(intercept) * rows["vertex_count"] ** slope,
                mode="lines",
                name=f"{algorithm}: fitted exponent {slope:.2f}",
                line=dict(color=COLOURS[str(algorithm)], width=2, dash="dash"),
            )
        )

    return _style(
        figure,
        "<b>Runtime against graph size, at 4 terminals and edge probability 0.3</b><br>"
        "<sub>n = number of vertices; points are medians of 5 random graphs per size.<br>"
        "Dashed lines are power law fits over all points. The analysis predicts exponent 3<br>"
        "for the exact algorithm, since it computes all-pairs shortest paths.</sub>",
        "number of vertices n (log scale)",
        "seconds (log scale)",
    )


def runtime_by_density(measurements: pd.DataFrame) -> go.Figure:
    """Runtime against edge probability; the analysis predicts almost no effect."""
    sweep = _rows_of(measurements, "density")
    medians = _median_by(sweep, "edge_probability")

    figure = go.Figure()
    for algorithm, rows in medians.groupby("algorithm"):
        figure.add_trace(
            go.Scatter(
                x=rows["edge_probability"],
                y=rows["seconds"],
                mode="lines+markers",
                name=algorithm,
                line=dict(color=COLOURS[str(algorithm)], width=2),
                marker=dict(size=8),
            )
        )

    figure.update_yaxes(type="log")
    return _style(
        figure,
        "<b>Runtime against how densely the graph is connected, at fixed size</b><br>"
        "<sub>p = probability that a given pair of vertices is joined by an edge, so p=1 is<br>"
        "the complete graph. Random graphs with n=20 vertices and r=5 terminals; points<br>"
        "are medians of 5 graphs. The exact algorithm is flat because it works on the<br>"
        "all-pairs distance matrix, whose size depends on the vertex count alone.</sub>",
        "edge probability p",
        "seconds (log scale)",
    )


def measured_against_prediction(measurements: pd.DataFrame) -> go.Figure:
    """Measured runtime against predicted work, which should be a straight line."""
    exact = pd.DataFrame(measurements[measurements["algorithm"] == "exact"]).copy()
    exact["predicted"] = [
        predicted_operations(int(n), int(r))
        for n, r in zip(exact["vertex_count"], exact["terminal_count"], strict=True)
    ]

    fitted = exact
    log_predicted = np.log(fitted["predicted"])
    log_seconds = np.log(fitted["seconds"])
    slope, intercept = np.polyfit(log_predicted, log_seconds, 1)
    residuals = log_seconds - (slope * log_predicted + intercept)
    r_squared = 1 - residuals.var() / log_seconds.var()

    figure = go.Figure()
    figure.add_trace(
        go.Scatter(
            x=exact["predicted"],
            y=exact["seconds"],
            mode="markers",
            name="single run",
            marker=dict(color=EXACT_COLOUR, size=7, opacity=0.5),
        )
    )
    ordered = fitted.sort_values("predicted")
    figure.add_trace(
        go.Scatter(
            x=ordered["predicted"],
            y=np.exp(intercept) * ordered["predicted"] ** slope,
            mode="lines",
            name=f"power law fit: exponent {slope:.2f}, R²={r_squared:.3f}",
            line=dict(color=APPROXIMATION_COLOUR, width=2, dash="dash"),
        )
    )

    figure.update_xaxes(type="log")
    figure.update_yaxes(type="log")
    return _style(
        figure,
        "<b>Measured runtime of the exact algorithm against the work its analysis predicts</b><br>"
        "<sub>One point per run, pooled over all sweeps. Predicted work is n³ for the<br>"
        "all-pairs shortest paths plus one spanning tree per enumerated subset, with<br>"
        "n = vertices, r = terminals, |S| = n−r Steiner vertices, i = subset size and<br>"
        "k = r+i vertices per spanning tree. A fitted exponent of 1 would mean the<br>"
        "analysis explains the measured runtime exactly.</sub>",
        "predicted operations  n³ + Σ C(|S|,i)·k²  (log scale)",
        "seconds (log scale)",
    )


def quality_by_terminals(measurements: pd.DataFrame) -> go.Figure:
    """How much heavier the approximation is, wherever the optimum is known."""
    paired = measurements.pivot_table(
        index=["sweep", "vertex_count", "terminal_count", "edge_probability", "seed"],
        columns="algorithm",
        values="weight",
    ).dropna()
    paired["ratio"] = paired["approximation"] / paired["exact"]
    paired = paired.reset_index()

    figure = go.Figure()
    figure.add_trace(
        go.Scatter(
            x=paired["terminal_count"] + np.random.uniform(-0.15, 0.15, len(paired)),
            y=paired["ratio"],
            mode="markers",
            name="instance",
            marker=dict(color=APPROXIMATION_COLOUR, size=8, opacity=0.55),
        )
    )
    figure.add_hline(y=1.0, line=dict(color=GUIDE_COLOUR, dash="dash"))
    figure.add_annotation(
        x=paired["terminal_count"].max(), y=1.0, text="optimum", showarrow=False, yshift=-12
    )

    optimal = (paired["ratio"] == 1.0).mean()
    return _style(
        figure,
        "<b>How much heavier the 2-approximation is than the optimal Steiner tree</b><br>"
        f"<sub>One point per instance, {len(paired)} instances pooled over all sweeps and<br>"
        "jittered horizontally so that equal values stay visible. r = number of terminals.<br>"
        f"A ratio of 1.0 means the approximation found an optimal tree ({optimal:.0%} of<br>"
        "instances); the algorithm guarantees at most 2.0.</sub>",
        "number of terminals r",
        "approximate weight / optimal weight",
    )


FIGURES = {
    "runtime_by_terminals": runtime_by_terminals,
    "runtime_by_vertices": runtime_by_vertices,
    "runtime_by_density": runtime_by_density,
    "measured_against_prediction": measured_against_prediction,
    "quality_by_terminals": quality_by_terminals,
}


def main() -> None:
    measurements = load()
    FIGURE_DIR.mkdir(parents=True, exist_ok=True)

    for name, build_figure in FIGURES.items():
        path = FIGURE_DIR / f"{name}.png"
        build_figure(measurements).write_image(path, width=900, height=540)
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
