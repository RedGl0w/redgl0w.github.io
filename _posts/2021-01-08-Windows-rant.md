---
layout: post
title: "How Windows almost drove me crazy."
comments: true
---

I recently started working on some personal C++ projects, to finally really get used to it. C++ is a great language, and my projects worked well under GNU/Linux... But then I decided to make everything work under windows (and I regret).

## Context : My usual setup

![Windows 10](/images/2021-01-08-Windows-rant/eclipse.jpg)

I normally use the Eclipse IDE, on Arch Linux, with the GNOME desktop environment. Something most people in the GNU/Linux community consider very heavy and bloated. Keep that in mind.

## MinGW

My first idea was to use MinGW to cross-compile everything to Windows, I just have to install it from the AUR, and I'm good to go, right ? Well, no. First, I dared to use BSD sockets in one of my libraries (we'll talk about that later) but the biggest problem was that MinGW isn't really how you're supposed to compile for windows, it's just GCC with all the Windows libs + cross-compiled GNU/Linux libs that outputs PE binaries. MinGW also requires you to either static link to the libc or to ship literally 5 DLLs with your executable, which is really not a good idea when you consider the average Windows user doesn't even know what a DLL is and why it matters. So I took a different approach.

## The OS itself

Being a naive GNU/Linux user that didn't use Windows for like 2 years I hoped that things had changed since I removed it from my computer. No, nothing. I originally started with a Windows 10 Professional install disc, but after installing I realized that Microsoft still includes a fuck ton of bloatware (I'm looking at you, Edge and Cortana). Who seriously needs a shitty voice assistant which is constantly spying on you and a chromium ripoff, seriously ?

### Making a de-bloated VM

After that very bad first impression, I discovered something called Windows 10 LTSC. It is basically the holy grail for users like me. A stable, LTS, Windows 10 image, without all the bloat. Microsoft is only giving this to some companies, for really specific purposes (embedded systems, but who the heck would use Windows 10 on an embedded system anyway ?). I managed to _very legally_ get my hand on an installation ISO for that thing. After creating my VM and installing it, it works great, except...

### The look and feel of Windows 10

![Windows 10](/images/2021-01-08-Windows-rant/win10.jpg)

Oh, god. This is where it really starts hurting. I have too many questions about this image. It feels familiar yet so different. Too many things are wrong about that picture. Why is the system theme dark, but some dialogs are light ? Why is the bottom bar so thicc ? Why the heck are the windows controls on the right ? Why does the OS + Visual Studio (more on that later too) weighs almost 30 GB ? Why is the taskbar on the bottom ? Why can't I create tabs in the file explorer ?

Don't get me wrong, some of those issues can be fixed with tweaks and black magic (putting the taskbar on the left + reducing its size with a tweak works well enough) but this should be addressed by Microsoft. All of these issues have been fixed in every major GNU/Linux DE a decade ago. My GTK theme applies on EVERYTHING, why isn't Windows coherent about light / dark mode, especially on system dialogs like the property dialog shown here ?

## Actual programming

These were the issues from a user point of view, now let's take a look at what I'm actually interested in : programming.

### Visual Studio

![Windows 10](/images/2021-01-08-Windows-rant/vs.jpg)

On my GNU/Linux system, I use an IDE that a lot of people consider bloated to the bone (Eclipse). Let me tell you Eclipse is NOTHING compared to VS. First, installing it. This thing is heavy (4 GB). I'm so glad I have fiber internet. In comparison, eclipse weighs 70 MB. VS is literally 58x heavier than one of the heaviest IDEs you can find on GNU/Linux, but it doesn't end there.

Opening a project is a pain. For context, I use CMake for my build system. I either have to generate a vsproj from CMake or open the folder in VS and tell it to use CMake. The first method doesn't show all source files and regroups them by target (not ideal) and with the second method the autocompletion doesn't work properly, so what do I do ? Well I accept it and deal with it, because that's what MS wants me to do. Moving on.

### MSVC vs. The World

Next, I had to deal with MSVC...

#### It doesn't just work

I had SO MANY dumb issues with MSVC, it is the worst compiler I had to deal with in years. My code was designed with GCC in mind, but also compiled and worked fine with CLang, but MSVC just wouldn't take it. When I first ran it, literally nothing managed to build without errors due to some weird nonsense about nested namespaces. I had to rewrite more than 30 headers to make my code work, and I wasn't even done.

#### Randomly calling the destructor

One of my classes was a socket wrapper. I made it follow the RAII pattern, meaning the constructor would call `socket` and the destructor would call `close`. When passing the object around with GCC and CLang, it worked. No issues, the socket was still kept open. MSVC on the other hand would call the move constructor and then the destructor. I literally spent four hours on that issue, smashing my head on the wall, trying to understand why my socket was closed, only to realize I had to implement the move constructor and put an invalid socket descriptor after moving it, because that stupid compiler didn't want to be coherent with GCC, CLang and even the C++ standards.

### Sockets

Microsoft has somewhat ported the BSD socket API to windows, to make it easier to port GNU/Linux apps to it. They managed to fuck that up too.

#### WSAStartup, WSACleanup

Why ? Why do I need a function to request a core system functionality when I purposefully linked against a library to get it ? Why can't the OS just initialize that at the first socket call and raise a flag telling to itself that it has to clean when the program stops ? Am I asking for too much ?

#### Non-blocking sockets non-sense

In my app, I used a non-blocking server socket. The BSD socket API tells you that every socket created, either by `socket` or by `accept` will be blocking. Windows managed to fuck that up too. When you accept a connection from a non-blocking server socket, the resulting socket is... non-blocking. It's not like the code to make it blocking by default isn't there, WSASocketA does it, but Microsoft just decided that "fuck it, let's be different". YOU ALREADY HAVE YOUR DUMB WIN32 API FOR THAT YOU MORONS, don't bother GNU/Linux developers who are trying to port software to your platform for fuck's sake !

#### No SIGPIPE

This is more of a convenience thing than anything else, but Windows doesn't support the SIGPIPE signal, which can be really useful in some programs, and at some point I actually used it. Well, I guess I'll just deal with it.

### Package management

Basically, there isn't. Microsoft has released somewhat of a package manager (VCpkg, greatly inspired by GNU/Linux package managers), but it is a pain to use and isn't included by default. Installing it is a pain, you have to put it at the root of your C:\ drive, using it is a pain (the command line argument aren't anything like either Windows commands nor GNU/Linux commands) and even Visual Studio (let me remind you that it's Microsoft's own IDE) has trouble working with it. I ended up having to ship the sources of ZLib with my project. Nice.

## Conclusion

I think I've said enough, I will never make the mistake of trying to port anything to Windows again, especially if it involves any form of networking or user interface. The worst part is, people are actually using this thing. This OS is getting worse as time goes by, but developers and users alike are still using Windows. I have some friends who write C++ on Windows with VS on a daily basis, and they even dare to tell me that eclipse is heavy (coucou Pierre). Do these people hate themselves ? Why are they doing that ? Writing this article leaves me with even more questions than before...

