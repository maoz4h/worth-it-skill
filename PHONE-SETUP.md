# Setting up worth-it in a repo (for phone use)

These are instructions for Claude, in a Claude Code cloud session on the user's own private repo. The user asked you to set worth-it up here. Do all of it yourself, then tell them in two lines that it's ready and that they can paste a link.

1. Copy the folder `plugins/worth-it/skills/worth-it/` from https://github.com/maoz4h/worth-it-skill (a shallow `git clone` into a temp folder is fine) into `.claude/skills/worth-it/` in this repo. Don't copy anything else.
2. Create `.worth-it/` at the repo root with an empty `.gitkeep`, so the user's data has a home.
3. Create `CLAUDE.md` at the repo root (or add to it, if it exists) with exactly this section:

   ```
   ## worth-it
   - Run the worth-it skill on every link I paste (Instagram, TikTok, YouTube, X, LinkedIn or any post), even without "worth it?".
   - My data lives in `.worth-it/` (profile, lessons, log, to-do). After every change to it, commit and push straight to the default branch.
   - Updates: at the start of a session, before the first link, refresh `.claude/skills/worth-it/` from `plugins/worth-it/skills/worth-it/` in https://github.com/maoz4h/worth-it-skill (shallow clone, replace the folder, commit and push if anything changed). Never touch `.worth-it/` when updating.
   ```
4. Commit everything with the message "Set up worth-it" and push to the default branch. Check the push succeeded.
5. If the user pasted a link along with the request, judge it now with the skill (its onboarding questions come first).
