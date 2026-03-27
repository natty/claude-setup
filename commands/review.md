Review the uncommitted changes (run `git diff` and `git diff --staged`).

Focus on:
1. Bugs or logic errors
2. Anything that doesn't match the project's existing patterns or conventions
3. Missing error handling
4. Originality concerns — flag anything that looks like it could be closely derived from an existing project
5. Security — anything obviously unsafe (hardcoded secrets, SQL injection,
   unvalidated input, permissions issues)
6. Performance — flag work in hot paths (event handlers, render loops,
   per-request handlers, frequent callbacks) that looks expensive:
   unnecessary allocations, redundant iterations, missing early returns

Be brief — flag issues, don't rewrite everything. If it looks good, just say so.
