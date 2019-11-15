## vim does not approve of your compass spriting

Compass provides a really cool way to generate sprites from a directory full of images - [http://compass-style.org/help/tutorials/spriting/](http://compass-style.org/help/tutorials/spriting/). This is pretty much all it takes:

```scss
@import "my-icons/*.png";
@include all-my-icons-sprites;
```

Unfortunately for Vim users, part of the first line is confused to be the beginning of a CSS comment :\

![bad syntax](/images/posts/20130629/bad_syntax.png)

This obviously won't do. Lucky for us, editing the logic of Vim's syntax highlighting logic is pretty easy. [Scriptease.vim](https://github.com/tpope/vim-scriptease) provides some cool commands that help deal with runtime files. `:Vedit` is the one we need here.

```bash
:Vedit syntax/sass.vim
```

Search for this line:

```bash
syn region sassInclude start="@import" end=";\|$" contains=scssComment,cssURL,cssUnicodeEscape,cssMediaType
```

Change it to this:

```bash
syn region sassInclude start="@import" end=";\|$" contains=cssURL,cssUnicodeEscape,cssMediaType
```

Basically the `scssComment` syntax match statement is the problem. Remove it and your SCSS files with Compass Spriting look like they should :D

![good syntax](/images/posts/20130629/good_syntax.png)
