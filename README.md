# skills

A few skills I kept wishing I had while building with Claude Code and Codex. Each one is a single `SKILL.md` with plain instructions and no code. The agent does the work with the tools it already has.

| Skill | What it's for |
|---|---|
| [silent-decisions](plugins/silent-decisions/skills/silent-decisions/SKILL.md) | Make the agent ask before choices that come back to bite you |
| [fix-without-overfitting](plugins/fix-without-overfitting/skills/fix-without-overfitting/SKILL.md) | Fix the cause of a failure, not just the failing cases |
| [abstract-dont-copy](plugins/abstract-dont-copy/skills/abstract-dont-copy/SKILL.md) | Fix what let a bug happen, everywhere it happened |
| [priced-in](plugins/priced-in/skills/priced-in/SKILL.md) | Check whether a Polymarket market moved before the news did |
| [reply-review](plugins/reply-review/skills/reply-review/SKILL.md) | Review a plan by quoting the lines you disagree with |

## Install

The skills are plain `SKILL.md` files in the shared Agent Skills format, so most agents can use them. Pick yours.

**Claude Code**

```
/plugin marketplace add sk1122/skills
/plugin install silent-decisions@sk1122
```

The others install the same way (`priced-in@sk1122` and so on). As a plugin, a skill's command is `/<plugin>:<skill>`, for example `/silent-decisions:silent-decisions`.

**Codex**

```bash
codex plugin marketplace add sk1122/skills
codex plugin add silent-decisions@sk1122
```

**Gemini CLI**

```bash
gemini extensions install https://github.com/sk1122/skills
```

That installs all five.

**Claude desktop and claude.ai**

Download the zips from the [latest release](https://github.com/sk1122/skills/releases/latest) and upload each one under Settings → Capabilities → Skills. To build them yourself, run `./package.sh`.

**Cursor, GitHub Copilot, or anything else that reads skills**

Copy the folders from `skills/` into the place your tool reads skills from:

```bash
git clone https://github.com/sk1122/skills
cp -RL skills/skills/* ~/.claude/skills/     # Claude Code, without the plugin
cp -RL skills/skills/* ~/.codex/skills/      # Codex, without the plugin
cp -RL skills/skills/* .cursor/skills/       # Cursor, per project
cp -RL skills/skills/* .github/skills/       # GitHub Copilot, per project
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

When a test fails, there's a cheap way to make it pass: hard-code the expected value, add an `if` for that one input, bump the timeout until the flaky test goes green, or just edit the test. Coding agents do this more than you'd think when they get stuck. With LLM pipelines it looks like a prompt line about the exact example that went wrong.

This skill makes the agent fix the cause instead. Before touching anything, it sets up a check on inputs the fix won't have seen: new test cases with different values for ordinary code, or a held-back sample for data and LLM pipelines. After the fix, it searches its own diff for values copied from the failures and shows before-and-after results on the failures, the unseen cases, and the cases that already worked. If only the failures improved, it says so.

## abstract-dont-copy

A bug report names one hole: Bob can read Alice's order. Usually the same cause left others nearby, like cancelling someone else's order or reading their invoice, because every handler checks access by hand and some forget. Patch the one in the report and the rest stay open.

With this skill the agent reproduces the bug, then names the cause in one sentence without naming the file. It searches for every other place that cause shows up, and sorts each hit as a hole, safe, or intended (an admin route that reads anyone's order on purpose). Then it fixes at the smallest level that closes all of them, and adds a test that finds the cases itself, shown failing before the fix. Before a bigger change it checks with you, and patches the serious holes while it waits. A one-off typo gets a three-line note, not the full treatment.

It pairs with fix-without-overfitting: that one stops the fix from cheating on the failing cases, and this one makes sure the fix reaches every case.

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
