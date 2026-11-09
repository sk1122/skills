# skills

A few skills I kept wishing I had while building with Claude Code and Codex. Each one is a single `SKILL.md` with plain instructions and no code. The agent does the work with the tools it already has.

| Skill | What it's for |
|---|---|
| [silent-decisions](plugins/silent-decisions/skills/silent-decisions/SKILL.md) | Make the agent ask before choices that come back to bite you |
| [fix-without-overfitting](plugins/fix-without-overfitting/skills/fix-without-overfitting/SKILL.md) | Fix bad outputs without just teaching the system its own examples |
| [priced-in](plugins/priced-in/skills/priced-in/SKILL.md) | Check whether a Polymarket market moved before the news did |
| [reply-review](plugins/reply-review/skills/reply-review/SKILL.md) | Review a plan by quoting the lines you disagree with |

## Install

Claude Code:

```
/plugin marketplace add sk1122/skills
/plugin install silent-decisions@sk1122
```

The others install the same way (`priced-in@sk1122` and so on). Installed as a plugin, a skill's command is `/<plugin>:<skill>`, for example `/silent-decisions:silent-decisions`.

You can also just copy the folders, and then the command is the skill's name, like `/silent-decisions`:

```bash
git clone https://github.com/sk1122/skills
cp -r skills/plugins/*/skills/* ~/.claude/skills/   # Claude Code
cp -r skills/plugins/*/skills/* ~/.codex/skills/    # Codex
```

## silent-decisions

Agents make a lot of small choices, and that's fine. The problem is the few that matter later. A store kept in memory works for the demo and falls over on real data. Other examples are a migration that drops a column, an endpoint that went public without a login, a free API the app now quietly depends on, or a default model that doubles what every run costs.

These usually go by unnoticed. Even when the agent mentions them, it's as a description of how things are, not as a choice you could say no to. You find out weeks later.

Run `/silent-decisions` at the start of a session. From then on the agent:

- **Checks what's already decided.** It looks at past decisions and at the code you're touching, and flags anything that no longer fits what you're asking for now. One example: "this was built in memory for small runs, and you want a nightly import of 2M rows. Change it first?"
- **Stops and asks before a decision that matters.** That covers scale, data loss, security, new dependencies or services, API and schema contracts, cost, product rules, and anything hard to undo. It gives you two or three options and its pick. Naming, refactors and other everyday choices it just makes.
- **Writes down what you chose** in `decisions.md` at the repo root, with what the choice depends on and when to revisit it. That's how the next session, or a different agent, knows to bring it up again.

If you tell it to carry on without you, it picks the safest option it can undo, marks it pending, and tells you when you're back.

An entry looks like this:

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

## fix-without-overfitting

When an LLM pipeline gets something wrong, the quick fix is to make those exact examples pass, by adding a line to the prompt about the name that kept failing or nudging a threshold until the bad cases flip. It looks fixed and it isn't.

This skill makes the agent write the failures down, set aside some data it won't look at, fix the cause instead of the cases, and check that no names or IDs from the failing examples ended up in the fix. Then it shows before-and-after numbers on the failures, on the set-aside data, and on cases that already worked. If only the failures improved, it says so.

## priced-in

Did the market know before the news broke? The agent:

1. Pins down when the news actually went public, using news sites and X. It reads posts through [mdfromx.com](https://mdfromx.com).
2. Looks for earlier leaks and hints.
3. Pulls Polymarket prices and trades around that time.
4. Explains each move.

You get a verdict of priced in, partly priced in, or a surprise, with sources for every time it quotes. It can also score your own model's forecasts against the market.

## reply-review

Long plans get skimmed. With this skill the agent writes plans as short numbered blocks. You reply by quoting the lines you have thoughts on (`> like this`) and writing under them. The agent answers each quote in order, and every answer is one of four things: changed, explained, disagree, or still open. It ends with what's still open and changes nothing until you say so.

## License

Apache-2.0
