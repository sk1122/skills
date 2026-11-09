# fix-without-overfitting

Makes the agent fix the cause of a failure instead of making the failing cases pass. Coding agents are known to "special-case" when stuck: hard-coding an expected value, adding an `if` for the one input that fails, nudging a timeout until a flaky test goes green, or editing the test. This skill rules those out. It has the agent set up a check on inputs the fix wasn't written against before changing anything, look over its own diff for values copied from the failures, and show before-and-after results on the failures, the unseen cases and the cases that already worked. It works for ordinary code and for LLM, data and ranking pipelines.

See the [repository README](../../README.md) for installation.
