---
layout: page
title: 往期课程
description: >
  往期课程
---

{% comment %} pop to remove default "posts" collection {% endcomment %}
{% assign sorted_collections = site.collections | sort: 'label' | pop | reverse %}
<ul>
{% for collection in sorted_collections %}
    {% if forloop.index == 1 %}
        <li><a href="/">{{ collection.label }}</a> (当前)</li>
    {% else %}
        <li><a href="/{{ collection.label }}/">{{ collection.label }}</a></li>
    {% endif %}
{% endfor %}
</ul>

每年的讲座内容都是完全独立的。我们建议您从最新版本的课程材料开始学习。由于每年的授课主题都会有所变化，因此我们会继续保留早期版本课程的讲义和视频。
