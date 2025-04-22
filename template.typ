// main theme
#import "@preview/touying:0.6.1": *
#import themes.simple: *

// theorems
#import "@preview/theorion:0.3.2": *
#import cosmos.fancy: *

// the logo
#let combined_logo = {
  box(image("./logos/zju_horizontal-logo.svg", height: 40pt))
  h(10pt)
  box(rect(height: 40pt, width: 2pt, stroke: 0pt, fill: black))
  h(10pt)
  box(pad(top: 5pt, bottom: 5pt,
    image("./logos/FICTION-logo.svg", height:30pt)))
}

#let seminar(
  title: "",
  subtitle: none,
  authors: (),
  date: none,
  outline_: true,
  body
) = {

  set document(author: authors.map(a => a.name), title: title)

  show heading.where(level: 2): []

  set text(font: "Libertinus Serif", lang: "en")
  set par(justify: true)

  // set the background
  set page(background: place(right + top,
    dx: -10pt, dy: 10pt,
    context if here().page() != 1 {
      combined_logo
    }))

  show outline: set heading(level: 2)
  show bibliography: set heading(level: 2)
  show link: set text(fill: blue)

  show figure: set align(center)

  show: simple-theme.with(
    aspect-ratio: "4-3",
    footer: [FICTION Seminar /
      #date / Zhejiang University],

    // freeze the theorem counter
    config-common(frozen-counters: (theorem-counter,)),
  )

  // theorems
  show: show-theorion

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

    #combined_logo

    #v(1fr)
  ]

  // the outline slide
  if outline_ {
    slide[
      #set align(horizon)
      #outline(indent: 1em, title: "Outline",
        target: heading.where(level: 2))
    ]
  }

  // for the body
  body
}



// theorem functions
#let citation(lab, supplement: none) = {
  set text(size: 14pt, fill: gray)
  cite(lab, form: "full", style: "springer-basic",
    supplement: supplement)
}
