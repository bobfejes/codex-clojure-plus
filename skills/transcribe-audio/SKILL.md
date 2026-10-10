---
name: transcribe-audio
description: Transcribe local audio or video files to timestamped SRT with whisper.cpp, with optional plain-text and JSON outputs and first-run setup. Use for offline speech-to-text from files; do not use for live microphone capture or cloud transcription services.
---

# Transcribe Audio

Use only the bundled Whisper.cpp workflow. It converts media to 16-bit mono WAV with `ffmpeg`, transcribes locally with `whisper-cli`, and writes `<input-basename>.transcript.srt` beside each input:

```bash
"<skill-directory>/scripts/transcribe-audio" <audio-file> [...]
```

SRT is the only default output. The default model is `small.en`, matching the established output in this project. Original media is never changed, temporary WAV files are removed, and existing selected outputs are protected unless the user explicitly requests replacement with `--force`.

## First-run setup

Check readiness with:

```bash
"<skill-directory>/scripts/transcribe-audio" --status
```

If `whisper-cli`, `ffmpeg`, or the selected model is missing, tell the user what will be installed or downloaded before running setup. Setup uses Homebrew for the two executables and downloads the model from the official Whisper.cpp Hugging Face repository into the user's cache:

```bash
"<skill-directory>/scripts/transcribe-audio" --setup --model small.en
```

Homebrew itself is a prerequisite. If it is absent, stop and ask before installing it; do not execute a remote Homebrew installer implicitly. Once installed, transcription is local and needs neither an OS speech-service permission nor network access.

## Model choice

Use `small.en` unless the user asks for a different speed, accuracy, or language tradeoff. Offer choices when setup is needed or when the user asks:

| Model | Download | Use |
|---|---:|---|
| `tiny.en` | 75 MiB | Fastest English, lowest accuracy |
| `base.en` | 142 MiB | Faster English |
| `small.en` | 466 MiB | Default English balance; matches prior transcripts |
| `medium.en` | 1.5 GiB | More accurate English, slower |
| `small` | 466 MiB | Default multilingual option |
| `medium` | 1.5 GiB | More accurate multilingual option |
| `large-v3-turbo-q5_0` | 547 MiB | Strong multilingual model with quantization |

Models containing `.en` are English-only. For multilingual models, use `--language auto` unless the user supplies a language code. Run `scripts/transcribe-audio --list-models` for the same choices at the command line.

## Invocation

Before invocation, resolve each input to an exact local path and confirm it exists. Quote paths. Useful options are:

- `--model NAME` to select an installed model.
- `--language CODE|auto` for multilingual recognition.
- `--prompt TEXT` to seed project names, acronyms, or specialized vocabulary.
- `--txt` to additionally write `<input-basename>.transcript.txt`.
- `--json` to additionally write detailed `<input-basename>.transcript.json` output.
- `--gpu` to request GPU acceleration; failures retry once on CPU automatically. CPU is the portable default.
- `--force` only when the user explicitly requested replacing existing selected outputs.

Report every transcript path written. Run `scripts/transcribe-audio --help` for complete syntax. Do not add another transcription engine as a fallback.
