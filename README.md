# worth-it

A [Claude Code](https://claude.com/claude-code) skill that filters social-media buzz. Paste a link to an Instagram reel, a TikTok, a YouTube video, an X post or a LinkedIn post, and Claude tells you in a few lines whether it deserves your time:

**Focus**, **Later** or **Skip**, whether the idea behind it is sound (with the real source, so you never need to "comment X and I'll DM you"), ideas for your own work, and how to do it.

How it works: `ingest.sh` downloads the video, transcribes it locally with [whisper.cpp](https://github.com/ggml-org/whisper.cpp) (any language), and pulls up to 16 frames. Claude reads the transcript, looks at the frames, checks the claims against the original source, and relates it to what you told it about yourself. The video and audio are deleted afterwards.

## Install

On a Mac or Linux computer:

```bash
git clone https://github.com/maoz4h/worth-it-skill.git ~/.claude/skills/worth-it
```

The first time you paste a link, Claude asks you four quick questions (your work, your interests, what you never want to see, answer language) and saves them to `profile.md`, so verdicts fit you. Say "update my profile" to change it.

The first run installs what's missing (yt-dlp, ffmpeg, whisper.cpp; with Homebrew on a Mac) and downloads a 550 MB speech model, so it takes a few minutes. To do that ahead of time: `~/.claude/skills/worth-it/ingest.sh --setup`.

To get updates later: `git -C ~/.claude/skills/worth-it pull`. Your profile, lessons, log and to-do list stay on your computer; they're in `.gitignore` and never pushed.

## Use it from your phone

Claude Code on the phone runs in a cloud session on one of your GitHub repos, so the skill needs a repo of its own:

1. On github.com, create a new **private** repo (e.g. `my-worth-it`) and tick "Add a README" so it isn't empty. Private, because your profile, lessons and log will live there. Don't fork this repo: a fork of a public repo is public.
2. In the Claude app, open **Code**, start a cloud session on that repo, and paste:

   > Copy the skill from github.com/maoz4h/worth-it-skill into `.claude/skills/worth-it/`. Take profile.md, lessons.md, log.md and todo.md out of its .gitignore. Add a CLAUDE.md that says: run the worth-it skill on every link I paste, then commit and push the log, lessons, to-do and profile. Then commit and push.

3. Paste a link in any session on that repo. The first time, it asks the four onboarding questions and saves your profile.

Each cloud session starts on a fresh machine, so the first link in a session takes a few minutes while the tools and the speech model install.

## Use

Paste a link into Claude Code, with or without "worth it?". Several links at once work too.

- **It learns from you:** if you disagree with a verdict ("too harsh", "this is actually useful"), it saves a rule to `lessons.md` and applies it next time.
- **It keeps a log** in `log.md` of every link and verdict.
- **It keeps a to-do list** in `todo.md`: the action items from every Focus and Later verdict. Ask "what's open?" to see them, "done <name>" to tick one off.

## Limits

- Instagram and others sometimes block downloads from servers or ask for a sign-in. On a Mac the script falls back to your browser's cookies (read locally). Otherwise Claude reads the page text or asks you for a screenshot.
- Claude reads the transcript and frames; it doesn't watch the video.
