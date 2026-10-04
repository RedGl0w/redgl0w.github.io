#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: diamond, cylinder
#import "../lib/template.typ": external

#let meta = (
  id: "comparing-cache-simulation",
  title: "Comparing cache simulation",
  date: datetime(year: 2026, month: 09, day: 19),
  path: "notes/2026-09-19-comparing-cache-simulation.html",
  summary: "During my internship in 2025, I tried to compare QEMU and gem5, two famous computer architecture simulators, in order to understand the origin of the differences they produce in their statistics during cache simulation.",
)

#let content = [
  = Why would we want to simulate cache ?
  There are a lot of reasons someone would want to simulate the cache of a system :
  - If you have ever attended a computer architecture lesson, you're very likely to have heard about the cache optimization that allows an important speedup for some algorithms. To do so, you want to have statistics about your cache usage during execution (such has number of hits and miss).You could do so using the #external("https://en.wikipedia.org/wiki/Hardware_performance_counter")[performance registers] of your CPU while executing the benchmark. However, this doesn't allow to change the cache size, associavity, structure, ... and some CPUs may not have these registers. Thus, it is pretty common to simulate the cache accesses during execution.
  - In the academic world, RISC-V has gained a lot of interest these last few years, because of its business model. Thus, a lot of studies (such as this internship) use RISC-V as the architecture for the experiment, but it is not easy to run RISC-V on real hardware, because of the rarity of RISC-V processors and systems, which requires simulation of the RISC-V architecture, which means that we can't use our host performance registers. Another very important reason to use cache simulators in academic world is also to run experiment on the memory hierarchy, and compare the impacts of the changes made for them. For instance, my internship tutor, #external("https://tima.univ-grenoble-alpes.fr/research/sls/members/dumas-julie")[Julie Dumas], and some other people in #external("https://tima.univ-grenoble-alpes.fr/research/madmax")[the laboratory] I was in are interested in cache coherency protocols, and all of their experiment requires them to write new protocol and check the performance results.

  If you run the same architecture, there are a lot of solution, such as #external("https://valgrind.org/docs/manual/cg-manual.html")[Cachegrind], but for other architecture, you will require complete architecture simulators that we will see next :

  = Our protagonists
  There are multiple different computer architecture simulator online; among them, two got my interest during this internship, for different reasons. Let's try to understand their pros and their cons.

  == gem5
  #external("https://www.gem5.org/")[gem5] is a simulator that is very popular in computer architecture academy, because it allows :
  - great fidelity in the simulation : gem5 is trying to reproduce the most it can the real way a processor work (without simulating the #external("https://en.wikipedia.org/wiki/Register-transfer_level")[RTL]), by using `SimObjects` which can represent cache, different CPU, memories, clocks, ...
  - simple modification and usage of the framework : all thos `SimObjects` are written in C++, and then are bound together within a #external("https://github.com/gem5/gem5/blob/f5c5a6e390f55dd5984977815bf9d0bd05da6945/configs/learning_gem5/part1/simple-riscv.py")[pyhon script] (named `config`) to create a specific system.

  I'm mentioned two times previously `SimObject`: this is a superclass of all simulated object, which can be clocked (through `ClockedObject`), and can have ports which allows communication between the `SimObject` where one object is a Requestor and the other is the Responder :

  // FIXME : align center and add padding + fix overlapping emoji
  #let height = 12
  #figure(diagram(
    // debug: 3,
    spacing: 1.5em,
    edge-stroke: .1em,
    label-size: 12pt,
    label-sep: 3pt,
    node((0, 0), [Requestor]),
    edge("->"),
    node((29, 0)),
    node((0, height), [Responder]),
    edge("->"),
    node((29, height)),

    edge((1, 0), (1, height), "->"),
    edge((2, height), (2, 0), "-->", [#emoji.checkmark.box]),
    edge((4, height), (4, 0), "->"),
    edge((5, 0), (5, height), "-->", [#emoji.checkmark.box], label-side: left),

    edge((9, 0), (9, height), "->"),
    edge((10, height), (10, 0), "-->", [#emoji.crossmark]),
    edge((12, height), (12, 0), "->", [#emoji.arrows.cycle], label-side: left, label-sep: -2pt),
    edge((13, 0), (13, height), "->"),
    edge((14, height), (14, 0), "-->", [#emoji.checkmark.box]),

    edge((18, 0), (18, height), "->"),
    edge((19, height), (19, 0), "-->", [#emoji.checkmark.box]),
    edge((21, height), (21, 0), "->"),
    edge((22, 0), (22, height), "-->", [#emoji.crossmark], label-side: left),
    edge((24, 0), (24, height), "->", [#emoji.arrows.cycle], label-sep: -2pt),
    edge((25, height), (25, 0), "->"),
    edge((26, 0), (26, height), "-->", [#emoji.checkmark.box], label-side: left),
  ), caption: [gem5 `SimObject` ports])

  The communication is based on an ACKnowledge system: when the requestor is requesting anything from the responder, three things can happen
  - Either the responder can answer, and the requestor is also available: the responder ACK the request, and then gives the answer to the requestor, which ACK too the answer.
  - Maybe the responder is not already available, and when the requestor will ask something, it will answer that it is not yet available. The requestor will then have to reschedule a "try again" answer a little bit later.
  - The same thing can happen the other way : maybe when the responder has its answer, the requestor is not anymore available. The requestor will then have to reschedule a "try again" answer too, in order for the responder to send again its answer.

  This is detailed more precisely within #external("https://www.gem5.org/documentation/learning_gem5/part2/memoryobject/")[gem5 tutorial].

  == QEMU
  QEMU on the other side is mainly focused on two goals : having a simulation that works, and its speed. To do so, one of its main feature is called #external("https://www.qemu.org/docs/master/devel/index-tcg.html")[Tiny Code Generation] (TCG): it is a #external("https://en.wikipedia.org/wiki/Binary_translation#Dynamic_binary_translation")[Dynamic Binary Translation] (DBT) framework.
  
  TCG uses an Intermediate Representation (IR) to allow executing any simulated Instruction Set Architecture (ISA) on any other host ISA, and it uses cache of previously translated Translation Blocks (sequence on instruction that finishes with jump/branches), to lower the overhead cost of translating too frequently :

  #let x86 = rgb("#036485")
  #let riscv = rgb("#758503")
  #let x86bg = x86.lighten(70%)
  #let riscvbg = riscv.lighten(70%)
  #let archgrad = gradient.linear(riscv, x86, relative: "self")
  #let archgradbg = gradient.linear(riscvbg, x86bg, relative: "self")
  #figure(diagram(
 	  node-stroke: .08em,
    spacing: 2.5em,
    node((1, 1), `Fetch`, fill: riscvbg, stroke: riscv),
    edge("-->"),
 	  node((1,0), [Target\ binary], shape: cylinder, fill: riscvbg, stroke: riscv),
    edge((1, 1), (2, 1), "->"),
    node((2, 1), `Decode`, fill: riscvbg, stroke: riscv),
    edge("->"),
    node((3, 1), `Branch?`, shape: diamond,  fill: riscvbg, stroke: riscv),
    edge("->", `Yes`),
    edge((3, 1), (1, 1), `No`, "->", bend:40deg, label-anchor: "south", label-sep: -5pt),
    node((4, 1), `TCG`, fill: archgradbg, stroke: archgrad),
    edge("->"),
    node((5, 1), `Execute`, fill: x86bg, stroke: x86),
    node((0, 0), [Known\ PC], shape: diamond),
    edge((0, 0), (1, 1), `No`, "->", label-sep: -5pt),
    node((0, 1), [TCG\ cache], shape: cylinder, fill: x86bg, stroke: x86),
    edge((0, 0), (0, 1), "-->"),
    edge((4, 1), (0, 1), `store`, "-->", bend:30deg, label-anchor: "south", label-sep: 0pt),
    edge((5, 1), (0, 1), "-->", bend: 33deg),
    edge((0, 0), "l,d,d,d,r,r,r,r,r,r,u,u", "->", `Yes`, label-pos: 12%, label-anchor: "west", label-sep: -7pt),
    edge((5, 1), "u,l,l,l,u,l,l,d", "->", `End of TB / Page fault / Interrupt`, label-pos: 31.5%, label-anchor: "north", label-sep: -7pt),
    node(enclose: ((4, -1), (6, -1)), `(Cache) plugins`, layer: 1, stroke: (dash: "dashed", paint: red), fill: red.lighten(80%)),
    edge((4, 1), (4.5, -1), "=>", bend: 15deg),
    edge((5, 1), (5, -1), "=>", bend: -15deg),
  ), caption: [DBT explained within TCG of QEMU]) <DBT>

  On @DBT, we can also notice that TCG has implemented a #external("https://www.qemu.org/docs/master/devel/tcg-plugins.html")[plugin system] : it allows `C` code to be compiled into dynamic library, which will be loaded when QEMU starts, and can register hooks to different part of QEMU internals, such as :
  - start/stop/reset of QEMU
  - Translation of blocks : depending of the translated instruction, we can hook different callbacks
  - Executing an instruction : when an instruction is executed, we can intercept it, and intercept its memory access

  QEMU has a few #external("https://github.com/qemu/qemu/tree/master/contrib/plugins")[integrated plugins], such as #external("https://github.com/qemu/qemu/blob/master/contrib/plugins/ips.c")[limiter of Instruction-per-Second], #external("https://github.com/qemu/qemu/blob/master/contrib/plugins/lockstep.c")[`git bisect` like execution], and the one which will gain our interest : #external("https://github.com/qemu/qemu/blob/master/contrib/plugins/cache.c")[cache simulation].

  This previous cache simulation plugin is great, but is has a very important slowdown due to the very frequent callback which are pretty slow with the cache simulation. Marie Badaroux proposed in 2023 another way to #external("https://hal.science/hal-04131264/document")[simulate cache], which compute cache interaction during the translation of the blocks, instead of computing them on each executed instruction.

  = Simulation environment
  Both of these simulators can run in quite different ways :
  - Bare Metal : we can compile our benchmarks to run directly on the hardware without any abstraction. We must include in the binary a #external("https://en.wikipedia.org/wiki/Crt0")[`crt0`] to initialize hardware, memory and registers.
  - Full System simulation : we must compile a linux kernel with some basic tools within the disk image (we chose busybox), and add our benchmarks compiled for linux which will run on it too.
  #figure(diagram(
    //debug: 3,
 	  node-stroke: .05em,
    spacing: 4em,
    node((0, 1), [Binary], shape: cylinder, name: <binary>, stroke: riscv, fill: riscvbg),
    node((-1, 1), [Busybox], shape: cylinder, name: <busybox>, stroke: riscv, fill: riscvbg),
    //node((-1, 1), [Disk], shape: cylinder, name: <disk>),
    node(enclose: (<binary>, <busybox>), name: <diskFS>,
        stroke: teal, fill: teal.lighten(90%),
        snap: -1, inset: 17pt),
    node((-0.5,2), [Kernel], shape: cylinder, name: <kernelFS>, stroke: riscv, fill: riscvbg),
    node(enclose: (<diskFS>, <kernelFS>), name: <linuxFS>,
        stroke: orange, fill: orange.lighten(90%), 
        snap: -2, inset: 15pt, layer: -2),
    node((1, 1.3), [
      Linux \
      Full System
    ], stroke: none),
    edge(<linuxFS>, (0, 0), "-->"),
    node((-1,0), [
      binary
    ], shape: cylinder, name: <bareFS>, stroke: riscv, fill: riscvbg),
    node((-1, -0.5), "Bare metal", stroke: none),
    node(enclose: (<bareFS>,), name: <bareFStotal>,
        stroke: purple, fill: purple.lighten(90%),
        snap: -1, inset: 15pt),
    edge(<bareFStotal>, (0,0), "-->"),
    node((0, 0), `Fetch`, stroke: riscv, fill: riscvbg),
    edge("->"),
    node((1, 0), `Decode`, stroke: riscv, fill: riscvbg),
    edge("->"),
    node((2, 0), [
      Translate \
      (or execute)
    ], stroke: archgrad, fill: archgradbg),
    edge("u,l,l,d", "->"),
  ), caption: [Bare metal and Full System simulation])
  - Syscall Emulation : instead of simulating the whole OS to run the linux benchmark, we can intercept the syscall the benchmark does to interface it with the kernel that is running on the host, in order to improve performances
  #figure(diagram(
    // debug: 3,
 	  node-stroke: .05em,
    spacing: 2.5em,
    node((-1, 1), [FileSystem], shape: cylinder),
    edge((-1, 1), (0, 0), "-->"),
    node((-1,0), [Binary], shape: cylinder, stroke: riscv, fill: riscvbg),
    edge("-->"),
    node((0, 0), `Fetch`, stroke: riscv, fill: riscvbg),
    edge("->"),
    node((1, 0), `Decode`, stroke: riscv, fill: riscvbg),
    edge("->"),
    node((2, 0), `ecall?`, shape: diamond, stroke: riscv, fill: riscvbg),
    edge("->", `no`),
    node((3, 0), [
      Translate \
      (or execute)
    ], stroke: x86, fill: x86bg),
    edge("u,l,l,l,d", "->"),
    edge((2, 0), (2, 1), "->", `yes`),
    node((2, 1), [
      Gen jump in QEMU \
      (or execute in gem5)
    ], stroke: x86, fill: x86bg),
    edge("l,l,u", "->", `after execution`, label-pos: 37%),
  ), caption: [Syscall emulation])

  On these simulators, we chose to run two different benchmarks :
  - #external("https://github.com/embench/embench-iot")[Embench-iot] is a small, minimal requirement benchmark, made for embedded platforms. Thus, it doesn't require any stdlib, and when all benchmark are linked together, it is $approx 180 "kB"$ in text and $approx 60 "kB"$ in data/rodata/bss, with strong spacial locality
  - #external("https://en.wikipedia.org/wiki/Princeton_Application_Repository_for_Shared-Memory_Computers")[PARSEC] is a benchmark made especially for shared memory system (which is usefull for manycore systems). It is built for linux, and each benchmark is $>= 45 "kB"$ in text and $>= 50 "kB"$ in data/rodata/bss.

  = Already found origin of differences
  // https://theses.hal.science/tel-04720001
  
  This article is not yet finished. Coming soon :p
]
