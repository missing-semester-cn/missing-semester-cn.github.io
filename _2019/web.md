---
layout: lecture
title: "Web and Browsers"
presenter: Jose
video:
  aspect: 62.5
  id: XpZO3S8odec
---

Apart from the terminal, the web browser is a tool you will find yourself spending significant amounts of time into. Thus it is worth learning how to use it efficiently and

## Shortcuts

Clicking around in your browser is often not the fastest option, getting familiar with common shortcuts can really pay off in the long run.

- `Middle Button Click` in a link opens it in a new tab
- `Ctrl+T` Opens a new tab
- `Ctrl+Shift+T` Reopens a recently closed tab
- `Ctrl+L` selects the contents of the search bar
- `Ctrl+F` to search within a webpage. If you do this often, you may benefit from an extension that supports regular expressions in searches.


## Search operators

Web search engines like Google or DuckDuckGo provide search operators to enable more elaborate web searches:

- `"bar foo"` enforces an exact match of bar foo
- `foo site:bar.com` searches for foo within bar.com
- `foo -bar ` excludes the terms containing bar from the search
- `foobar filetype:pdf` Searches for files of that extension
- `(foo|bar)` searches for matches that have foo OR bar

More through lists are available for popular engines like [Google](https://ahrefs.com/blog/google-advanced-search-operators/) and [DuckDuckGo](https://duck.co/help/results/syntax)


## Searchbar

The searchbar is a powerful tool too. Most browsers can infer search engines from websites and will store them. By editing the keyword argument

- In Google Chrome they are in [chrome://settings/searchEngines](chrome://settings/searchEngines)
- In Firefox they are in [about:preferences#search](about:preferences#search)

For example you can make so that `y SOME SEARCH TERMS` to directly search in youtube.

Moreover, if you own a domain you can setup subdomain forwards using your registrar. For instance I have mapped `https://ht.josejg.com` to this course website. That way I can just type `ht.` and the searchbar will autocomplete. Another good feature of this setup is that unlike bookmarks they will work in every browser.

## Privacy extensions

Nowadays surfing the web can get quite annoying due to ads and invasive due to trackers. Moreover a good adblocker not only blocks most ad content but it will also block sketchy and malicious websites since they will be included in the common blacklists. They will also reduce page load times sometimes by reducing the amount of requests performed. A couple of recommendations are:

- **uBlock origin** ([Chrome](https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm), [Firefox](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/)): block ads and trackers based on predefined rules. You should also consider taking a look at the enabled blacklists in settings since you can enable more based on your region or browsing habits. You can even install filters from [around the web](https://github.com/gorhill/uBlock/wiki/Filter-lists-from-around-the-web)

- **[Privacy Badger](https://privacybadger.org/)**: detects and blocks trackers automatically. For example when you go from website to website ad companies track which sites you visit and build a profile of you

- **[HTTPS everywhere](https://www.eff.org/https-everywhere)** is a wonderful extension that redirects to HTTPS version of a website automatically, if available.

You can find about more addons of this kind [here](https://www.privacytools.io/privacy-browser-addons/)

## Style customization

Web browsers are just another piece of software running in _your machine_ and thus you usually have the last say about what they should display or how they should behave. An example of this are custom styles. Browsers determine how to render the style of a  webpage using Cascading Style Sheets often abbreviated as CSS.

You can access the source code of a website by inspecting it and changing its contents and styles temporarily (this is also a reason why you should never trust webpage screenshots).

If you want to permanently tell your browser to override the style settings for a webpage you will need to use an extension. Our recommendation is **[Stylus](https://github.com/openstyles/stylus)** ([Firefox](https://addons.mozilla.org/en-US/firefox/addon/styl-us/), [Chrome](https://chrome.google.com/webstore/detail/stylus/clngdbkpkpeebahjckkjfobafhncgmne?hl=en)).


For example, we can write the following style for the class website


```css

body {
    background-color: #2d2d2d;
    color: #eee;
    font-family: Fira Code;
    font-size: 16pt;
}

a:link {
    text-decoration: none;
    color: #0a0;
}
```

Moreover, Stylus can find styles written by other users and published in [userstyles.org](https://userstyles.org/). Most common websites have one or several dark theme stylesheets for instance. FYI, you should not use Stylish since it was shown to leak user data, more [here](https://arstechnica.com/information-technology/2018/07/stylish-extension-with-2m-downloads-banished-for-tracking-every-site-visit/)


## Functionality Customization

In the same way that you can modify the style, you can also modify the behaviour of a website by writing custom javascript and them sourcing it using a web browser extension such as [Tampermonkey](https://tampermonkey.net/)

For example the following script enables vim-like navigation using the J and K keys.

```js
// ==UserScript==
// @name         VIM HT
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Vim JK for our website
// @author       You
// @match        https://hacker-tools.github.io/*
// @grant        none
// ==/UserScript==


(function() {
    'use strict';

    window.onkeyup = function(e) {
        var key = e.keyCode ? e.keyCode : e.which;

        if (key == 74) { // J is key 74
            window.scrollBy(0,500);;
        }else if (key == 75) { // K is key 75
            window.scrollBy(0,-500);;
        }
    }
})();
```

There are also script repositories such as [OpenUserJS](https://openuserjs.org/) and [Greasy Fork](https://greasyfork.org/en). However, be warned, installing user scripts from others can be very dangerous since they can pretty much do anything such as steal your credit card numbers. Never install a script unless you read the whole thing yourself, understand what it does, and are absolutely sure that you know it isn't doing anything suspicious. Never install a script that contains minified or obfuscated code that you can't read!

## Web APIs

It has become more and more common for webservices to offer an application interface aka web API so you can interact with the services making web requests.
A more in depth introduction to the topic can be found [here](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Client-side_web_APIs/Introduction). There are [many public APIs](https://github.com/toddmotto/public-apis). Web APIs can be useful for very many reasons:

- **Retrieval**. Web APIs can quite easily provide you information such as maps, weather or what your public ip address. For instance `curl ipinfo.io` will return a JSON object with some details about your public ip, region, location, &c. With proper parsing these tools can be integrated even with command line tools. The following bash functions talks to Googles autocompletion API and returns the first ten matches.

```bash
function c() {
    url='https://www.google.com/complete/search?client=hp&hl=en&xhr=t'
    # NB: user-agent must be specified to get back UTF-8 data!
    curl -H 'user-agent: Mozilla/5.0' -sSG --data-urlencode "q=$*" "$url" |
        jq -r ".[1][][0]" |
        sed 's,</\?b>,,g'
}
```

- **Interaction**. Web API endpoints can also be used to trigger actions. These usually require some sort of authentication token that you can obtain through the service. For example performing the following
`curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello, World!"}' "https://hooks.slack.com/services/$SLACK_TOKEN"` will send a `Hello, World!` message in a channel.

- **Piping**. Since some services with web APIs are rather popular, common web API "gluing" has already been implemented and is provided with server included. This is the case for services like [If This Then That](https://ifttt.com/) and [Zapier](https://zapier.com/)


## Web Automation

Sometimes web APIs are not enough. If only reading is needed you can use a html parser like `pup` or use a library, for example python has BeautifulSoup. However if interactivity or javascript execution is required those solutions fall short. WebDriver


For example, the following script will save the specified url using the wayback machine simulating the interaction of typing the website.

```python
from selenium.webdriver import Firefox
from selenium.webdriver.common.keys import Keys


def snapshot_wayback(driver, url):

    driver.get("https://web.archive.org/")
    elem = driver.find_element_by_class_name('web-save-url-input')
    elem.clear()
    elem.send_keys(url)
    elem.send_keys(Keys.RETURN)
    driver.close()


driver = Firefox()
url = 'https://hacker-tools.github.io'
snapshot_wayback(driver, url)
```


## Exercises

1. Edit a keyword search engine that you use often in your web browser
1. Install the mentioned extensions. Look into how uBlock Origin/Privacy Badger can be disabled for a website. What differences do you see? Try doing it in a website with plenty of ads like YouTube.
1. Install Stylus and write a custom style for the class website using the CSS provided. Here are some common programming characters `=   ==   ===   >=   =>   ++   /=   ~=`. What happens to them when changing the font to Fira Code? If you want to know more search for programming font ligatures.
1. Find a web api to get the weather in your city/area.
1. Use a WebDriver software like [Selenium](https://docs.seleniumhq.org/) to automate some repetitive manual task that you perform often with your browser.


