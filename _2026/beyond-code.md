---
layout: lecture
title: "Beyond the Code"
description: >
  Learn about essential soft skills including documentation, open-source community norms, and AI etiquette.
thumbnail: /static/assets/thumbnails/2026/lec8.png
date: 2026-01-22
ready: true
video:
  aspect: 56.25
  id: 2DOEATfXT8k
---

Being a good software engineer isn't just about writing code that
works. It's about writing code that others (including future you) can
understand, maintain, and build upon. It's about communicating
clearly, contributing thoughtfully, and being a good citizen in the
ecosystems you participate in—whether open source or proprietary.

# One-way communication

Much of software engineering involves writing for people who lack your
current context: teammates who join later, maintainers who inherit
your code, or yourself in six months when you've forgotten why you
made a particular choice. A key piece of advice for all this kind of
writing is that your goal is to capture and convey the *why*, not just
the *what*. The what tends to be self-explanatory, while the *why* is
hard-earned knowledge that is easily lost to time.

Perhaps the most common form of engineer-to-engineer communication
(apart from the code itself) is code comments. I've personally found
that a lot of code comments are useless. But they don't have to be! Good
comments explain things that the code itself cannot: *why* something is
done a particular way, not *how* it works (which is what the code
shows). They can save hours of confusion, while bad comments add noise
or, worse, mislead.

Types of comments that are nearly always worthwhile:

- **TODOs**: Mark incomplete or unpolished code, but leave enough
  context for someone else to understand what's outstanding and why it
  was deferred. "TODO: optimize" is useless; "TODO: this O(n²) loop is
  fine for `n<100`, but will need indexing if we scale" is actionable.
- **References**: Link to external sources when code implements an
  algorithm from a paper, adapts code from elsewhere, or encodes
  behaviour specified in documentation. Use permalinks. Note any
  divergences from the reference.
- **Correctness arguments**: Explain *why* non-trivial code produces
  correct results. The code shows the steps; a comment explains why
  those steps work.
- **Hard-learned lessons**: If you spent 30+ minutes debugging something
  and the fix is a non-obvious incantation, document it. Your past self
  didn't realize it was needed; future readers won't either.
- **Rationale for constants**: Magic numbers deserve explanation. Why
  1492? Why 16 bits? Was it chosen randomly, derived from testing, or
  required for correctness? Even "chosen arbitrarily" is useful
  information.
- **Load-bearing choices**: If correctness depends on a
  seemingly-innocent implementation detail (e.g., "must be a BTreeSet
  because iteration order matters below"), call it out explicitly.
- **"Why not"s**: When you deliberately avoid the obvious approach,
  explain why. Otherwise someone will "fix" it later and break things.

READMEs (you have one, right?) are also a common first touch-point with
other developers. A good one answers four questions immediately: What
does this do? Why should I care? How do I use it? How do I install it?
In that order. Structure it like a funnel: a one-liner and maybe a
visual demo at the top so someone can decide in seconds if this solves
their problem, then progressively add depth. Show usage before
installation — people want to see what they're getting before committing
to setup steps.

Commit messages are another kind of "writing for others" that is often
neglected. They are often written as "fixed blah" or "added foo", and
while that may be sufficient in some cases, it's easy to forget that
they form the historical record of *why* the codebase evolved the way it
did. When someone (including you!) runs `git blame` trying to understand
a confusing change, good commit messages should give them answers.

In general, the body should answer:
- What problem forced this change?
- What alternatives did you consider?
- What are the trade-offs or implications?
- What might be surprising about this approach?

> Obviously you should scale detail with complexity. A one-line typo fix
> needs only a subject. A subtle race condition fix that took hours to
> debug deserves paragraphs explaining the problem and solution.

For complex changes, it can be useful to follow a Problem → Solution →
Implications structure: Start with the forcing function or limitation,
then explain what changed and the key design decisions, and then list
noteworthy consequences (positive and negative). That last part is
particularly important; real engineering involves balancing concerns,
and documenting that a trade-off was intentional prevents future
developers from thinking you missed the problem.

LLMs _can_ be helpful in writing commit messages. However, if you simply
point one at your change and ask it to write the commit message for the
change, the LLM will only have access to the _what_, not the _why_. And
the resulting commit message will thus be mostly descriptive (the
opposite of what we want!). If you used an LLM to help you make the
change in the first place, asking the LLM to write the commit in that
same session can be a much better option since your conversation with
the LLM is inherently a rich source of context about the change!
Otherwise, or in addition, a useful trick is to specifically tell the
LLM you'd like a commit message focused on the "why" (and other nuances
from the notes above), and then _tell it to query you for missing
context_. Essentially, you're acting like a MCP "tool" for the coding
agent that it can use to "read" context.

