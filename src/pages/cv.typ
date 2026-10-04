#import "../lib/template.typ": external, row
#import "../lib/config.typ": site

#let entry(period, title, place, body) = row(margin: period, class: "entry")[
  #html.h3(title)
  #if place != [] {
    html.p(class: "where", place)
  }
  #body
]

#let content = [
  #row[== Education]

  #entry(
    [2026-2027],
    [#external("https://informatique.ens-rennes.fr/formation/deuxieme-annee-m1-sif")[Master 1 in computer science (M1 SIF)]],
    [Ecole Normale Supérieur of Rennes (ENS Rennes)],
  )[
    #link(label("M1Project"))[M1 research project], #external("https://team.inria.fr/pacap/members/isabelle-puaut/#teaching")[Operating Systems (SEA)], Bio-informatics, #external("https://mquinson.frama.io/ensr-hpc/")[High Performance Computation], #external("https://mquinson.frama.io/ensr-methodo/")[research methodology], English, ...
  ]

  #entry(
    [2025-2026],
    [#external("https://informatique.ens-rennes.fr/formation/premiere-annee-l3-sif")[Licence 3 in computer science (L3 SIF)]],
    [Ecole Normale Supérieur of Rennes (ENS Rennes)],
  )[
    - CS : Computer architecture, #external("https://mquinson.frama.io/ensr-arcsys1/")[C/network], #external("https://mquinson.frama.io/ensr-cpp/")[C++], #external("https://people.irisa.fr/David.Baelde/prog/index.html")[OCaml/lambda-calculus], #external("https://people.irisa.fr/David.Baelde/logique/index.html")[logic], Turing machines, Distributed Algorithms
    - Mathematics : Optimisation, Finite fields, probability and statistics, ...
    - Other : English, #external("https://mquinson.frama.io/ensr-methodo/")[teaching methodology], ...
  ]

  #entry(
    [2024-2025],
    [#external("https://ensimag.grenoble-inp.fr/fr/formation/offre-de-formation-1a#page-presentation")[First year in computer science engineering school]],
    [Ecole Nationale Supérieure d'Informatique et de Mathématiques Appliqués de Grenoble (ENSIMAG), Grenoble],
  )[
    -  CS : Computer architecture (writing RISC-V 32bit VHDL processor, RISC-V assembly), Python, C, Network, Cybersecurity, Operational Research, ...
    - Mathematics : Lebesgue Integral, Fourrier Transform, Information Theory, Probabilities, Statistics, Digital analysis, ...
    - Other : English, German, Economy, environmental transition, ...
  ]

  #entry(
    [2022-2024],
    [#external("https://en.wikipedia.org/wiki/Classe_pr%C3%A9paratoire_aux_grandes_%C3%A9coles")[CPGE] MP2I/MPI\*],
    [#external("https://www.lyc-descartes.fr/mpi/")[Lycée Descartes], Tours]
  )[
    Maths, Computer science, physics, english

    Research project (TIPE) : #external("https://en.wikipedia.org/wiki/Hex_(board_game)")[Hex game] ; theorical considerations, algorithm playing and solving it
  ]

  #entry(
    [2019-2022],
    [#external("https://en.wikipedia.org/wiki/Baccalaur%C3%A9at")[Baccalauréat général]],
    [Lycée Montesquieu, Le Mans]
  )[
    Obtained in 2022 with high honours (Mention Très Bien)
    - Specialities : Mathematics, Physics and Computer Science 
    - English and German as second/third languages
    - Options : expert mathematics, ancient greek and cinema
  ]

  #row[== Internships]

  #label("M1Project") // TODO move to the entry
  #entry(
    [2026-2027],
    [Research project during Master 1],
    [#external("https://team.inria.fr/pacap/")[PACAP \@ INRIA Rennes], 1 day / week during the whole year],
  )[
    #external("https://people.irisa.fr/Martin.Quinson/Teaching/Projet-M1/26-Simon-Rokicki.pdf")[Subject:] improving in-Order performances through speculation with HW/SW codesign\
    Supervisor: #external("https://people.irisa.fr/Simon.Rokicki/")[Simon Rokicki]

    Abstract: we want to add on a small in-Order CPU branch, value and memory-dependency prediction/speculation. However, we want to be able to control it thanks to a modified ISA, in order to improve the physical complexity/costs, while trying to keep or improve good performances. In a first time, we did focus on branch prediction, and especially specifying different branch predictors for different branching.
  ]

  #entry(
    [2026],
    [Summer research Internship],
    [#external("https://team.inria.fr/taran/")[TARAN \@ INRIA Rennes], 11 weeks],
  )[
    Subject: study origin of differences between in-Order and Out-of-Order CPU and implement in High-Level-Synthsis a superscalar RISC-V in-Order processor\
    Supervisor: #external("https://people.irisa.fr/Simon.Rokicki/")[Simon Rokicki]

    Abstract: during this internship, I studied the origin of differences in performances between in-Order CPU and Out-of-Order ones (cf. #external("https://www.irisa.fr/alf/downloads/PMA/p241-mcfarlin.pdf")[McFarlin's article]), by learning a lot about in-Order and VLIW CPUs and the techniques used with them (speculation on in-Order machines, such as `ld.as` on Itanium, software pipelining, ...). Next to this, I started implementing an in-Order CPU that would incorporate these ideas in the future, by modifying #external("https://gitlab.inria.fr/srokicki/Comet")[Comet], a High-Level-Synthesis CPU written in C++ to make it superscalar.

    Check #link("static/2026-taran/paper.pdf")[internship report] or #link("static/2026-taran/slides.pdf")[slides].
  ]

  #entry(
    [2025],
    [Engineer assistant internship in laboratory],
    [#external("https://tima.univ-grenoble-alpes.fr/research/madmax")[MADMAX \@ TIMA (INRIA Grenoble)], 10 weeks],
  )[
    Subject: track down the origin of differences of RISC-V manycore cache simulators\
    Supervisor: #external("https://tima.univ-grenoble-alpes.fr/research/sls/members/dumas-julie")[Julie Dumas]

    Abstract : QEMU and gem5 are two great computer architecture for different reasons (fidelity of simulation for gem5, speed of simulation, especially for manycore systems for QEMU). Recently, QEMU got a plugin system allowing it to easily run cache simulation on top of it. However, these two simulators give different results on the same benchmarks, which is the problematic of this internship.

    Check #link(label("comparing-cache-simulation"))[blog post], #link("static/2025-madmax/paper.pdf")[internship report] or #link("static/2025-madmax/slides.pdf")[slides].
  ]

  #row[== Personnal projects]

  #entry(
    [2020-],
    [#external("https://www.numworks.com/")[NumWorks] calculator (#external("https://github.com/numworks/epsilon")[Epsilon], #external("https://getomega.dev/")[Omega])], []
  )[
    Contributed to Epsilon, official firmware of the NumWorks calculator, and helped creating a fork called Omega targetting power users.\
    Written firstly as a monolithic C/C++ bare metal firmware, it changed with time to a really simple bootloader/kernel/userland division to allow third party application in userland without being able to control the exam LED.\
    Including a home-made Computer Algebra System (poincare) with tokenizer/lexer/AST simplification and micropython.
    
    TODO : blog post ?
  ]

  #row(margin: [Misc])[
    == Skills
    French (native), English C1, German (B1)\
    Low level : C, C++, RISC-V, VHDL\
    Systems/networks : NixOS, Archlinux, Mikrotik, debian-based dists\
    Documents writing : Typst, LaTeX\
    Tools : Makefile, git, bases of bash, ...\
    Other languages : OCaml, Python, and R, Ruby\
    Web : Javascript, Typescript, HTML, PHP
  ]
]
