# AI usage

Written while the work is ongoing.

## Paul Menhart

### Tools used

| Tool                      | Model                     |
| ------------------------- | ------------------------- |
| Web chat (Gemini, Claude) | various                   |
| Claude Code (agent, CLI)  | Claude Opus 5, 1M context |

### Usage

| Phase                 | AI use                                                                           |
| --------------------- | -------------------------------------------------------------------------------- |
| Research              | Clarifying questions in a web chat app                                           |
| Project idea, outline | None                                                                             |
| Source code           | AI agents used to help create the scaffolding.                                   |
| Test cases            | AI agents used to create the tests                                               |
| Algorithms            | Written by hand (`floyd`, `prim`, `steiner`), AI added docstrings and tests      |
| Slides                | AI helped in the creation of SVG vector graphics                                 |
| Paper                 | Structure and content by hand, AI agent drafted prose for some parts based on it |

The outline and the architecture of the code was created by hand. AI agents were used to help create the
scaffolding around the algorithms: graph types, instance generators, plotting, project tooling and tests.
None of the code written by AI was accepted without reading the code and large parts of it were rejected,
renamed or simplified by hand. The core algorithms, which are the subject of the presentation,
were written by hand and AI was used only to add docstrings and tests.
The creation and editing of git commits was done by hand.

The slides were created almost entirely by hand. AI was used to help with the creation of SVG vector graphics
based on visual examples which were designed manually.

For the paper, the outline, the section structure and the content of each section were written by hand.
On that basis an AI agent drafted the German prose of some sections, while others were drafted by hand (~50/50).
Afterwards all sections were reviewed, corrected and iterated on by hand.
The measurements reported in the paper were produced by the implementation described above and interpreted manually.
In the final step AI was used to review, point out duplicate text, fix spelling mistakes and double check the citations.

### Kinds of instructions and questions

- Instructions: which parts to build and which to leave to me, followed by corrections to
  naming, data structures, code style and test scope.
- Questions: how the individual steps of the algorithm work, and checks of claims about the
  choice and complexity of its subroutines.

## Julius Greppmair

### Tools used

Webchat with Anthropic Claude and ChatGPT models.
AI agent using Claude Code by Anthropic (VS Code extension).

### Usage

| Phase                 | AI use                                                                                          |
| --------------------- | ----------------------------------------------------------------------------------------------- |
| Research              | clarifying questions in a web chat app                                                          |
| Project idea, outline | None                                                                                            |
| Source code           | AI agent used for the experiment code in `steiner_eukledean.ipynb` (benchmark, plots, data loading) |
| Test cases            | AI agent used to create the tests and the validation against the OR-Library optima              |
| Algorithms            | Written by hand (full topologies, Melzak, DP over subsets); Debugging with AI fixed degenerate cases, added counters, length bound and the MST + 120° heuristic |
| Slides                | SVGs created with Claude                                                                        |
| Paper                 | Rewording and Proofreading                                                                      |

The exact algorithm for the Euclidean Steiner tree problem was written by hand: generating
all full Steiner topologies, the Melzak construction including the reconstruction of the
Steiner points, and the dynamic program that combines full subtrees into the optimal tree.
The Claude Code agent was used to refactor this code for the experiments,
benchmark and the plots. The agent found a bug in the original code in which degenerate
cases produced `nan` and were accepted as valid trees.
None of the AI-generated code was accepted without reading it
The creation and editing of git commits was done by hand.

### Kinds of instructions and questions

- Instructions: which measurements the paper needs, keeping the code small and close to the original notebook, and plotting in the
  notebook instead of separate scripts.
- Questions: which code changes follow from the planned paper section, whether the results
  are complete, how to run the heuristic on the larger OR-Library instances