As your changes get more complex, make sure to also break up commits
logically (`git add -p` is your friend). Each commit should represent
one coherent change that could be understood and reviewed independently.
Don't mix refactoring with new features or combine unrelated bug fixes,
as this muddies the story for which changes fixed what problem, and will
almost certainly slow down the eventual review of your changes. It also
gives you superpowers through `git bisect`, but that's a story for
another time.

> One note as you start being more diligent about technical writing, and
> using it more extensively, make sure you respect the reader. It's easy
> to end up over-explaining once you start, but you have to resist that
> urge lest the reader read _none_ of what you've written. Explain the
> "why" and trust them to figure out the "how" for their situation.

# Collaboration

As engineers, we may spend a large part of our job coding at our own
keyboard, but a sizeable chunk of our time is also taken up by
communicating with others. That time is usually split into collaboration
and education, and the payoff from investing in getting better at both is
significant.

## Contributing

Whether you are submitting a bug report, contributing a simple bug fix,
or implementing a huge feature, it's worth keeping in mind that there
are usually orders of magnitude more users than there are contributors,
and an order of magnitude more contributors than there are maintainers.
As a result, maintainer time is highly oversubscribed. If you want to
increase the likelihood that your contribution goes somewhere
productive, you have to ensure that your contributions carry a high
signal-to-noise ratio and are worth the maintainers' time.

For example, a good bug report respects the maintainer's time by
providing everything needed to understand and reproduce the problem:

- **Environment**: OS, version numbers, relevant configuration
- **What you expected** vs **what actually happened**
- **Steps to reproduce**: Be specific. "Click the button" is less useful
  than "Click the Submit button on the /settings page while logged in as
  an admin."
- **What you've already tried**: This prevents duplicate suggestions and
  shows you've done some investigation

> If you find a security vulnerability, don't post it publicly. Contact
> the maintainers privately first and give them reasonable time to fix
> it before disclosure. Many projects have a SECURITY.md file or
> similar for this purpose.

**Make sure you search for existing issues.** Your bug or feature
request may already be reported, and it's far better to add information
to existing discussions rather than creating duplicates. Not to mention,
it reduces noise for the maintainers.

Minimal reproducible examples are gold, if you can come up with one.
They save the maintainer a huge amount of time and effort, and
reliably reproducing the bug is often the hardest part of fixing it. Not
to mention, the effort you put into isolating the problem often helps
you understand it better too, and sometimes leads you to find a fix
yourself.

If you don't hear back right away, keep in mind that maintainers are
often volunteers with limited time. If you're waiting for a reply from
them, a polite follow-up after a couple weeks is fine; daily pings are
not. Similarly, "me too" comments, or bug reports that are just a
copy-paste of some terminal output tend to be a net-negative in terms of
getting traction for your issue.

If you're looking to make a code contribution, you'll also want to
familiarize yourself with the contribution guidelines. Many projects
have a `CONTRIBUTING.md` — follow it. You'll also usually want to start
small; a typo fix or documentation improvement is a great first
contribution as it helps you learn the project's processes without also
having to go through lots of back and forth on the content.

