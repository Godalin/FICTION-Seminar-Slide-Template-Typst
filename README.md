# FICTION Seminar Slides Template in Typst by Linyu

## PTree seminar deck

`main.typ` contains the Chinese FICTION seminar presentation for PTree.
Build the reviewed PDF with:

```sh
typst compile main.typ ptree-seminar.pdf
```

The deck cites the neighboring PTree repository files in Touying speaker
notes.  It is designed for the template's original 4:3 aspect ratio.

Regular slide bodies are vertically centered by default. For a deliberately
top-aligned deck, pass `content-valign: top` to `seminar.with(...)`. Slide
titles and the combined ZJU/FICTION logo share the template header row, so
long titles are constrained before reaching the logo.

This is a personal template for FICTION Slides.

It can also be used elsewhere.
