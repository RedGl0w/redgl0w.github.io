// -----------------------------------------------------------------------------
// The single entry point of the site. One compilation produces the whole
// bundle:
//
//   typst compile --features bundle,html --format bundle src/site.typ dist
//
// Every #document is an output file, every label a link target.
// -----------------------------------------------------------------------------

#import "lib/template.typ": emit, note
#import "lib/config.typ": site
#import "posts/all.typ": notes
#import "pages/home.typ"
#import "pages/cv.typ"

#set text(lang: "en")

#emit(
  "index.html",
  id: "home",
  description: site.name + ", " + site.status + ".",
  current: "home",
  home.content,
)

#emit(
  "cv.html",
  id: "cv",
  title: "CV",
  description: "Education, projects, teaching and talks of " + site.name + ".",
  current: "cv",
  cv.content,
)

// One file per note. There is no index page: the list on the home page is the
// only way in, which is what keeps the site small.
#for n in notes {
  emit(
    n.meta.path,
    id: n.meta.id,
    title: n.meta.title,
    description: n.meta.summary,
    current: "home",
    note(n.meta, n.content),
  )
}

// All static files
#asset("style.css", read("/static/style.css", encoding: none))
#asset("static/2025-madmax/paper.pdf", read("/static/2025-madmax/paper.pdf", encoding: none))
#asset("static/2025-madmax/slides.pdf", read("/static/2025-madmax/slides.pdf", encoding: none))
#asset("static/2026-taran/paper.pdf", read("/static/2026-taran/paper.pdf", encoding: none))
#asset("static/2026-taran/slides.pdf", read("/static/2026-taran/slides.pdf", encoding: none))
