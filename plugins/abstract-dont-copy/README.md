# abstract-dont-copy

Makes the agent find the mechanism behind a bug before fixing it. Every hole is one instance of something that makes that kind of hole easy to create, such as authorization written by hand in each handler. Patch the one hole and the same cause opens the next one somewhere else. The agent reproduces the bug, names the cause in one sentence without naming the file, searches for every other place it shows up, and sorts each hit as a hole, safe, or intended. It then fixes at the lowest level that closes the whole class, and adds a guard that fails before the fix. It checks with you before a bigger change, and patches serious holes in the meantime. A one-off slip gets a three-line note, not a ceremony.

See the [repository README](../../README.md) for installation.
