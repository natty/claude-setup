---
name: grill-me
description: Stress-test a plan or design through relentless one-at-a-time questioning until reaching shared understanding. Use when the user wants to pressure-test their thinking before committing to an approach.
user-invocable: true
disable-model-invocation: true
---

<!-- Inspired by Matt Pocock's grill-me skill (MIT): https://github.com/mattpocock/skills -->


$ARGUMENTS

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. The goal is to find the gaps, contradictions, and unstated assumptions before they become problems in implementation.

Walk down each branch of the decision tree, resolving dependencies between decisions one by one. For each question, provide your recommended answer — make me react to a concrete proposal rather than generating answers from scratch.

**Ask one question at a time.** Wait for my answer before moving to the next. Follow the thread — if my answer raises a new question, pursue it before moving on.

If a question can be answered by exploring the codebase, explore it yourself instead of asking me. Don't waste my time on things you can verify.

If a question surfaces an idea or tangent outside the current plan, park it and continue the grilling. Don't let me derail the session by chasing something shiny.

When we reach shared understanding, summarize the settled decisions and offer to log them to the appropriate project documentation.

**Watch yourself for:**
- Asking multiple questions in one message — one at a time, always
- Accepting vague answers ("we'll figure that out later") — push for specifics or flag it as an open question
- Agreeing too easily — if the plan has a weakness, name it even if I seem committed to the approach
