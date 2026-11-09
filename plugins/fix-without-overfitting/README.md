# fix-without-overfitting

Fixes a failing pipeline (an LLM, a prompt, a classifier, extraction or ranking) from its real failures without overfitting to them. It writes down the failures, freezes a held-out set before any change, fixes the cause rather than the examples, checks for names, places and ids from the failing examples that leaked into the fix, and proves the gain on data the fix never saw. Use `/fix-without-overfitting`, or ask to fix wrong outputs with failure cases first.

See the [repository README](../../README.md) for installation.
