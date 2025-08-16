---
layout: lecture
title: "Automation"
presenter: Jose
video:
  aspect: 56.25
  id: BaLlAaHz-1k
---

Sometimes you write a script that does something but you want for it to run periodically, say a backup task. You can always write an *ad hoc* solution that runs in the background and comes online periodically. However, most UNIX systems come with the cron daemon which can run task with a frequency up to a minute based on simple rules.

On most UNIX systems the cron daemon, `crond` will be running by default but you can always check using `ps aux | grep crond`.

## The crontab

The configuration file for cron can be displayed running `crontab -l` edited running `crontab -e` The time format that cron uses are five space separated fields along with the user and command

- **minute** -  What minute of the hour the command will run on,
     and is between '0' and '59'
- **hour** -    This controls what hour the command will run on, and is specified in
         the 24 hour clock, values must be between 0 and 23 (0 is midnight)
- **dom** - This is the Day of Month, that you want the command run on, e.g. to
     run a command on the 19th of each month, the dom would be 19.
- **month** -   This is the month a specified command will run on, it may be specified
     numerically (0-12), or as the name of the month (e.g. May)
- **dow** - This is the Day of Week that you want a command to be run on, it can
     also be numeric (0-7) or as the name of the day (e.g. sun).
- **user** -    This is the user who runs the command.
- **command** - This is the command that you want run. This field may contain
     multiple words or spaces.

Note that using an asterisk `*` means all and using an asterisk followed by a slash and number means every nth value. So `*/5` means every five. Some examples are

```shell
*/5   *    *   *   *       # Every five minutes
  0   *    *   *   *       # Every hour at o'clock
  0   9    *   *   *       # Every day at 9:00 am
  0   9-17 *   *   *       # Every hour between 9:00am and 5:00pm
  0   0    *   *   5       # Every Friday at 12:00 am
  0   0    1   */2 *       # Every other month, the first day, 12:00am
```
You can find many more examples of common crontab schedules in [crontab.guru](https://crontab.guru/examples.html)

## Shell environment and logging

A common pitfall when using cron is that it does not load the same environment scripts that common shells do such as `.bashrc`, `.zshrc`, &c and it does not log the output anywhere by default. Combined with the maximum frequency being one minute, it can become quite painful to debug cronscripts initially.

To deal with the environment, make sure that you use absolute paths in all your scripts and modify your environment variables such as `PATH` so the script can run successfully. To simplify logging, a good recommendation is to write your crontab in a format like this


```shell
* * * * *   user  /path/to/cronscripts/every_minute.sh >> /tmp/cron_every_minute.log 2>&1
```

And write the script in a separate file. Remember that `>>` appends to the file and that `2>&1` redirects `stderr` to `stdout` (you might to want keep them separate though).

## Anacron

One caveat of using cron is that if the computer is powered off or asleep when the cron script should run then it is not executed. For frequent tasks this might be fine, but if a task runs less often, you may want to ensure that it is executed. [anacron](https://linux.die.net/man/8/anacron) works similar to `cron` except that the frequency is specified in days. Unlike cron, it does not assume that the machine is running continuously. Hence, it can be used on machines that aren't running 24 hours a day, to control regular jobs as daily, weekly, and monthly jobs.


## Exercises

1. Make a script that looks every minute in your downloads folder for any file that is a picture (you can look into [MIME types](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types) or use a regular expression to match common extensions) and moves them into your Pictures folder.

1. Write a cron script to weekly check for outdated packages in your system and prompts you to update them or updates them automatically.



{% comment %}

- [fswatch](https://github.com/emcrisostomo/fswatch)
- GUI automation (pyautogui) [Automating the boring stuff Chapter 18](https://automatetheboringstuff.com/chapter18/)
- Ansible/puppet/chef

- https://xkcd.com/1205/
- https://xkcd.com/1319/

{% endcomment %}
