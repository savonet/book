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
- margin=20mm
- marginparwidth=15mm
default-image-extension: ".pdf"
fontfamily: libertine
implicit_figures: no
subparagraph: yes
header-includes: |
  \usepackage{style}
  \usepackage{cleveref}
  \usepackage{makeidx}\makeindex
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

!include "workflow.md"

!include "video.md"

!include "streaming.md"

<!-- !include "faq.md" -->

<!-- !include "reference.md" -->

<!-- !include "conclusion.md" -->

!include "bibliography.md"

!include "index.md"
