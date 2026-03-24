# NTUA Presentation Framework

This repository provides a reusable LaTeX Beamer framework for NTUA presentations, together with shared theme components, branding hooks, and slide-level macros.

The current setup is designed around:
- shared NTUA branding and layout under `latex/framework/ntua-beamer/`
- per-deck sources under `latex/<deck>/`
- final exported PDFs under `presentations/`
- intermediate LaTeX artifacts under `latex/<deck>/.build/`
- generated distribution bundles under `dist/`

## Purpose

The repo is meant to support a growing collection of presentation decks with:
- a consistent NTUA visual identity
- reusable Beamer helpers such as column layouts, logo placement, and frame-local references
- clean separation between source, build artifacts, and final deliverables

## Layout

```text
.
├── Makefile
├── latex/
│   ├── framework/
│   │   └── ntua-beamer/
│   │       ├── assets/
│   │       ├── ntuabeamer.cls
│   │       ├── ntuabeamer.sty
│   │       ├── macros.tex
│   │       └── theme.tex
│   ├── gnns/
│   └── example/
├── dist/
└── presentations/
```

Key directories:
- `latex/framework/ntua-beamer/`: shared class, package, internal theme implementation, and framework-default assets
- `latex/<deck>/main.tex`: one deck per folder
- `dist/`: generated modular and standalone framework bundles
- `presentations/`: final PDFs intended to be kept

## Quick Start

Create a new deck under `latex/<deck>/main.tex`:

```tex
\documentclass[10pt,aspectratio=169]{ntuabeamer}

\title{My Presentation}
\subtitle{Optional subtitle}
\author{NTUA School of Civil Engineering}
\date{\today}

\begin{document}

\begin{frame}[plain]
  \makepresentationtitle
\end{frame}

\begin{frame}{Example}
  \twocols{%
    Left content
  }{%
    Right content
  }
\end{frame}

\end{document}
```

Then build it with:

```bash
latexmk latex/<deck>/main.tex
```

The live-build PDF will be written to:

```text
latex/<deck>/.build/main.pdf
```

If you also want an exported copy in `presentations/`, use:

```bash
make <deck>
```

## Build Workflow

The default workflow is plain `latexmk`:

```bash
latexmk latex/gnns/main.tex
latexmk latex/example/main.tex
```

This writes the live build into the source directory’s local `.build/` folder:
- aux files: `latex/<deck>/.build/`
- live-build PDF: `latex/<deck>/.build/main.pdf`

Each deck also carries a tiny local `.latexmkrc` that forwards to the repo policy and cleans up stray top-level artifacts if `latexmk` is run from inside the deck directory.

The `make` targets are only optional export helpers for this repo:

```bash
make gnns
make example
```

They copy the already-built local PDF into:
- `presentations/<deck>.pdf`

Generate reusable framework bundles with:

```bash
make dist-framework
```

This creates:
- `dist/ntuabeamer-modular/`
- `dist/ntuabeamer-standalone/ntuabeamer.cls`

## TeX IDEs

If you compile a deck directly from an IDE such as TeXstudio using its default `pdflatex` command, it may place artifacts next to the source file or fail to resolve the framework class.

Recommended approaches:
- configure the IDE to call `latexmk`, not raw `pdflatex`
- or compile from the terminal with `latexmk latex/<deck>/main.tex`
- or use `make <deck>` only when you want an exported copy in `presentations/`

For PDF preview in editors such as VSCode LaTeX Workshop, the robust file to open is the local deck output:
- `latex/<deck>/.build/main.pdf`

That keeps normal editor workflows working without any deck registry or export step.

## Shared API

The shared theme exposes two kinds of API:
- author-facing commands that you use directly in slide content
- deck-tuning lengths and hooks that you override in each deck’s `main.tex`

### Primary Entry Point

Deck authors should start from the framework class:

```tex
\documentclass[10pt,aspectratio=169]{ntuabeamer}
```

Everything else is passed through to normal `beamer`, for example `aspectratio=169`.

### Class vs Package

The framework intentionally has both a class and a package:
- `ntuabeamer.cls`: the public entry point for deck authors. This is what a deck uses in `\documentclass{ntuabeamer}`. It is a thin shell over `beamer`.
- `ntuabeamer.sty`: the implementation package loaded by the class. It brings in the framework defaults and loads the internal implementation files.
- `macros.tex` and `theme.tex`: internal framework implementation files. Deck authors should not normally import these directly.

Architecturally, the class is the user-facing shell and the package is the reusable implementation layer behind it.

