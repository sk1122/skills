# skills

Skills for coding agents, packaged as a Claude Code plugin marketplace.

| Plugin | What it does |
|---|---|
| [silent-decisions](plugins/silent-decisions/skills/silent-decisions/SKILL.md) | Stops the agent from making important decisions silently. |

## Install

In Claude Code:

```
/plugin marketplace add sk1122/skills
/plugin install silent-decisions@sk1122
```

Or copy the skill folder into your own skills, where it becomes `/silent-decisions`:

```bash
git clone https://github.com/sk1122/skills && cp -r skills/plugins/silent-decisions/skills/silent-decisions ~/.claude/skills/
```

## silent-decisions

Code is decisions, and an agent should make most of them by itself. A few it shouldn't make alone. These are the ones that work today but hurt the application later, often at a size or in a setting the user hasn't reached yet:

- an in-memory store or one JSON file for all state, fine for a demo and slow on real data;
- a migration that drops a column;
- a new public endpoint with no login;
- a free public API that the app now depends on;
- a new default model that changes what every run costs;
- a rule that decides which records get merged or deleted.

Agents tend to make these choices quietly. When they mention them at all, it's in passing, as how things are rather than as a choice you could have turned down. You find out weeks later, when the system slows down or the bill arrives.

Type `/silent-decisions` (or `/silent-decisions:silent-decisions` when installed as a plugin) at the start of a session. For the rest of that session, the agent:

1. **Checks past decisions first.** It reads `decisions.md` and your uncommitted changes, then looks for earlier decisions that no longer fit what you're asking for now. For example: "this store was built in memory for small runs, and you've asked for a 50k-record import. Should we change it?"
2. **Asks only about important decisions.** These are decisions that:
   - won't scale;
   - can lose data;
   - change security or access;
   - add a dependency or service;
   - change a contract;
   - change cost;
   - set a product rule;
   - are hard to undo.

   It also asks when it's about to add a requirement you never asked for. Names, refactors and anything you could undo within an hour it decides on its own.
3. **Asks briefly.** It gives the decision, why it matters and when it would hurt, and two or three options with its recommendation first. Then it waits.
4. **Records what you chose** in `decisions.md` at the repo root, to commit with the code. Each entry says what the decision depends on and when to revisit it. That's how later sessions, and other agents, know to raise it again.
5. **Ends each turn that changed code with one line:** `Decisions: none new.`, `D-7 recorded.` or `Decisions pending your approval: …`.

If you tell it to keep going without you, it doesn't stop. It picks the safest option it can undo, marks it pending, and lists it first when you're back.

### What goes in decisions.md

```markdown
## D-3: Keep job state in Postgres, not in memory
- Date: 2026-11-09
- Kind: scale
- Decided: one row per job in Postgres
- Instead of: an in-memory map saved to a JSON file on exit
- Why: imports will reach 50k records; memory and restarts can't hold that
- Holds while: one database, under ~10M jobs
- Revisit when: jobs need to be shared across regions
- Status: approved
```

Only decisions of this size go in. Everyday code choices don't, because a list of everything stops being read.

## License

Apache-2.0
