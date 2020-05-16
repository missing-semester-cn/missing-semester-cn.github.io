---
layout: page
title: 计算机科学教育中缺失的一课（The Missing Semester of Your CS Education）
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

阅读[开设此课程的动机](/about/).

{% comment %}
# Registration

Sign up for the IAP 2020 class by filling out this [registration form](https://forms.gle/TD1KnwCSV52qexVt9).
{% endcomment %}

# 日程

{% comment %}
**Lecture**: 35-225, 2pm--3pm<br>
**Office hours**: 32-G9 lounge, 3pm--4pm (every day, right after lecture)
{% endcomment %}

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

讲座视频可以在 [
YouTube](https://www.youtube.com/playlist?list=PLyzOVJj3bHQuloKGG59rS43e29ro7I57J)上找到

# 关于本课程

**教员**: 本课程由 [Anish](https://www.anishathalye.com/)、 [Jon](https://thesquareplanet.com/) 和 [Jose](http://josejg.com/)教授。

**问题**: 请通过 [missing-semester@mit.edu](mailto:missing-semester@mit.edu)联系我们

# 在 MIT 之外

我们将本课程分享到了MIT之外，希望其他人也能受益于这些资源。你可以在下面这些地方找到相关文章和讨论。

 - [Hacker News](https://news.ycombinator.com/item?id=22226380)
 - [Lobsters](https://lobste.rs/s/ti1k98/missing_semester_your_cs_education_mit)
 - [/r/learnprogramming](https://www.reddit.com/r/learnprogramming/comments/eyagda/the_missing_semester_of_your_cs_education_mit/)
 - [/r/programming](https://www.reddit.com/r/programming/comments/eyagcd/the_missing_semester_of_your_cs_education_mit/)
 - [Twitter](https://twitter.com/jonhoo/status/1224383452591509507)
 - [YouTube](https://www.youtube.com/playlist?list=PLyzOVJj3bHQuloKGG59rS43e29ro7I57J)

## 致谢

感谢 Elaine Mello, Jim Cain, 以及 [MIT Open
Learning](https://openlearning.mit.edu/) 帮助我们录制讲座视频。

感谢 Anthony Zolnik 和 [MIT
AeroAstro](https://aeroastro.mit.edu/) 提供 A/V 设备。

感谢 Brandi Adams 和
[MIT EECS](https://www.eecs.mit.edu/) 对本课程的支持。



---

<div class="small center">
<p><a href="https://github.com/missing-semester-cn/missing-semester-cn">Source code</a>.</p>
<p>Licensed under CC BY-NC-SA.</p>
<p>Translator: Lingfeng Ai (hanxiaomax@qq.com)</p>
<p>See <a href="/license">here</a> for contribution &amp; translation guidelines.</p>
</div>
