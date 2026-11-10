---
name: abstract-dont-copy
description: Before fixing a bug, security finding, incident, regression or flaky test, name the mechanism that let it happen, find every other place the same mechanism left a hole, and fix at the level that closes the whole class, with a guard that fails if it comes back. Also use before copying a fix or pattern from another repo, a blog, Stack Overflow or an AI answer. Use when the user says "find the root cause", "where else does this happen", "fix the class", "abstract, don't copy", or reports the same kind of bug again.
---

# Abstract, don't copy

Every hole is one instance of a mechanism. Patch the instance and the mechanism produces the next hole somewhere else. Copy a fix without knowing why it works and you import someone else's constraints along with it.

This skill makes the mechanism explicit, and checkable, before any code changes.

## When to use

Use for bug fixes, security findings, incidents, regressions, flaky or failing tests, an error that keeps coming back, and any time a solution is being copied from somewhere else.

When the failures are failing tests or a set of bad outputs, the fix-without-overfitting skill covers the other half: no special-casing, and proving the fix on cases it wasn't written against.

Skip for typos, wording changes, renames, dependency bumps with no change in behaviour, and feature work with no defect involved. When copying, copy freely what's generic (a date library, a retry helper) and do the work below for what's specific to how this system works.

## The procedure

Do the steps in order. Keep each one short. Show evidence (commands, output, paths), not prose.

### 1. Reproduce, then separate the symptom from the hole

- **Reproduce it first.** Write a failing test, a script or a request that shows the problem. A fix for something you couldn't reproduce is a guess; if you truly can't reproduce it, say so and say what you'd need.
- **Symptom:** what someone observed (an error, a wrong value, an exploit, a crash).
- **Hole:** the exact place the system let it happen: file, function, boundary. That's often not where the symptom showed up. A crash on a null is a symptom; the hole is where the null was let in.

### 2. Name the mechanism in one sentence

State why the system allowed this, **without naming the specific file, function, variable, endpoint or value**. If the sentence only makes sense with those names, you've described the instance.

- Instance: "`/api/orders/:id` doesn't check that the user owns the order."
- Mechanism: "Authorization is written by hand in each handler, so any handler that forgets it is open."

Then hold it to two tests:

1. **It predicts a search.** Write down what you'd search for to find other instances: the shared shape, helper, call or missing call. If the mechanism doesn't tell you what to search for, it's too vague.
2. **It isn't a label.** "Insufficient validation", "an edge case", "human error", "a race condition" and "bad code" are categories, not mechanisms. Say what makes the mistake easy to make here.

Common mechanisms to check against:
- An invariant nothing enforces (nothing guarantees X is always true)
- An unsafe default (the easy path is the wrong path)
- Duplicated logic that drifted (the rule lives in five places and one is stale)
- An unchecked boundary (input trusted where it enters the system)
- An implicit assumption (ordering, timing, uniqueness, one caller, one tenant)
- State that can go invalid (two sources of truth, partial writes, no transaction)
- Errors swallowed or turned into defaults

If you can't settle on one mechanism after a reasonable look, list the two or three candidates and what evidence would decide between them. Don't pick one just to move on.

**Not every bug has a mechanism.** Some are one-off slips: a wrong operator, a typo in a constant. If the sibling search in step 3 finds nothing, write "Mechanism: one-off slip, no shared cause" and use the short card (below). Don't invent a bigger story to fill the field.

### 3. Find the siblings

The mechanism rarely produced only one hole. Search for every other place with the same shape, using the search from step 2.

- **Search from at least two angles:** the pattern itself (every handler, every caller of the helper, every place the value is built) and the guard that should be there (everywhere it's present, so you can see where it's missing).
- **Show the searches** you ran and how many hits each gave. Take every count from the search output, not from memory or a skim.
- **Classify every hit:**
  - **Hole:** same mechanism, same problem. Reproduce at least one.
  - **Safe:** same shape, but protected some other way. Say how.
  - **Intended:** looks the same, but the behaviour is deliberate (an admin route, a public endpoint). Say what shows it's deliberate. If you can't tell, mark it **Unsure** and ask.

