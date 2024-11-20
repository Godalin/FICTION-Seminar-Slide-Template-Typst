#import "@preview/touying:0.5.3": *
#import themes.simple: *

#let combind_logo = {
  box(image("./logos/zju_horizontal-logo.svg", height: 50pt))
  h(10pt)
  box(rect(height: 50pt, width: 2pt, stroke: 0pt, fill: black))
  h(10pt)
  box(pad(top: 5pt, bottom: 5pt,
    image("./logos/FICTION-logo.svg", height:40pt)))
}

#let seminar(
  title: "",
  subtitle: none,
  authors: (),
  date: none,
  outline_: true,
  body) = {

  set document(author: authors.map(a => a.name), title: title)
  set text(font: "Libertinus Serif", lang: "en")
  set par(justify: true)
  set page(background: place(right + top,
    dx: -10pt, dy: 10pt,
    context if here().page() != 1 {
      combind_logo
    }))

  show link: set text(fill: blue)

  show: simple-theme.with(
    aspect-ratio: "16-9",
    footer: [Open Source Software /
      #date / Zhejiang University])
  
  // Title row.
  title-slide[
    #v(2fr)
    = #title

    #(if subtitle != none {
      set text(size: 30pt, weight: "black")
      subtitle
    })

    #v(3fr)

    // Author information.
    #grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center)[
        Presenter: *#author.name*
      ])
    )
    #date

    #v(1fr)

    #combind_logo

    #v(1fr)
  ]

  // the outline slide
  if outline_ [
    #outline(title: [], indent: 1em, fill: [],
      target: heading.where(level: 2))
    ]

  // for the body
  body
}