---
title: The Liquidsoap book
author:
- Samuel Mimram
- Romain Beauxis
lang: en-US
documentclass: book
geometry:
- paperwidth=6in
- paperheight=9in
- margin=20mm
- marginparwidth=15mm
fontfamily: libertine
implicit_figures: no
replace-headers: no
subparagraph: yes
header-includes: |
  \usepackage{style}
  \usepackage{cleveref}
  \usepackage{makeidx}\makeindex
  \usepackage{titlepic}
  \titlepic{\vspace{3cm}\includegraphics[width=3cm]{img/logo.pdf}\vspace{-3cm}}
  \usepackage{perpage}\MakePerPage{footnote}
numbersections: true
secnumdepth: 1
toc-depth: 1
toc: true
...

!include "introduction.md"

!include "technology.md"

!include "installation.md"

!include "quickstart.md"

!include "language.md"

!include "audio.md"

!include "video.md"

!include "streaming.md"

<!-- !include "faq.md" -->

!include "bibliography.md"

!include "index.md"