### Using the Framework Outside This Repo

There are two supported reuse modes.

#### 1. Standard modular install

In modular mode, the `.cls` file alone is not enough. The class depends on:
- `ntuabeamer.cls`
- `ntuabeamer.sty`
- `macros.tex`
- `theme.tex`
- logo assets

The easiest source for that bundle is:
- `dist/ntuabeamer-modular/`

Install it into the user TeX tree discovered by TeX itself:

```bash
kpsewhich -var-value=TEXMFHOME
```

Copy the contents of `dist/ntuabeamer-modular/` into:

```text
<TEXMFHOME>/tex/latex/ntuabeamer/
```

If your TeX distribution needs a filename database refresh, run:

```bash
mktexlsr
```

This is the standard TeX-native workflow on Linux, macOS, and Windows. The exact install location stays OS-agnostic because TeX itself tells you where `TEXMFHOME` is.

#### 2. Standalone convenience mode

If you want the simplest possible reuse, copy only:
- `dist/ntuabeamer-standalone/ntuabeamer.cls`

Place it next to your deck’s `main.tex`, then use:

```tex
\documentclass{ntuabeamer}
```

The standalone file compiles without repo-relative dependencies. If no default logos are present, it simply omits them.

There are three reasonable ways to use the framework elsewhere:

1. Install the modular bundle in `TEXMFHOME`
2. Copy the standalone class next to a deck
3. Keep the full framework in a repo and compile with `latexmk`

Best practice is either:
- install the framework in a local/user `texmf` tree if you want system-wide reuse, or
- keep the framework as a versioned folder/submodule inside the repo if you want project-local reuse.

Add only deck-specific packages after that, for example:

```tex
\usepackage{physics}
```

If a deck wants `.bib` support, load `biblatex` in the normal way:

```tex
\usepackage[backend=biber,style=ieee]{biblatex}
\addbibresource{references.bib}
```

In other words:
- the class controls presentation layout
- the deck controls bibliography packages and bibliography style
- the framework macros then work on top of whichever normal `biblatex` setup the deck chose

### Author-Facing Commands

Title page:
- `\makepresentationtitle`
- `\sectiondivider{<title>}` for centered section-break slides with the standard frame chrome

Logo placement hooks:
- `\logotopleft{...}`
- `\logotopright{...}`
- `\logobottomright{...}`

Default logo render hooks:
- `\insertntuamainlogo`
- `\insertschoollogo`
- `\insertgrouplogo`
- `\insertheaderlogo`
- `\ntuabeamerassetpath`

Layout helpers:
- `\twocols[<w1>][<w2>]{<left>}{<right>}`
- `\threecols[<w1>][<w2>][<w3>]{<c1>}{<c2>}{<c3>}`

Frame-local references:
- `\defineslidesource{<key>}{<source>}`
- `\slideref{<key>}`
- standard `biblatex` commands such as `\addbibresource{...}` and `\printbibliography`

Math helpers:
- `\bd{...}` for bold mathematical objects

### Column Helpers

Balanced two-column split:

```tex
\twocols{%
  Left content
}{%
  Right content
}
```

Custom-width two-column split:

```tex
\twocols[0.58\textwidth][0.38\textwidth]{%
  Left content
}{%
  Right content
}
```

Balanced three-column split:

```tex
\threecols{%
  A
}{%
  B
}{%
  C
}
```

Custom-width three-column split:

```tex
\threecols[0.22\textwidth][0.34\textwidth][0.34\textwidth]{%
  A
}{%
  B
}{%
  C
}
```

### Section Divider

Use this when a deck wants a visual break between major blocks without creating a custom slide layout:

```tex
\sectiondivider{Message Passing}
```

The helper uses a normal frame with the standard NTUA title bar and footer, but keeps the slide body minimal by centering only the section title.

### Frame-Local References

There are two supported citation paths.

#### 1. Inline slide sources

Use this when you want a lightweight source without a `.bib` file:

Define sources once near the top of the deck:

```tex
\defineslidesource{kipf2017}{Kipf, Welling. \emph{Semi-Supervised Classification with Graph Convolutional Networks}. ICLR, 2017.}
\defineslidesource{hamilton2017}{Hamilton, Ying, Leskovec. \emph{Inductive Representation Learning on Large Graphs}. NeurIPS, 2017.}
```

Use them inside a frame:

```tex
Graph convolution\slideref{kipf2017} and GraphSAGE\slideref{hamilton2017}
can appear on the same slide.
```

