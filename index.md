---
layout: page
title: The Missing Semester of Your CS Education
---

Classes teach you all about advanced topics within CS, from operating systems
to machine learning, but there’s one critical subject that’s rarely covered,
and is instead left to students to figure out on their own: proficiency with
their tools. We’ll teach you how to master the command-line, use a powerful
text editor, use fancy features of version control systems, and much more!

Students spend hundreds of hours using these tools over the course of their
education (and thousands over their career), so it makes sense to make the
experience as fluid and frictionless as possible. Mastering these tools not
only enables you to spend less time on figuring out how to bend your tools to
your will, but it also lets you solve problems that would previously seem
impossibly complex.

Read about the [motivation behind this class](/about/).

# Registration

Sign up for the IAP 2020 class by filling out this [registration form](https://forms.gle/TD1KnwCSV52qexVt9).

# Schedule

**Lecture**: 35-225, 2pm--3pm<br>
**Office hours**: 32-G9 lounge, 3pm--4pm (every day, right after lecture)

<ul>
{% assign lectures = site['2020'] | sort: 'date' %}
{% for lecture in lectures %}
    {% if lecture.phony != true %}
        <li>
        <strong>{{ lecture.date | date: '%-m/%d' }}</strong>:
        {% if lecture.ready %}
            <a href="{{ lecture.url }}">{{ lecture.title }}</a>
        {% else %}
            {{ lecture.title }} {% if lecture.noclass %}[no class]{% endif %}
        {% endif %}
        </li>
    {% endif %}
{% endfor %}
</ul>

See [here](/lectures/) for more on this year's topics, including links to
lecture notes and videos. If you want to get a sense of what the class was like
last year, check out [last year's
lectures](https://hacker-tools.github.io/lectures/).

# About the class

**Staff**: This class is co-taught by [Anish](https://www.anishathalye.com/), [Jon](https://thesquareplanet.com/), and [Jose](http://josejg.com/).  
**Questions**: Email us at [missing-semester@mit.edu](mailto:missing-semester@mit.edu).

# Beyond MIT

We've also shared this class beyond MIT in the hopes that others may
benefit from these resources. You can find posts and discussion on

 - [Hacker News](https://news.ycombinator.com/item?id=19078281)
 - [Lobsters](https://lobste.rs/s/h6157x/mit_hacker_tools_lecture_series_on)
 - [/r/learnprogramming](https://www.reddit.com/r/learnprogramming/comments/an42uu/mit_hacker_tools_a_lecture_series_on_programmer/)
 - [/r/programming](https://www.reddit.com/r/programming/comments/an3xki/mit_hacker_tools_a_lecture_series_on_programmer/)
 - [Twitter](https://twitter.com/Jonhoo/status/1091896192332693504)
 - [YouTube](https://www.youtube.com/playlist?list=PLyzOVJj3bHQuiujH1lpn8cA9dsyulbYRv)

## Acknowledgements

We thank Elaine Mello, Jim Cain, and [MIT Open
Learning](https://openlearning.mit.edu/) for making it possible for us to
record lecture videos; Anthony Zolnik and [MIT
AeroAstro](https://aeroastro.mit.edu/) for A/V equipment; and Brandi Adams and
[MIT EECS](https://www.eecs.mit.edu/) for supporting this class.

---

<div class="small center">
<p><a href="https://github.com/missing-semester/missing-semester">Source code</a>.</p>
</div>
