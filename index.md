---
layout: page
title: The Missing Semester of Your CS Education
---

**Note: this site is under construction for the 2020 offering of this IAP class.**

Learn to make the most of the tools that
[hackers](https://en.wikipedia.org/wiki/Hacker_culture) have been using for
decades.

As hackers, we spend a lot of time on our computers, so it makes sense to make
that experience as fluid and frictionless as possible. In this class, we’ll
help you learn how to make the most of tools that productive programmers use.

We’ll show you how to navigate the command line, use a powerful text editor,
use version control efficiently, automate mundane tasks, manage packages and
software, configure your desktop environment, and more.

## Topics

Click on specific topics below to see lecture videos and lecture notes.

<ul>
{% for lecture in site.data.lectures %}
{% for topic in lecture.topics %}
    <li><a href="{{ topic.url }}">{{ topic.title }}</a></li>
{% endfor %}
{% endfor %}
</ul>

## About the class

**Staff**: This class is co-taught by [Anish](https://www.anishathalye.com/), [Jon](https://thesquareplanet.com/), and [Jose](http://josejg.com/).  
**Questions**: Email us at [missing-semester@mit.edu](mailto:missing-semester@mit.edu).

## Beyond MIT

We've also shared this class beyond MIT in the hopes that others may
benefit from these resources. You can find posts and discussion on

 - [`/r/hackertools`](https://www.reddit.com/r/hackertools)
 - [Hacker News](https://news.ycombinator.com/item?id=19078281)
 - [Lobsters](https://lobste.rs/s/h6157x/mit_hacker_tools_lecture_series_on) — you'll need an [invite](https://lobste.rs/about#invitations) to comment
 - [`/r/learnprogramming`](https://www.reddit.com/r/learnprogramming/comments/an42uu/mit_hacker_tools_a_lecture_series_on_programmer/)
 - [`/r/programming`](https://www.reddit.com/r/programming/comments/an3xki/mit_hacker_tools_a_lecture_series_on_programmer/)
 - [Twitter](https://twitter.com/Jonhoo/status/1091896192332693504)
 - [YouTube](https://www.youtube.com/playlist?list=PLyzOVJj3bHQuiujH1lpn8cA9dsyulbYRv)
 - [Facebook](https://www.facebook.com/jonhoo/posts/10161566630165387)

---

<div class="small center">
<p><a href="https://github.com/missing-semester/missing-semester">Source code</a>.</p>
</div>