Zero siblings is a valid finding, but only after the searches are shown.

### 4. Pick the fix level

| Level | What it does | Example |
| --- | --- | --- |
| 1. Patch the instance | Closes this hole only | Add the ownership check to this handler |
| 2. Fix the class | Closes every sibling found | Move ownership checks into one shared guard that all handlers use |
| 3. Make the class impossible | The wrong version can't be written or merged | A handler can't be registered without declaring its access policy; a test fails if one is missing |

Choose the **lowest level that removes the class**, not the most elegant one. Use or extend what the code already has before inventing a new abstraction. Don't touch code beyond the siblings.

### 5. Confirm before a level 2 or 3 change

Write the mechanism card (below) before any level 2 or 3 code.

- **If someone is in the loop:** show them the card and wait for them to confirm or correct the mechanism and the sibling list. The point is that they understand the mechanism, not just that the code changes. While you wait, patch the reproduced instance (level 1), and also patch at level 1 any sibling you reproduced as a **Hole** that writes or deletes data, or exposes secrets or another user's data. Don't leave a known, serious hole open while waiting for a reply about the bigger fix. These patches are stopgaps; say so on the card, and replace them with the class fix once it's agreed.
- **If no one is available** (they said to carry on without them): do level 1, plus level 2 for siblings you classified as **Hole** and reproduced. Leave level 3, and anything **Unsure**, as a follow-up with the sibling list attached.
- **If level 2 or 3 is too large for this change:** do level 1 now and write the follow-up as a concrete ticket with the sibling list.

### 6. Lock it

Add a guard that fails if the mechanism comes back, not just a test for this one input:
- a test over the whole class, which finds its members itself (every registered route, every caller) rather than a hard-coded list that new code will escape;
- a type, schema or constructor that makes the invalid state impossible to represent;
- a lint rule, CI check or assertion at the boundary.

**Show the guard failing before the fix**, on the original hole and on at least one sibling, and passing after it. A guard that never failed hasn't been shown to guard anything.

### 7. Check second-order effects

Before finishing, answer:
- Who relies on the old behaviour, including the buggy part?
- What does the fix make slower, stricter or harder for the next developer?
- Does it move the problem somewhere else? For example, a retry that hides a race, a longer timeout, or a broader catch.

## The mechanism card

Put this before the code change, and in the PR description:

```
Symptom:      <what was observed>
Reproduced:   <the test or command, and what it showed>
Hole:         <where the system let it happen>
Mechanism:    <one sentence, no specific names>
Search:       <the searches run, with hit counts>
Siblings:     <path - Hole / Safe / Intended / Unsure - one-line reason>
Fix level:    <1 / 2 / 3> because <reason>
Guard:        <what it is; failed before on <hole> and <sibling>, passes after>
Side effects: <who or what this changes>
Deferred:     <follow-up, with siblings, if not fully fixed>
```

**The short card**, for a one-off slip with no siblings:

```
Fixed:        <what was wrong, where, and the fix>
Search:       <the searches run, with hit counts: no siblings>
Guard:        <the test; failed before, passes after>
```

## Patch smells

If the planned fix is one of these, stop and go back to step 2:
- A special-case `if` for one input, user, ID or tenant
- Catching and ignoring an error, or turning it into a default value
- A retry, sleep or longer timeout that makes a failure go away
- A null check at the crash site instead of where the null came from
- Copying the validation into one more place
- Skipping, disabling or loosening a test
- A guard whose list of covered cases is typed in by hand
- Copying a fix from elsewhere without being able to say why it works here

## When copying a solution

Before adopting code or a pattern from anywhere else, write down:
1. **Principle:** why it works, in one sentence.
2. **Their constraints and ours:** scale, trust model, runtime, team size, cost of failure.
3. **The adapted version:** what changes so it fits ours.

If you can't write the first one, don't adopt it yet.

## Limits

- **Urgent production incident:** ship the level 1 patch first, then write the card and the follow-up the same day.
- **Stay in scope.** A class fix touches the siblings, not the whole codebase.
- **Be honest about doubt.** If the mechanism is still unclear, say so plainly. A card with a confident wrong mechanism is worse than no card.