> Check what license the project uses, as any code you contribute will
> fall under the same license. In particular, look out for copyleft
> licenses (like GPL), which requires derivatives to also be open source
> and may have implications for your employer if you touch it!
> [choosealicense.com](https://choosealicense.com/) has more useful
> information.

When you've decided to open a pull request ("PR"), first make sure you
isolate the change you actually want to be accepted. If your PR changes
lots of other unrelated things at the same time, chances are the
reviewer will send it back to you asking you to clean it up. This is
similar to how you should break down your git commits into semantically
related chunks.

In some cases, if you have many seemingly-disparate changes but
they're all needed to enable one feature, it may be okay to open a
larger PR that captures all the changes. However, in this case, commit
hygiene is particularly important so that maintainers have the option
to review the change "commit by commit".

Next, make sure you explain the "why" behind the change well. Don't just
describe _what_ changed — explain _why_ the change is needed and _why_
this is a good way to address the problem. You should also proactively
call out parts of the change that warrant special attention in the
review, if any. Depending on `CONTRIBUTING.md` and the nature of your
change, reviewers may also expect to see additional information like
trade-offs you made or how to test the change.

> We recommend contributing back to upstream projects rather than
> "forking" the project, at least as a first approach. Forking (license
> permitting) should be reserved for when the contributions you want to
> make are out of scope for the original project. If you do fork, make
> sure you acknowledge the original project!

AI makes it incredibly easy to generate plausible-looking code and PRs
quickly, but this doesn't excuse you from understanding what you're
contributing. Submitting AI-generated code you can't explain burdens
maintainers with reviewing and potentially maintaining code that even
its author doesn't understand. It's fine to use AI to help you
identify issues and produce fixes/features, **so long as you still do
the due diligence** to polish it into a worthwhile contribution, rather
than passing that work on to the (already-overloaded) maintainers.

Remember that for maintainers, accepting a PR means accepting long-term
responsibility. They will be maintaining this code long after the
contributor has moved on, and so may decline changes that are
well-intentioned but don't fit the project's direction, add complexity
they don't want to maintain, or where the need simply isn't sufficiently
well-documented. It's on _you_ as the contributor to make the case for
why the accepting the contribution is worth the maintenance burden.

> When receiving feedback on a PR, remember that your code is not you!
> Reviewers are trying to make the code better, not criticizing you
> personally. Ask clarifying questions if you disagree — you might learn
> something, or maybe they will.

## Reviewing

You might think code review is something senior developers do, but
you'll likely be asked to review code much earlier than you expect, and
your perspective is valuable. Fresh eyes catch things that experienced
developers overlook, and questions from someone less familiar with the
code often reveal assumptions that should be documented or simplified.

Review is also one of the fastest ways to learn. You'll see how others
approach problems, pick up patterns and idioms, and develop intuition
for what makes code readable. Beyond personal growth, reviews catch bugs
before they reach production, spread knowledge across the team, and
improve code quality through collaboration. They are not merely
bureaucratic overhead.

Good code review is a skill you need to hone over time, but there are
some tips that can make them much better much faster:

- **Review the code, not the person**:
  "This function is confusing" vs "You wrote confusing code."
- **Prefer actionable comments**:
  "Can you replace these globals with a config dataclass" is an easier
  comment to address than "Don't use globals here"
- **Ask questions rather than making demands**:
  "What happens if X is null here?" invites discussion better than
  "Handle the null case."
- **Explain the "why"**:
  "Consider using a constant here" is less useful than "Consider using a
  constant here so we can easily adjust the timeout based on
  environment."
- **Distinguish blocking issues from suggestions**:
  Be clear about what must change versus what's a matter of preference.
- **Acknowledge what's good**:
  Pointing out clever solutions or clean implementations is encouraging
  and helps the author know what to continue doing.
- **Know when to stop**:
  Contributors only have so much time and patience, and it's not always
  best spent handling all the nits. Focus on the big things, and
  consider tidying up nits yourself after the fact.

> AI tools can catch certain issues, but they're not a substitute for
> human review. They miss context, don't understand product
> requirements, and can confidently suggest wrong things. They're worth
> using as a first pass, but not a replacement for thoughtful human
> review.

# Education

A lot of our non-coding time as engineers is spent either asking or
answering questions, possibly a mixture of both; during collaboration,
in dialogue with peers, or while trying to learn. Asking good questions
is a skill that makes you better at learning from anyone, not just
perfect explainers. Julia Evans has some excellent blog posts on "[How
to ask good questions](https://jvns.ca/blog/good-questions/)" and "[How
to get useful answers to your
questions](https://jvns.ca/blog/2021/10/21/how-to-get-useful-answers-to-your-questions/)"
that are worth reading.

Some particularly valuable pieces of advice are:

- **State your understanding first**: Say what you think you know and
  ask "is that right?" This helps the answerer identify your actual
  knowledge gaps.
- **Ask yes/no questions**: "Is X true?" prevents tangential
  explanations and usually prompts useful elaboration anyway.
- **Be specific**: "How do SQL joins work?" is too vague. "Does a LEFT
  JOIN include rows where the right table has no match?" is answerable.
- **Admit when you don't understand**: Interrupt to ask about unfamiliar
  terms. This reflects confidence, not weakness. Similarly, if they ask
  questions of you that you do not know the answer to, it's best to say
  "I don't know", and possibly follow up with "but I think ..." or even
  "but I can find out".
- **Don't accept incomplete answers**: Keep asking follow-ups until you
  actually understand.
- **Do some research first**: Basic investigation helps you ask more
  targeted questions (though casual questions among colleagues are
  fine).

Remember: well-crafted questions benefit entire communities. They
surface hidden assumptions that others need to understand too.

> Note that this advice applies just as much when communicating with
> LLMs!

# AI etiquette

With the growing use of LLMs and AI across software engineering, the
social and professional norms around are still in flux. We already
covered many of the tactical considerations in the [agentic coding
lecture](/2026/agentic-coding/), but there are also "softer" parts of
their use that are worth discussing.

The first of these is that when AI meaningfully contributed to your
work, **disclose it**. This isn't about shame — it's about honesty,
setting appropriate expectations, and ensuring the resulting work gets
the appropriate level of review. It's also worthwhile to disclose which
_parts_ you use AI for — there's a meaningful distinction between "this
whole thing is vibecoded" and "I wrote this backup tool and used an LLM
to style the web frontend". For example, we've used LLMs to help write
some of these lecture notes, including proofreading, brainstorming, and
generating first drafts of code snippets and exercises.

You'll also want to follow the norms of the teams and projects you're
contributing to here. Some teams have stricter policies around the use
of AI than others (e.g., for compliance or data residency reasons), and
you don't want to accidentally run afoul of that. Being open about your
use helps prevent potentially costly mistakes.

> If you're aiming to learn as part of the work you're doing, keep in
> mind that if you have AI do all or most of the work for you can be
> self-defeating; you're likely to learn more about prompting (and maybe
> reviewing AI output) than the task itself. Especially when you're
> learning, the point may be the journey, not the destination, so using
> AI to "get the solution quickly" is an anti-goal.

