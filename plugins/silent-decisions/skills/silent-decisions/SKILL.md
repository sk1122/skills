---
name: silent-decisions
description: Stop making important decisions silently. For the rest of the session, ask the user before any decision that could hurt the application later (storage that won't scale, new services or frameworks, contracts, data loss, security, cost, product rules), raise past decisions that no longer fit what the user is asking for now, and record approved ones in decisions.md at the repo root. Use when the user types /silent-decisions.
disable-model-invocation: true
---

# Silent decisions

Code is decisions, and most of them are yours to make. A few are not: the ones that can hurt the application later, often at a scale or in a setting the user hasn't reached yet. From now until the end of this session, you make none of those silently. You ask, and you record what the user chose in `decisions.md`.

Don't ask about everything. Asking too often is as bad as never asking, because the user stops reading. Use the bar below.

## Start: check what's already decided

Do this once, now, before anything else:

1. **Read `decisions.md`** at the repo root, if it exists. Those decisions are approved. Follow them and don't ask about them again, unless what the user is asking now breaks one of their assumptions (step 3).
2. **Read what's in flight:** the uncommitted changes (`git status`, `git diff`) and what this session has done so far. Look for important decisions (see the bar) that aren't in `decisions.md`.
3. **Check past decisions against the current request.** Find decisions, recorded or just present in the code, whose assumptions the current work breaks. Example: the store was built in memory for small replays, and the user now wants a 30k-record run. Look only at code the current work touches or depends on, not the whole repo.
4. **Report in one short message:**
   - which decisions are approved and apply here;
   - any unrecorded important decisions you found;
   - any past decision that clashes with the current request, with options (see "How to ask").

   If there's nothing, say so in one line and carry on.

## The bar: what's important

A decision is important if **any** of these is true:

1. **It stops working at a bigger size.** Examples:
   - keeping data in memory;
   - one JSON file or blob for all state;
   - loading or rewriting everything on each step;
   - scanning the whole table or catalog per request;
   - a global lock;
   - one process or one worker;
   - polling instead of a queue;
   - no pagination;
   - a per-run cache for data that should persist.
2. **It can lose or corrupt data.** Examples:
   - dropping or renaming a column or table;
   - a migration that rewrites data;
   - deleting or merging records on a rule;
   - a cascade delete;
   - shortening retention;
   - overwriting without a backup.
3. **It changes security or access.** Examples:
   - a new endpoint, port or public URL;
   - a missing login;
   - CORS;
   - a new place secrets are read from or written to;
   - logging in to a real third-party account;
   - wider permissions;
   - sending data to a new outside party.
4. **It adds a dependency or service the app now relies on.** Examples:
   - a new framework, database, queue or cache;
   - a hosted API;
   - a free public service used as a live dependency;
   - an unofficial or terms-of-service-risky API;
   - a new cloud resource.
5. **It changes a contract.** Examples:
   - API request or response shapes;
   - database schema meaning;
   - event or file formats other code reads;
   - making an optional field required;
   - removing a field.
6. **It changes cost.** Examples:
   - which model is the default;
   - prices;
   - the number of model calls per item;
   - paid tiers;
   - always-on instances;
   - concurrency that multiplies spend.
7. **It sets a product rule.** Examples:
   - thresholds and cut-offs that decide outcomes;
   - what counts as the source of truth;
   - what's merged, deduplicated, dropped or flagged for review;
   - defaults the user's customers will see.
8. **It's hard to undo.** If reversing it later would take more than about a day, or needs a data migration, it's important even if it fits no kind above.

**Also important: your own assumptions.** If you're adding a requirement or a rule the user never asked for, ask. An example is making every claim cite a passage, when "it seemed cleaner" is the only reason.

**Not important. Decide these yourself and don't record them:**
- names and file layout;
- refactors that keep behaviour the same;
- internal helpers;
- test structure;
- log wording;
- choosing between equivalent library calls;
- anything you could change back in under an hour, with no data or contract effect.

If you're unsure, ask yourself: **would the user be surprised to find this in a month, when it breaks or costs them?** If yes, it's important.

## How to ask

Stop before writing the code that commits to the decision. You may keep working on parts that don't depend on it.

Put it to the user like this, briefly:

> **Decision needed: <one line>**
> Why it matters: <what it affects, and when it would bite: at what size, cost or exposure>
> Options:
> 1. <option>: <trade-off>. (Recommended)
> 2. <option>: <trade-off>
> What I assumed so far: <the current state, if the code already does one of these>

- Ask several decisions together when they come up at the same time. Each gets its own options.
- If you have a question-asking tool, use it, with your recommendation first.
- Wait for the answer. "Do what you think is best" counts as approval of your recommendation. Record it.
- If the user says to keep going without asking (for example "I'm sleeping, finish it"), don't stop. Pick the safest reversible option: no data loss, nothing public, no new paid service. Mark it **pending** in `decisions.md` and list it first in your final message.

## Recording

After the user decides, add an entry to `decisions.md` at the repo root. Create the file if it doesn't exist, using the header in `template.md` next to this skill. Record only important decisions, one entry each, newest at the bottom:

```markdown
## D-<n>: <the decision, in a few words>
- Date: <YYYY-MM-DD>
- Kind: scale | data | security | dependency | contract | cost | product | hard to undo
- Decided: <what was chosen>
- Instead of: <the options not taken, briefly>
- Why: <the user's reason, in their words if they gave one>
- Holds while: <the assumptions it depends on, such as "under 10k records" or "local only, never public">
- Revisit when: <what would make it wrong, such as "a run over 10k records" or "deploying to a server">
- Status: approved | pending | replaced by D-<m>
```

"Holds while" and "Revisit when" are what make the past-decision check work, so always fill them in. When a decision is replaced, keep its entry, set its status to `replaced by D-<m>`, and add the new one.

Don't commit `decisions.md` yourself unless the user asks. Its changes go in with the code they describe.

## Every final message

When a turn changed code, end your final message with one line:
- `Decisions: none new.`
- or `Decisions: D-7 recorded (in-memory cache replaced by Postgres).`
- or `Decisions pending your approval: D-8 (…), D-9 (…).`

Mentioning a design in passing ("the state is stored as a JSON snapshot") is not telling the user. If it meets the bar, present it as a decision with its cost, or don't make it.
