#import "../lib/template.typ": row
#import "../lib/config.typ": site
#import "../posts/all.typ": notes

#let content = [
  #row(margin: [])[
    == In short

    I'm #site.name, a 22-year french computer science student at ENS Rennes. I'm mainly interested in computer architecture, and more precisely in microarchitecture. I would like to pursue an academic career in the future.
  ]

  #row(margin: [Notes])[
    == Blogs
    These are a collection of small blog posts, mostly written for myself, but take a look if you want to.
  ]

  #for n in notes {
    row(
      margin: html.time(datetime: n.meta.date, n.meta.date.display()),
      class: "note-link",
      {
        html.h3(link(label(n.meta.id), n.meta.title))
        html.p(n.meta.summary)
      },
    )
  }

]