A related concern comes up in interviews and other assessment
situations. These are often intended to specifically evaluate _your_
skills and abilities, not those of an LLM. More companies now allow you
to use LLMs and other AI-assisted tooling in interviews as long as you
let them observe those interactions as part of the interview (i.e., they
are evaluating your skill in making use of those tools too!), but those
are still in the minority. If you are unsure about whether AI assistance
is in scope for a particular task, ask!

> It should go without saying that if an assessment situation explicitly
> calls for no external tools, no LLMs, etc., you should not use them.
> Trying to do so discretely without getting caught **will** come back
> to bite you.

# Exercises

1. Browse the source code of a well-known project (e.g.,
   [Redis](https://github.com/redis/redis) or
   [curl](https://github.com/curl/curl)). Find examples of some of the
   comment types mentioned in the lecture: a useful TODO, a reference to
   external documentation, a "why not" comment explaining an avoided
   approach, or a hard-learned lesson. What would be lost if that
   comment was not there?

1. Pick an open-source project you're interested in and look at its
   recent commit history (`git log`). Find one commit with a good
   message that explains *why* the change was made, and one with a weak
   message that only describes *what* changed. For the weak one, look at
   the diff (`git show <hash>`) and try to write a better commit message
   following the Problem → Solution → Implications structure. Notice how
   much work is required to reassemble the necessary context after the
   fact!

1. Compare the READMEs of three GitHub projects with 1000+ stars. Are
   all of them equally useful? Look for things that come across mostly
   as noise to you as a lesson for future READMEs you write yourself.

1. Find an open issue on a project you use (check the "good first issue"
   or "help wanted" labels if they have it). Evaluate the issue against
   the criteria from the lecture: does it seem like it values the
   maintainer's time and contains all the information necessary to debug
   it, or do you expect that the maintainer may need to go multiple
   rounds of questions with the submitter to get to the root problem?

1. Think of a bug you've encountered in software you use (or find one in
   an issue tracker). Practice creating a minimal reproducible example:
   strip away everything unrelated to the bug until you have the
   smallest case that still demonstrates the problem. Write up what you
   removed and why.

1. Find a merged pull request on a project you're familiar with that has
   substantive review comments (not just "LGTM"). Read through the
   review. Were all the comments equally productive? If you were the PR
   author, how would you find the experience of getting all those
   comments?

1. Go to Stack Overflow and find a question in a technology you know
   that has a highly-voted answer. Then find one that was closed or
   heavily downvoted. Compare them against the advice from the lecture;
   was it predictable which question would get better answers?
