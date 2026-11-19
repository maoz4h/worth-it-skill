# worth-it

A [Claude Code](https://claude.com/claude-code) plugin that filters social-media buzz. Paste a link to an Instagram reel, a TikTok, a YouTube video, an X post or a LinkedIn post, and Claude tells you in a few lines whether it deserves your time:

**Focus**, **Later** or **Skip**, whether the idea behind it is sound (with the real source, so you never need to "comment X and I'll DM you"), ideas for your own work, and how to do it.

How it works: it downloads the video, transcribes it locally with [whisper.cpp](https://github.com/ggml-org/whisper.cpp) (any language), and pulls up to 16 frames. Claude reads the transcript, looks at the frames, checks the claims against the original source, and relates it to what you told it about yourself. The video and audio are deleted afterwards.

## Install

In Claude Code, on a Mac or Linux computer:

```
/plugin marketplace add maoz4h/worth-it-skill
/plugin install worth-it@worth-it-skill
```

Start a new session and paste a link. The first time, Claude asks a few quick questions (your work, your interests, what you never want to see, answer language, automatic updates, and whether you want it on your phone too) and saves your answers, so verdicts fit you. Say "update my profile" to change them.

The first link takes a few minutes: it installs yt-dlp, ffmpeg and whisper.cpp (with Homebrew on a Mac) and downloads a 550 MB speech model.

## Updates

Say yes to automatic updates during onboarding, and new versions arrive by themselves, a few minutes after you start a Claude Code session. After an update, your next verdict ends with one line saying what's new. What changed is in [CHANGELOG.md](plugins/worth-it/skills/worth-it/CHANGELOG.md).

Without automatic updates: `/plugin` → Marketplaces → worth-it-skill → Update marketplace.

Your profile, lessons, log and to-do live in the plugin's own data folder on your computer (`~/.claude/plugins/data/`). Updates never touch them, and they're never uploaded anywhere.

**Installed it with `git clone` before?** Install the plugin as above. On its first run it moves your profile, lessons, log and to-do over, then you can delete `~/.claude/skills/worth-it`.

## Use

Paste a link into Claude Code, with or without "worth it?". Several links at once work too.

- **It learns from you:** if you disagree with a verdict ("too harsh", "this is actually useful"), it saves a rule and applies it next time.
- **It checks itself** before every answer: format, a real source for every claim, fit to your profile, and that the log and to-do were saved.
- **It keeps a log** of every link and verdict.
- **It keeps a to-do list** of the action items from every Focus and Later verdict. Ask "what's open?" to see them, "done <name>" to tick one off.
- **It reminds you weekly:** once a week, the next verdict also lists your open to-do items, oldest first, so good ideas don't get forgotten. Say "weekly review" any time. On the phone setup you can also schedule a real Sunday reminder with `/schedule`.

## Use it from your phone

**Easiest, if you have a computer:** install the plugin there, then say "set up my phone" (onboarding also offers it). Claude creates a private repo, copies your profile and history into it, and opens the one GitHub page where you tap **Install**. You need a free GitHub account.

**Phone only:** Claude Code on the phone runs in cloud sessions on a GitHub repo, so it needs a free GitHub account and one private repo. Setup is about 5 minutes, once:

1. On github.com: **+** → **New repository**, name it `my-worth-it`, choose **Private**, tick **Add a README**, create it.
2. Give Claude access: open https://github.com/apps/claude/installations/select_target, pick your account, **Only select repositories** → `my-worth-it` → **Install**.
3. In the Claude app, open **Code**, start a new session on `my-worth-it`, and paste:

   > Set up worth-it here by following https://github.com/maoz4h/worth-it-skill/blob/main/PHONE-SETUP.md

That's it. From then on, open a session on `my-worth-it` and paste links. Each session checks for a newer worth-it first, so the phone stays up to date too. The first link in a session takes a few minutes while the tools install.

## Limits

- Instagram and others sometimes block downloads from servers or ask for a sign-in. On a Mac the script falls back to your browser's cookies (read locally). Otherwise Claude reads the page text or asks you for a screenshot.
- Claude reads the transcript and frames; it doesn't watch the video.
