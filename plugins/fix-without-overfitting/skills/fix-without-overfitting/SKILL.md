---
name: fix-without-overfitting
description: Fix a pipeline from its real failures without teaching it the test set. Turns bad outputs into failure cases, freezes a held-out set the fix never sees, writes the smallest general fix, checks the change for names and ids copied from the failing examples, and proves the gain holds on held-out data. Use when fixing wrong outputs from an LLM, prompt, classifier, extraction or ranking pipeline, or when the user says "failure cases first", "generalize", "no dataset-specific rules" or "don't overfit".
---

# Fix without overfitting

The easy way to fix a failing pipeline is to make the failing examples pass. A rule that mentions the airport from example 3, a prompt line about a politician who appeared twice, a threshold tuned until the five bad cases flip: each makes the failures pass and teaches the system nothing. You end up with a pipeline that's good at its own test set.

This skill fixes the cause, and proves it on data the fix never saw.

## 1. Write down the failures

For each bad output, record a case with:
- `input`: the exact input;
- `got`: what the pipeline produced;
- `want`: what it should have produced, described as a behaviour ("the two reports of the same event are joined"), not a copied answer;
- `why`: the kind of mistake, in general words ("treats a caption's account as the speaker").

Save them as `failure-cases/<topic>.jsonl` (or the repo's existing place for cases). Use real outputs only, not invented ones.

## 2. Freeze a held-out set before you fix anything

Before touching code or prompts, set aside data the fix will never see:
- **Held-out:** inputs from the same source and period as the failures that you haven't looked at. Take a fresh random sample. If you can't tell yet whether they pass or fail, that's fine; you'll judge before and after.
- **Regression:** a sample of cases that pass today.

Write down their ids, and don't open the held-out inputs while you design the fix. If no held-out data exists, say so and ask the user for some. A fix with no held-out set can't be shown to generalize.

## 3. Find the cause, not the case

Group the failures by `why`, not by example. For each group, find the place in the pipeline that produces the mistake: the retrieval, the schema, a tool, a prompt rule, a threshold or the data.

Prefer a fix in this order:
1. the structure (schema, retrieval, the order of steps, what context is given);
2. a general rule;
3. a threshold;
4. a prompt example.

Prompt examples are the most likely to be memorised.

## 4. Write the smallest general fix

Before writing the fix, check it against these rules:
- **It names a class, not an instance.** "A caption's posting account is not the speaker of a quote" is a class. "@SomeAccount is not the speaker" is an instance.
- **No names, places, organisations, numbers, ids or quoted phrases** from the failing inputs, in code, prompts, rules or tests of the runtime path. Test fixtures may contain them.
- **No gold labels or expected answers** reachable at run time.
- **No branches** that only the failing examples take.
- **Thresholds come from a stated principle** or a sweep on non-held-out data. They're never tuned until the failures flip.

## 5. Check the fix for leaked words

Before you call the fix done, check it mechanically:
1. **List the distinctive words in the failing inputs:** names of people, places and organisations, handles, numbers, ids, and unusual phrases. Leave out ordinary words.
2. **Search the lines the fix adds** (`git diff`) for each one, case-insensitively. Ignore words the repository already used before the change.
3. **Show the user every hit** with its file and line. For each one, either remove it and generalize, or explain why it's a genuine general term (for example, a field name the schema already uses).

Don't hide a hit by rewording it, for example spelling a name differently or describing it so closely that only that example matches.

## 6. Prove it

Run all three sets before and after the fix. If a run costs money, estimate the cost first and ask.

| Set | Before | After |
|---|---|---|
| Failures (fix set) | 0 / n | ? / n |
| Held-out | ? | ? |
| Regression | n / n | ? / n |

The verdict:
- **A general fix:** the failures improve, the held-out set improves or stays level where nothing was failing, and the regression set doesn't drop.
- **Overfit:** the failures improve, but the held-out set doesn't improve on the same kind of mistake. Say so plainly, then go back to step 3.
- **A trade-off:** the regression set drops. Show the cases that broke, and ask the user before keeping it.

## Report

End with:
- each failure group, its cause, and the fix in one line;
- the table above;
- the leak check result: clean, or each hit with its justification;
- what's still failing, and why.

Don't report "all failures fixed" without the held-out row.
