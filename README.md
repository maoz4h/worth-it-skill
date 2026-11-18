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

To get updates later: `git -C ~/.claude/skills/worth-it pull`. Your profile, lessons and log stay on your computer; they're in `.gitignore` and never pushed.

**From your phone:** make your own **private** repo, put this folder at `.claude/skills/worth-it/` in it, remove `profile.md`, `lessons.md` and `log.md` from its `.gitignore` (so your phone sessions keep them), and open a Claude Code cloud session on that repo from the Claude app.

## Use

Paste a link into Claude Code, with or without "worth it?". Several links at once work too.

- **It learns from you:** if you disagree with a verdict ("too harsh", "this is actually useful"), it saves a rule to `lessons.md` and applies it next time.
- **It keeps a log** in `log.md` of every link and verdict.

## Limits

- Instagram and others sometimes block downloads from servers or ask for a sign-in. On a Mac the script falls back to your browser's cookies (read locally). Otherwise Claude reads the page text or asks you for a screenshot.
- Claude reads the transcript and frames; it doesn't watch the video.
