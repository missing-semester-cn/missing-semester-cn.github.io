---
layout: lecture
title: "OS Customization"
presenter: Anish
video:
  aspect: 62.5
  id: epSRVqQzeDo
---

There is a lot you can do to customize your operating system beyond what is
available in the settings menus.

# Keyboard remapping

Your keyboard probably has keys that you aren't using very much. Instead of
having useless keys, you can remap them to do useful things.

## Remapping to other keys

The simplest thing is to remap keys to other keys. For example, if you don't
use the caps lock key very much, then you can remap it to something more
useful. If you are a Vim user, for example, you might want to remap caps lock
to escape.

On macOS, you can do some remappings through Keyboard settings in System
Preferences; for more complicated mappings, you need special software.

## Remapping to arbitrary commands

You don't just have to remap keys to other keys: there are tools that will let
you remap keys (or combinations of keys) to arbitrary commands. For example,
you could make command-shift-t open a new terminal window.

# Customizing hidden OS settings

## macOS

macOS exposes a lot of useful settings through the `defaults` command. For
example, you can make Dock icons of hidden applications translucent:

```shell
defaults write com.apple.dock showhidden -bool true
```

There is no single list of all possible settings, but you can find lists of
specific customizations online, such as Mathias Bynens'
[.macos](https://github.com/mathiasbynens/dotfiles/blob/master/.macos).

# Window management

## Tiling window management

[Tiling window management](https://en.wikipedia.org/wiki/Tiling_window_manager)
is one approach to window management, where you organize windows into
non-overlapping frames. If you're using a Unix-based operating system, you can
install a tiling window manager; if you're using something like Windows or
macOS, you can install applications that let you approximate this behavior.

## Screen management

You can set up keyboard shortcuts to help you manipulate windows across
screens.

## Layouts

If there are specific ways you lay out windows on a screen, rather than
"executing" that layout manually, you can script it, making instantiating a
layout trivial.

# Resources

- [Hammerspoon](https://www.hammerspoon.org/) - macOS desktop automation
- [Rectangle](https://rectangleapp.com/) - macOS window manager
- [Karabiner](https://karabiner-elements.pqrs.org/) - sophisticated macOS keyboard remapping
- [r/unixporn](https://www.reddit.com/r/unixporn/) - screenshots and
documentation of people's fancy configurations

# Exercises

1. Figure out how to remap your Caps Lock key to something you use more often
   (such as Escape or Ctrl or Backspace).

1. Make a custom global keyboard shortcut to open a new terminal window or a
   new browser window.

{% comment %}

TODO

- Bitbar / Polybar
- Clipboard Manager (stack/searchable history)

{% endcomment %}
