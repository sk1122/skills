# silent-decisions

Stops a coding agent from making important decisions silently. Run `/silent-decisions` at the start of a session. From then on, the agent asks before any choice that could hurt the application later, such as storage that won't scale, data loss, security, a new dependency or service, a contract change, cost, a product rule, or anything hard to undo. It also raises past decisions that no longer fit what you're asking for now, and it records the decisions you approve in `decisions.md` at the repo root. Everyday code choices it makes on its own and doesn't record.

See the [repository README](../../README.md) for installation and an example `decisions.md` entry.
