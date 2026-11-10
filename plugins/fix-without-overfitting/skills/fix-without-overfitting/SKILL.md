---
name: fix-without-overfitting
description: Fix the cause of a failure instead of making the failing cases pass. Forbids special-casing (hard-coded expected values, branches keyed on the failing inputs, edited tests, thresholds nudged until cases flip, swallowed errors), checks the change for values copied from the failures, and proves the fix on cases it was not written against. Use when fixing failing tests, bug reports or wrong outputs from any code, including LLM, data and ranking pipelines, or when the user says "don't overfit", "no special cases", "fix it properly" or "failure cases first".
---

# Fix without overfitting

There are two ways to make a failing case pass. One fixes the cause. The other teaches the code to recognise the case: a hard-coded expected value, an `if` for that one input, a timeout raised until the flaky test goes green, a prompt line about the exact example that went wrong. Both turn the test green. Only the first fixes anything.

Coding agents are known to take the second way when they get stuck. This skill rules it out.

**The core rule: the fix must not be able to tell it's looking at one of the cases it was written for.** If it can, it isn't a fix.

## 1. Write down the failures

For each failure, note:
- the input;
- what happened;
- what should have happened, described as a behaviour ("dates before 1970 parse correctly"), not as a copied value;
- a guess at the kind of mistake.

Use the real failures: the failing tests, the bug report or the bad outputs. Don't invent them.

## 2. Set up a check the fix can't see, before you fix anything

Decide how you'll show the fix generalises, and do it first:

- **Ordinary code:** write a few new test cases for the same behaviour with *different* inputs from the failing ones, such as other values, edge cases and the opposite case. Where it fits, add a property test over a range of inputs. Keep the cases that already pass as a regression check.
- **Data, LLM, ranking or other pipelines:** set aside a sample from the same source and period that you won't look at while fixing. Add a sample of cases that work today.

If neither is possible, say so. A fix you can only check against its own failures hasn't been shown to work.

**Don't change the failing tests or their expected values.** If you believe a test itself is wrong, stop and tell the user why, rather than editing it.

## 3. Find the cause

Group the failures by the kind of mistake, not by example. Find the line, step or rule that produces it.

If every failure seems to need its own fix, you haven't found the cause yet. Keep looking.

If the same cause could have left holes the failures don't show, the abstract-dont-copy skill covers finding them and fixing the whole class.

## 4. Fix it without special-casing

The fix must not contain any of these:

- **Copied values:** strings, IDs, file names, error messages, dates, numbers or names taken from the failing inputs or expected outputs. That covers code, config, prompts and rules.
- **Input-keyed branches:** `if` or `switch` cases that only the failing inputs take.
- **Nudged numbers:** a threshold, timeout, retry count or tolerance changed until the failures flip, with no reason that would hold for other inputs.
- **Test edits:** changes to tests, fixtures, snapshots or expected outputs made to get a pass.
- **Hidden errors:** catching, skipping or silencing the error the failure raised.
- **Answers at run time:** test labels, gold answers or expected outputs that the running code can reach.
- **For LLM prompts:** a rule or example that describes the failing case instead of the class it belongs to.

A good fix is about the class, not the instance. For example, "handle negative timestamps" rather than "handle `-86400`"; "a caption's account isn't the speaker of a quote" rather than "@SomeAccount isn't the speaker".

## 5. Check the change for leaks

Before calling it done:

1. **List the distinctive values in the failures:** literals, IDs, names, numbers, unusual phrases and error text. Leave out ordinary words and the names of the code's own functions and fields.
2. **Search the lines the fix adds** (`git diff`) for each one. Ignore any that were already in the code before the change.
3. **Look over the diff** for new branches on specific inputs, changed numbers, and any edits to tests or fixtures.
4. **Show the user every hit,** with file and line. Then either generalise it, or explain why it's genuinely general (a standard constant, or a field name the code already uses).

Don't hide a hit by rewording it or building the same value another way.

## 6. Prove it

Run the failures, the unseen check and the regression set before and after the fix. If running them costs money, estimate the cost and ask first.

| Set | Before | After |
|---|---|---|
| The failures | 0 / n | ? / n |
| Unseen cases (step 2) | ? | ? |
| Regression | n / n | ? / n |

- **A real fix:** the failures pass, the unseen cases pass or improve on the same kind of mistake, and the regression set holds.
- **Overfit:** the failures pass but the unseen cases don't. Say so plainly, and go back to step 3.
- **A trade-off:** something in the regression set broke. Show what broke, and ask the user before keeping it.

## Report

- each kind of mistake, its cause and the fix, in one line each;
- the table;
- the leak check: clean, or each hit with its reason;
- anything still failing, and why.

Never report "fixed" from the failures alone. Always include the unseen row.
