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

FIGURE_DIR = Path("paper_sync/images/benchmarks")

EXACT_COLOUR = "#1b3a6b"
APPROXIMATION_COLOUR = "#e8590c"
GRID_COLOUR = "#eef1f4"
GUIDE_COLOUR = "#adb5bd"

COLOURS = {"exact": EXACT_COLOUR, "approximation": APPROXIMATION_COLOUR}

FONT_SIZE = 17
"""Plotly defaults to 12; the figures are scaled down in the paper, so they need more."""


def load(path: Path = CSV_PATH) -> pd.DataFrame:
    return pd.read_csv(path)


def predicted_operations(vertex_count: int, terminal_count: int) -> float:
    """Work the analysis predicts: Floyd, plus one spanning tree per enumerated subset."""
    steiner_count = vertex_count - terminal_count
    enumeration = sum(
        comb(steiner_count, i) * (terminal_count + i) ** 2 for i in range(terminal_count - 1)
    )
    return vertex_count**3 + enumeration


def _style(figure: go.Figure, x_title: str, y_title: str) -> go.Figure:
    """Axis titles and legend only.

    The figures carry no caption of their own: they are placed in the paper, where the
    caption is written in German next to the figure.
    """
    figure.update_layout(
        xaxis_title=x_title,
        yaxis_title=y_title,
        plot_bgcolor="white",
        font=dict(size=FONT_SIZE),
        margin=dict(l=90, r=30, t=60, b=80),
        legend=dict(orientation="h", yanchor="bottom", y=1.0, xanchor="left", x=0.0),
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
        # the exact algorithm was not run here; the caption says why
        figure.add_vrect(
            x0=min(missing) - 0.5,
            x1=max(missing) + 0.5,
            fillcolor=GUIDE_COLOUR,
            opacity=0.15,
            line_width=0,
        )

    figure.update_yaxes(type="log")
    return _style(
        figure,
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
        "predicted operations  n³ + Σ C(|S|,i)·k²  (log scale)",
        "seconds (log scale)",
    )


def quality_by_terminals(measurements: pd.DataFrame) -> go.Figure:
    """How much heavier the approximation is than the optimum, per instance.

    Taken from the terminal sweep, where the graph size is fixed, so that the trend along
    the axis is one of the terminal count alone. Every instance is drawn rather than an
    average, which keeps the outliers visible; the points are jittered horizontally because
    the terminal count is an integer and many instances sit at exactly 1.0, where they would
    otherwise hide each other.
    """
    sweep = _rows_of(measurements, "terminals")
    paired = sweep.pivot_table(
        index=["terminal_count", "seed"], columns="algorithm", values="weight"
    ).dropna()
    paired["ratio"] = paired["approximation"] / paired["exact"]
    paired = paired.reset_index()

    # the mean rather than the median: most instances are solved optimally, so the median
    # sits at exactly 1.0 for most terminal counts and shows no trend at all
    averages = paired.groupby("terminal_count", as_index=False)["ratio"].mean()
    jitter = np.random.default_rng(seed=0).uniform(-0.28, 0.28, len(paired))

    figure = go.Figure()
    figure.add_trace(
        go.Scatter(
            x=paired["terminal_count"] + jitter,
            y=paired["ratio"],
            mode="markers",
            name="single instance",
            marker=dict(color=APPROXIMATION_COLOUR, size=9, opacity=0.6),
            hovertemplate="r=%{x:.0f}, ratio=%{y:.3f}<extra></extra>",
        )
    )
    figure.add_trace(
        go.Scatter(
            x=averages["terminal_count"],
            y=averages["ratio"],
            mode="lines",
            name="mean of 5 instances",
            line=dict(color=EXACT_COLOUR, width=2),
        )
    )
    figure.add_hline(y=1.0, line=dict(color=GUIDE_COLOUR, dash="dash"))

    return _style(
        figure,
        "number of terminals r",
        "approximate weight / optimal weight",
    )


FIGURES = {
    "measured_against_prediction": measured_against_prediction,
    "runtime_by_vertices": runtime_by_vertices,
    "runtime_by_density": runtime_by_density,
    "runtime_by_terminals": runtime_by_terminals,
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
