---
title: The Liquidsoap book
author:
- Romain Beauxis
- Samuel Mimram
lang: en-US
documentclass: book
geometry:
- paperwidth=6in
- paperheight=9in
- margin=22mm
- marginparwidth=15mm
fontfamily: libertine
subparagraph: yes
header-includes: |
  \usepackage[varqu,scaled=.9]{inconsolata}
  \usepackage[Bjornstrup]{fncychap}
  \usepackage{fvextra}
  \RecustomVerbatimEnvironment{verbatim}{Verbatim}{breaklines}
  \usepackage{cleveref}
  \usepackage{titlesec}
  `\titleformat{\subsection}[runin]{\normalfont\normalsize\bfseries}{\thesubsection}{1ex}{}[.]`{=latex}
  \titlespacing*{\subsection}{0pt}{3.25ex plus 1ex minus .2ex}{1ex}
  \newcommand{\TODO}[1]{\marginpar{\tiny #1}}
  \newcommand{\SM}[1]{\TODO{SM: #1}}
  \newcommand{\RB}[1]{\TODO{RB: #1}}
numbersections: true
secnumdepth: 1
toc-depth: 1
toc: true
...

!include "introduction.md"

!include "technology.md"

!include "installation.md"

!include "helloworld.md"

!include "language.md"

!include "workflow.md"

!include "advanced.md"

!include "cookbook.md"

!include "video.md"

!include "plugins.md"

!include "faq.md"

!include "internals.md"

!include "reference.md"

!include "conclusion.md"

!include "bibliography.md"
