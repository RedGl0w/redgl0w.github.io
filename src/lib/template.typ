#import "config.typ": nav, site

#let row(margin: none, class: "", body) = html.div(
  class: ("row " + class).trim(),
  {
    html.div(class: "margin", if margin != none { margin } else { [] })
    html.div(class: "body", body)
  },
)

#let external(url, body) = html.a(href: url, rel: "noopener", target: "_blank", body)

#let up(path) = "../" * (path.split("/").len() - 1)

#let header(current) = html.header(class: "top", {
  html.span(class: "wordmark", link(label("home"), site.name))
  html.nav(
    aria-label: "Site pages",
    nav
      .map(p => if p.id == current {
        html.span(class: "here", link(label(p.id), p.title))
      } else {
        html.span(link(label(p.id), p.title))
      })
      .join(),
  )
})

#let footer() = html.footer(class: "foot", {
  if site.links.len() > 0 {
    html.p(site.links.map(l => external(l.url, l.name)).join(", ") + [. Built with Typst.])
  } else {
    html.p[Built with Typst.]
  }
})

#let emit(path, id: "", title: none, description: "", current: "", body) = [
  #document(
    path,
    title: if title == none { site.name } else { title + " · " + site.name },
    description: description,
    author: site.name,
  )[
    #html.html(lang: "en", {
      html.head({
        html.meta(charset: "utf-8")
        html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
        html.title(if title == none { site.name } else { title + " · " + site.name })
        html.meta(name: "description", content: description)
        html.link(rel: "stylesheet", href: up(path) + "style.css")
      })
      html.body({
        header(current)
        html.main(class: "sheet", {
          show heading.where(level: 2): it => html.h2(it.body)
          show heading.where(level: 3): it => html.h3(it.body)
          show heading.where(level: 4): it => html.h4(it.body)
          show figure: it => html.frame(it)
          body
        })
        footer()
      })
    })
  ]
  #label(id)
]

#let note(meta, body) = {
  row(
    margin: html.time(datetime: meta.date, meta.date.display()),
    class: "note-head",
    {
      html.h1(meta.title)
      if meta.summary != "" { html.p(class: "standfirst", meta.summary) }
    },
  )
  row(body)
  row(html.p(class: "back", link(label("home"))[Back to the home page]))
}
