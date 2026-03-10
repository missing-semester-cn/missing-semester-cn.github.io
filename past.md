---
layout: page
title: 历年课程
description: >
  查看所有历年版本的 Missing Semester 课程。
---

{% comment %} pop to remove default "posts" collection {% endcomment %}
{% assign sorted_collections = site.collections | sort: 'label' | pop | reverse %}
<ul>
{% for collection in sorted_collections %}
    {% if forloop.index == 1 %}
        <li><a href="/">{{ collection.label }}</a> (最新)</li>
    {% else %}
        <li><a href="/{{ collection.label }}/">{{ collection.label }}</a></li>
    {% endif %}
{% endfor %}
</ul>

每年的课程都是完整独立的。我们建议从最新版本的资料开始学习。不同年份涵盖的主题会有所变化，因此我们继续托管早期版本课程的讲义和视频。
