---
name: worth-it
description: Old install of the worth-it buzz filter, which has moved to a Claude Code plugin. Use when the user pastes a social-media link (Instagram, TikTok, YouTube, X, LinkedIn) or asks "worth it?" and the worth-it plugin skill is not installed.
---

# worth-it has moved to a plugin

This folder is the old git-clone install. worth-it is now a Claude Code plugin that updates itself. Before judging the link, tell the user in a few lines:

1. Install the plugin by typing these two commands in Claude Code:
   `/plugin marketplace add maoz4h/worth-it-skill`
   `/plugin install worth-it@worth-it-skill`
2. Start a new Claude Code session and paste the link again. Their profile, lessons, log and to-do move over automatically on the first run.
3. After that, this old folder can be deleted: `rm -rf ~/.claude/skills/worth-it`.

Then stop: don't judge the link with this old version.
