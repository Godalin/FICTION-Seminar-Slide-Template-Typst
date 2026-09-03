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
  content-valign: horizon,
  body
) = {

  set document(author: authors.map(a => a.name), title: title)

  show heading.where(level: 2): []

  set text(font: ("Libertinus Serif", "Songti SC"), lang: "zh")
  set par(justify: true)

  show outline: set heading(level: 2)
  show bibliography: set heading(level: 2)
  show link: set text(fill: blue)

  show figure: set align(center)

  // Keep regular slide bodies visually balanced. Dense decks can opt out with
  // `content-valign: top` when calling `seminar`.
  let seminar-slide(
    config: (:),
    repeat: auto,
    setting: body => body,
    composer: auto,
    ..bodies,
  ) = slide(
    config: config,
    repeat: repeat,
    setting: body => setting(align(content-valign, body)),
    composer: composer,
    ..bodies,
  )

  show: simple-theme.with(
    aspect-ratio: "4-3",
    // Title and logo share a header row, preventing overlap. The padding also
    // moves both away from the top edge.
    header: self => pad(top: 8pt)[
      #utils.display-current-heading(
        setting: utils.fit-to-width.with(grow: false, 100%),
        level: 1,
        depth: self.slide-level,
      )
    ],
    header-right: pad(top: 8pt)[#combined_logo],
    footer: [FICTION Seminar /
      #date / Zhejiang University],

    // freeze the theorem counter
    config-common(frozen-counters: (theorem-counter,)),
    config-common(slide-fn: seminar-slide),
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
