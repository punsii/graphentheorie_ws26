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

## _Team member_

_To be filled in by the author._

| Phase                 | AI use |
| --------------------- | ------ |
| Research              |        |
| Project idea, outline |        |
| Source code           |        |
| Test cases            |        |
| Algorithms            |        |
| Slides                |        |
| Paper                 |        |
