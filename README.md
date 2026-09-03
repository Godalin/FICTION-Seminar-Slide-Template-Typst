# FICTION Seminar Slides Template in Typst by Linyu

## PTree seminar deck

`main.typ` contains the Chinese FICTION seminar presentation for PTree.
Build the reviewed PDF with:

```sh
typst compile main.typ ptree-seminar.pdf
```

The deck cites the neighboring PTree repository files in Touying speaker
notes.  It is designed for the template's original 4:3 aspect ratio.

Regular slide bodies are vertically centered by default while slide titles
remain top-aligned. For a deliberately top-aligned body, pass
`content-valign: top` to `seminar.with(...)`. The combined ZJU/FICTION logo
keeps its original hand-tuned page position; title and header widths are
constrained so they do not enter the logo area.

This is a personal template for FICTION Slides.

It can also be used elsewhere.
