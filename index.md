---
layout: page
title: 计算机教育中缺失的一课
description: >
  掌握强大的工具，让您成为更高效的计算机科学家和程序员。
subtitle: IAP 2026
---

# The Missing Semester of Your CS Education 中文版

大学里的计算机课程通常专注于讲授从操作系统到机器学习这些学院派的课程或主题，而对于如何精通工具这一主题则往往会留给学生自行探索。在这个系列课程中，我们讲授命令行、强大的文本编辑器的使用、使用版本控制系统提供的多种特性等等。学生在他们受教育阶段就会和这些工具朝夕相处（在他们的职业生涯中更是这样）。

因此，花时间打磨使用这些工具的能力并能够最终熟练地、流畅地使用它们是非常有必要的。

精通这些工具不仅可以帮助您更快的使用工具完成任务，并且可以帮助您解决在之前看来似乎无比复杂的问题。

如今（2026），AI 增强工具和工作流程的引入正在使软件工程领域发生翻天覆地的变化。如果能够使用得当，这些AI工具通常可以为计算机科学从业者带来显著的好处，是一种值得学习掌握的实用技术。由于 AI 是使能技术，因此我们并没有独立的 AI 讲座；相反，我们将最新的 AI 工具和技术直接融入到每个讲座中。

关于 [开设此课程的动机](/about/)。

{% comment %}

# Registration

Sign up for the IAP 2026 class by filling out this [registration form](https://forms.gle/j2wMzi7qeiZmzEWy9).
{% endcomment %}

# 课程安排

## 2026年课程

<ul>
{% assign lectures = site['2026'] | sort: 'date' %}
{% for lecture in lectures %}
    {% if lecture.phony != true %}
        <li>
        <strong>{{ lecture.date | date: '%-m/%d/%y' }}</strong>:
        {% if lecture.ready %}
            <a href="{{ lecture.url }}">{{ lecture.title }}</a>
        {% else %}
            {{ lecture.title }} {% if lecture.noclass %}[no class]{% endif %}
        {% endif %}
        </li>
    {% endif %}
{% endfor %}
</ul>

## 2020年课程

<ul>
{% assign lectures = site['2020'] | sort: 'date' %}
{% for lecture in lectures %}
    {% if lecture.phony != true and lecture.solution !=true  %}
        <li>
        <strong>{{ lecture.date | date: '%-m/%d' }}</strong>:
        {% if lecture.ready%}
            <a href="{{ lecture.url }}">{{ lecture.title }}</a>
        {% else %}
             <a href="{{ lecture.url }}">{{ lecture.title }}  {% if lecture.noclass %}[no class]{% endif %}</a>
        {% endif %}
        </li>
    {% endif %}
{% endfor %}
</ul>

讲座视频可以在 [YouTube](https://www.youtube.com/playlist?list=PLyzOVJj3bHQunmnnTXrNbZnBaCA-ieK4L) (2026) 或 [YouTube](https://www.youtube.com/playlist?list=PLyzOVJj3bHQuloKGG59rS43e29ro7I57J) (2020) 上找到。

# 关于本课程

**教员**：本课程由 [Anish](https://anish.io/)、[Jon](https://thesquareplanet.com/) 和 [Jose](https://josejg.com/) 讲授。

**问题**：请通过 [missing-semester@mit.edu](mailto:missing-semester@mit.edu) 联系我们。

# 在 MIT 之外

我们也将本课程分享到了 MIT 之外，希望其他人也能受益于这些资源。您可以在下面这些地方找到相关文章和讨论。

 - Hacker News ([2026](https://news.ycombinator.com/item?id=47124171), [2020](https://news.ycombinator.com/item?id=22226380))
 - Lobsters ([2026](https://lobste.rs/s/q4ykw7/missing_semester_your_cs_education_2026), [2020](https://lobste.rs/s/ti1k98/missing_semester_your_cs_education_mit))
 - r/learnprogramming ([2026](https://www.reddit.com/r/learnprogramming/comments/1r93yk6/the_missing_semester_of_your_cs_education_2026/), [2020](https://www.reddit.com/r/learnprogramming/comments/eyagda/the_missing_semester_of_your_cs_education_mit/))
 - r/programming ([2020](https://www.reddit.com/r/programming/comments/eyagcd/the_missing_semester_of_your_cs_education_mit/))
 - X ([2026](https://x.com/anishathalye/status/2024521145777848588), [2020](https://twitter.com/jonhoo/status/1224383452591509507))
 - Bluesky ([2026](https://bsky.app/profile/jonhoo.eu/post/3mfa2bhyuj22i))
 - Mastodon ([2026](https://fosstodon.org/@jonhoo/116098318361854057))
 - LinkedIn ([2026](https://www.linkedin.com/posts/anishathalye_i-returned-to-mit-during-iap-january-term-activity-7430285026933522433-Ehr9))
 - YouTube ([2026](https://www.youtube.com/playlist?list=PLyzOVJj3bHQunmnnTXrNbZnBaCA-ieK4L), [2020](https://www.youtube.com/playlist?list=PLyzOVJj3bHQuloKGG59rS43e29ro7I57J))

# 翻译版本

- [阿拉伯语](https://missing-semester-ar.github.io/)
- [孟加拉语](https://missing-semester-bn.github.io/)
- [简体中文](https://missing-semester-cn.github.io/)（当前站点）
- [繁体中文（台湾）](https://missing-semester-tw.github.io/)
- [德语](https://missing-semester-de.github.io/)
- [意大利语](https://missing-semester-it.github.io/)
- [日语](https://missing-semester-jp.github.io/)
- [卡纳达语](https://missing-semester-kn.github.io/)
- [韩语](https://missing-semester-kr.github.io/)
- [波斯语](https://missing-semester-fa.github.io/)
- [葡萄牙语](https://missing-semester-pt.github.io/)
- [俄语](https://missing-semester-rus.github.io/)
- [塞尔维亚语](https://netboxify.com/missing-semester/)
- [西班牙语](https://missing-semester-esp.github.io/)
- [瑞典语](https://itiquette.github.io/den-saknade-terminen/)
- [泰语](https://missing-semester-th.github.io/)
- [土耳其语](https://missing-semester-tr.github.io/)
- [越南语](https://missing-semester-vn.github.io/)

注意：上述链接为社区翻译，我们并未验证其内容。

## 致谢

感谢 Elaine Mello 和 [MIT Open Learning](https://openlearning.mit.edu/) 让我们能够录制讲座视频。感谢 Luis Turino / [SIPB](https://sipb.mit.edu/) 作为 [SIPB IAP 2026](https://sipb.mit.edu/iap/) 的一部分支持本课程。

---

<div class="small center">
<p><a href="https://github.com/missing-semester-cn/missing-semester-cn">Source code</a>.</p>
<p>Licensed under CC BY-NC-SA.</p>
<p>See <a href="/license/">here</a> for contribution &amp; translation guidelines.</p>
</div>
