---
layout: page
title: 计算机教育中缺失的一课
---

# The Missing Semester of Your CS Education 中文版

大学里的计算机课程通常专注于讲授从操作系统到机器学习这些学院派的课程或主题，而对于如何精通工具这一主题则往往会留给学生自行探索。在这个系列课程中，我们讲授命令行、强大的文本编辑器的使用、使用版本控制系统提供的多种特性等等。学生在他们受教育阶段就会和这些工具朝夕相处（在他们的职业生涯中更是这样）。

因此，花时间打磨使用这些工具的能力并能够最终熟练地、流畅地使用它们是非常有必要的。

精通这些工具不仅可以帮助您更快的使用工具完成任务，并且可以帮助您解决在之前看来似乎无比复杂的问题。

关于 [开设此课程的动机](/about/)。

{% comment %}

# Registration

Sign up for the IAP 2020 class by filling out this [registration form](https://forms.gle/TD1KnwCSV52qexVt9).
{% endcomment %}

# 日程 <span style="float:right"><img src = "https://img.shields.io/badge/文档同步时间-2021--04--24-blue"></span>

<ul>
{% assign lectures = site['2020'] | sort: 'date' %}
{% for lecture in lectures %}
    {% if lecture.phony != true and lecture.solution !=true  %}
        <li>
        <strong>{{ lecture.date | date: '%-m/%d' }}</strong>:
        {% if lecture.ready%}
            <a href="{{ lecture.url }}">{{ lecture.title }}</a><span style="float:right"><img src = "https://img.shields.io/badge/Chinese-✔-green"></span>
        {% else %}
             <a href="{{ lecture.url }}">{{ lecture.title }}  {% if lecture.noclass %}[no class]{% endif %}</a><span style="float:right"><img src = "https://img.shields.io/badge/Chinese-✘-orange"></span>
        {% endif %}
        {% if lecture.sync %}
           <span style="float:right"><img src = "https://img.shields.io/badge/Update-✔-green"></span>
        {% else %}
           <span style="float:right"><img src = "https://img.shields.io/badge/Update-✘-orange"></span>
        {% endif %}
        {% if lecture.solution.ready%}
        <span style="float:right"><a href="{{site.url}}/{{site.solution_url}}/{{lecture.solution.url}}"><img src = "https://img.shields.io/badge/Solution-✔-green"></a></span>
            {% else %}
            <span style="float:right"><img src = "https://img.shields.io/badge/Solution-✘-orange"></span>
            {% endif %}
        </li>
    {% endif %}
{% endfor %}
</ul>

讲座视频可以在 [
YouTube](https://www.youtube.com/playlist?list=PLyzOVJj3bHQuloKGG59rS43e29ro7I57J) 上找到。

# 关于本课程

**教员**：本课程由 [Anish](https://www.anishathalye.com/)、[Jon](https://thesquareplanet.com/) 和 [Jose](http://josejg.com/) 讲授。

**问题**：请通过 [missing-semester@mit.edu](mailto:missing-semester@mit.edu) 联系我们。

# 在 MIT 之外

我们也将本课程分享到了 MIT 之外，希望其他人也能受益于这些资源。您可以在下面这些地方找到相关文章和讨论。

 - [Hacker News](https://news.ycombinator.com/item?id=22226380)
 - [Lobsters](https://lobste.rs/s/ti1k98/missing_semester_your_cs_education_mit)
 - [/r/learnprogramming](https://www.reddit.com/r/learnprogramming/comments/eyagda/the_missing_semester_of_your_cs_education_mit/)
 - [/r/programming](https://www.reddit.com/r/programming/comments/eyagcd/the_missing_semester_of_your_cs_education_mit/)
 - [Twitter](https://twitter.com/jonhoo/status/1224383452591509507)
 - [YouTube](https://www.youtube.com/playlist?list=PLyzOVJj3bHQuloKGG59rS43e29ro7I57J)

# 译文

- [繁体中文](https://missing-semester-zh-hant.github.io/)
- [Japanese](https://missing-semester-jp.github.io/)
- [Korean](https://missing-semester-kr.github.io/)
- [Portuguese](https://missing-semester-pt.github.io/)
- [Russian](https://missing-semester-rus.github.io/)
- [Serbian](https://netboxify.com/missing-semester/)
- [Spanish](https://missing-semester-esp.github.io/)
- [Turkish](https://missing-semester-tr.github.io/)
- [Vietnamese](https://missing-semester-vn.github.io/)

注意：上述链接为社区翻译，我们并未验证其内容。

## 致谢

感谢 Elaine Mello, Jim Cain 以及 [MIT Open Learning](https://openlearning.mit.edu/) 帮助我们录制讲座视频。

感谢 Anthony Zolnik 和 [MIT AeroAstro](https://aeroastro.mit.edu/) 提供 A/V 设备。

感谢 Brandi Adams 和 [MIT EECS](https://www.eecs.mit.edu/) 对本课程的支持。

---

<div class="small center">
<p><a href="https://github.com/missing-semester-cn/missing-semester-cn">Source code</a>.</p>
<p>Licensed under CC BY-NC-SA.</p>
<p>See <a href="/license">here</a> for contribution &amp; translation guidelines.</p>
</div>