#### 2. Imported `.bib` sources

Use this when the deck already has a normal bibliography file:

```tex
\usepackage[backend=biber,style=numeric,sorting=none]{biblatex}
\addbibresource{references.bib}
```

Then cite BibTeX keys with the same slide-local command:

```tex
Graph convolution\slideref{kipf2017}
```

You can also keep a traditional bibliography slide:

```tex
\begin{frame}{References}
  \printbibliography[heading=none]
\end{frame}
```

Behavior:
- numbering resets on every frame
- repeated use of the same key on the same frame reuses the same number
- references appear in the footer of that frame only

Resolution order for `\slideref{key}` is:
- first, a matching inline `\defineslidesource{key}{...}`
- otherwise, a matching `biblatex` entry from `\addbibresource{...}`

This means a deck can mix both styles. For example:

```tex
\defineslidesource{internal-note}{Internal benchmark note, 2026.}
\usepackage[backend=biber,style=ieee]{biblatex}
\addbibresource{references.bib}
```

and then on a slide:

```tex
Internal result\slideref{internal-note}, published method\slideref{kipf2017}
```

This keeps the usual bibliography workflow available without giving up the inline convenience API. `\printbibliography` remains available for decks that want a traditional references slide.

### Bibliography Style Choice

The framework does not force a bibliography package or style.

If a deck wants bibliography support, the deck should load `biblatex` itself in the normal LaTeX way, for example:

```tex
\usepackage[backend=biber,style=authoryear]{biblatex}
```

or:

```tex
\usepackage[backend=biber,style=ieee,sorting=nyt]{biblatex}
```

That is the cleaner architecture here. It keeps the class focused on presentation layout, while bibliography configuration remains a deck-level concern, just like in plain `beamer`.

### Deck-Level Customization

Deck-specific sizing and layout tuning should be done in each deck’s `main.tex` before `\begin{document}`.

Typical example:

```tex
\setlength{\ntuamaintitlelogoheight}{2.0cm}
\setlength{\schooltitlelogoheight}{1.4cm}
\setlength{\grouptitlelogoheight}{0.95cm}
\setlength{\headerlogoheight}{1.0cm}
\setlength{\footpagenumberwidth}{1.6cm}
```

Default logo assets are owned by the shared theme under `latex/framework/ntua-beamer/assets/`. A deck does not need to set any logo path unless it wants to override the defaults.

### Tunable Lengths

You can control sizes and spacing through these shared lengths.

Title-page logo positions:
- `\titlelogoleftinset`
- `\titlelogorightinset`
- `\titlelogotopinset`
- `\titlelogobottominset`

Title-page block spacing:
- `\titleblocktopskip`

Logo sizes:
- `\ntuamaintitlelogoheight`
- `\schooltitlelogoheight`
- `\grouptitlelogoheight`
- `\headerlogoheight`

Header layout:
- `\headerlogoboxwidth`
- `\headercontentheight`

Footer layout:
- `\footlineleftinset`
- `\footlinerightinset`
- `\footpagenumberwidth`

These are overridden with normal LaTeX length assignments such as:

```tex
\setlength{\headerlogoheight}{1.05cm}
\setlength{\headerlogoboxwidth}{1.55cm}
\setlength{\footlinerightinset}{0.30cm}
```

### Overriding Logo Hooks

If a deck wants different assets or a different composition, it can redefine the logo render hooks in `main.tex`.

Example:

```tex
\renewcommand{\insertheaderlogo}{%
  \includegraphics[height=\headerlogoheight]{latex/mydeck/assets/my-other-logo.pdf}%
}
```

The placement hooks can also be reused if you want a custom title-page composition:

```tex
\renewcommand{\inserttitlelogos}{%
  \begin{tikzpicture}[remember picture,overlay]
    \logotopleft{\insertntuamainlogo}
    \logobottomright{\insertgrouplogo}
  \end{tikzpicture}%
}
```

### Slide Canvas

If you want to change the actual slide aspect ratio or base font size, do that in the document class line, not through the shared theme lengths.

Example:

```tex
\documentclass[10pt,aspectratio=169]{ntuabeamer}
```

Common aspect ratios:
- `aspectratio=169`
- `aspectratio=43`

## Example Deck

The canonical starter deck is:
- `latex/example/main.tex`

It is intentionally documented with short inline comments showing:
- where to change metadata
- where to override theme lengths
- how to override default logos
- how to use the column helpers
- how to define and cite frame-local references
