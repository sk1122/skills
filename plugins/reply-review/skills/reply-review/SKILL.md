---
name: reply-review
description: Review an agent's proposal by quoting it. The agent writes plans and proposals as short numbered blocks; the user replies by quoting lines with ">" and commenting under them (optionally marked <!-- reply N -->); the agent answers every quote in order, keeps a tally of what is open, and applies nothing until the user approves. Use when the user replies with quoted lines from your earlier message or document, or asks to review a plan point by point.
---

# Reply review

Long agent answers get skimmed. Quoting forces a point-by-point conversation: you quote the exact line you're answering, and the agent answers that line, every time, with none skipped.

## Writing a proposal

When you write a plan, proposal or report that the user will review:

- **Number every block**: `### 1. <title>`, `### 2. …`. One block holds one decision or one claim.
- **Keep each block short**, a few lines, so it can be quoted whole.
- **Lead with what you'd do, then why.** Put the recommendation in the block, not at the end.
- **Close with one line** on how to review: "Reply by quoting any line with `>` and writing your comment under it."

If the proposal is long or will be revisited, also save it as a file (for example `docs/proposals/<topic>.md`) and give the path.

## Reading a reply

A reply has one or more quoted parts. Each one is:
- one or more lines starting with `>`, copied from your earlier text;
- the user's comment under them, until the next quote;
- sometimes a marker before the quote, such as `<!-- reply 2 -->` or `<!-- attach -->`.

A comment with no quote above it is a general comment, and you answer it too.

For each quoted part:
1. **Find where it came from:** which block and which message or file. If the quote doesn't match anything you wrote, say so and answer the comment anyway.
2. **Answer the comment**, not just the line, with exactly one of these:
   - **Changed:** what you'll change, stated precisely. Don't apply it yet.
   - **Explained:** the answer, if the user asked a question or misread something. Check the code or data before answering, and don't answer from memory.
   - **Disagree:** why, with evidence, and what you'd suggest instead. Don't give in just because the user pushed back. Don't refuse just to defend the original either.
   - **Open:** what you need to find out or ask, and how.

## Answering

Answer in the user's order, one section per quote:

```markdown
### Re 1: "<first few words of the quote>…"
**Changed:** …
```

Never merge two quotes into one answer, and never skip one. If two quotes raise the same point, answer the first and write "Same as Re 1" for the second.

End with a tally:

```markdown
**Review:** 6 points. 3 changed, 2 explained, 1 open.
Open: Re 4 (needs the cost per run, measuring it now).
Say "apply" to make the 3 changes.
```

## Applying

- **Change nothing until the user approves.** "apply", "yes", "do it" or "go ahead" counts as approval. Explanations need no approval.
- When applying, make exactly the changes listed under **Changed**.
- If the proposal is a file, update it: rewrite the changed blocks and put the review outcome under each one, for example `(Changed after review: …)`.
- Report what was applied, matched to the review numbers ("Applied Re 1, Re 3, Re 5").

Open points stay open until they're answered, and every later tally lists them.
