---
layout: post
title: "tmux ist rad"
date: 2013-05-05 20:06
comments: true
categories: [tmux, vim, bash, osx]
---

Since I started using vim, productivity tools have become really exciting to me. I'm not talking about Office or crap like that - I mean command line based tools that feel like vim. A lot of these tools are vim plugins and some just implement functionality based on vim conventions (most importantly navigation).

A more general disipline that vim encourages is mouse-free development. Using a pointing device in addition to your keyboard is considered an anti-pattern. It's frustrating at first but when you get the hang of it, it's really fun, you think about text and your editor more creatively, and your speed and efficiency begins to increase at a pace that would be tough to match using a click dependent IDE of some sort. Also worth mentioning is a consequent skill boost over ssh.

The only prerequisite for running vim is a terminal. Terminal and iTerm are the only two I'm familiar with on OSX. Both are great applications, but iTerm lets you do really cool stuff with panes. You can focus the different panes by clicking on the one you want or by using `command [` & `command ]` to cycle through them. They can also resize by clicking and dragging pane borders.

{% img /images/posts/20130505/iterm_panes.png %}

This approach kept me happy for a long time. But it turns out that this functionalty is actually an interpretation of another tool - tmux. It's like when you hear a song, love it, and find out it's a cover of a classic. So I did what I think most people would do - go check out the classic: TMUUUUXXX.

Right off the bat I saw "tmux is a terminal multiplexer", and thought "wtf, I don't know what that means, but it sounds awesome". I immediately started to try to incorporate it in my workflow, had some fun, but couldn't quite get to a point where I was completely comfortable. So I abandoned ship - went back to iTerm.

A month later, I was looking for new reading material on [http://pragprog.com](http://pragprog.com) and I came across Brian P. Hogan's book, [tmux](http://pragprog.com/book/bhtmux/tmux), and downloaded a copy. This book got me in. It covers quite a bit so it took a while to filter what I wanted tmux to do for me and what I didn't. What I wanted was panes, windows, and sessions to feel like vim. What I didn't want is a ton of configuration overhead - I figured this out by trying some wild session templates using bash and Tmuxinator shown in the book. It's not for me.

Like, vim, tmux has a configuration file where you can do some really fine-grain customizations. My .tmux.conf can be viewed here: [https://github.com/trotttrotttrott/.files/blob/master/.tmux.conf](https://github.com/trotttrotttrott/.files/blob/master/.tmux.conf). The following configuration settings are what really made tmux work for me:

* make it feel like vim:
```bash
# moving between panes
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

```bash
# enable vi keys.
setw -g mode-keys vi
```

* make clipboard stuff work as it would outside of a tmux session:
```bash
# Allow use of unnamed clipboard in vim and stuff
set-option -g default-command 'reattach-to-user-namespace -l bash'
```

This requires you to install `reattach-to-user-namespace`. This article helped me understand: [http://robots.thoughtbot.com/post/19398560514/how-to-copy-and-paste-with-tmux-on-mac-os-x](http://robots.thoughtbot.com/post/19398560514/how-to-copy-and-paste-with-tmux-on-mac-os-x).

* Use control+space instead of control+b as prefix:
```bash
# Use C-space of C-b as prefix
set -g prefix C-space
unbind C-b
bind C-space send-prefix
```

I found C-b to be kind of awkward. C-a is a popular alternative as it's what [screen](http://www.gnu.org/software/screen/) uses, but C-a also jumps to the beginning of a line in bash. There's no way I'm going to sacrifice C-a in bash. So I landed on C-space. It doesn't collide with any other shortcuts (that I'm aware of) and it allows me to keep my right hand on the home row so I'm ready to bang on my primary vim navigation keys: `h`, `j`, `k`, & `l`.

I've got quite a bit of other configuration, but the rest is not quite as crucial to productivity. I do like pretty color schemes though, so this is a good trick to help pick custom colors:

```bash
#! /bin/bash

# show 256 terminal colors
for i in {0..255} ; do
  printf "\x1b[38;5;${i}mcolour${i}\n"
done
```

So now iTerm is out of my life, Terminal is back, and tmux is a key player.

{% img /images/posts/20130505/tmux_panes.png %}

{% img /images/posts/20130505/tmux_panes_vim.png %}
