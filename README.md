# Terminal Timeout Enforcement for LLM Terminals

This project enforces a timeout on all terminal commands issued by LLMs (such as in Cursor, VSCode, or Windsurf) to prevent runaway or stalled processes and to teach LLMs the correct command format.

## Purpose

- **Prevent runaway commands:** Any command run from an LLM terminal must complete within a user-specified timeout or it will be killed.
- **Teach LLMs proper command syntax:** If the timeout or command is missing/invalid, the script outputs clear, LLM-friendly instructions.
- **Easy to enable/disable:** Only affects LLM/IDE terminals, and can be removed or bypassed easily if needed.

## How It Works

- All terminal commands must be run as:

  ```
  timeout-run <seconds> <your command>
  ```

  Example:

  ```
  timeout-run 10 docker compose up -d
  timeout-run 5 curl.exe -s http://localhost:49477/patterns/names
  ```

- If the first argument is not a positive integer, or if the command is missing, the script prints a detailed error and usage guide.
- The script detects if it is running in a supported LLM/IDE terminal (Cursor, VSCode, Windsurf) using environment variables (e.g., `$env:TERM_PROGRAM`, `$env:CURSOR_SESSION`, `$env:WIND_SURF_SESSION`).
- Aliases or profile functions can be set up to intercept all commands in these environments and require the timeout-run wrapper.

## Installation

1. Copy `timeout-run.ps1` to a directory in your system `PATH` (e.g., `C:\tools\cursor-llm-utils\`).
2. Add the provided PowerShell profile snippet to your PowerShell profile (see `profile_snippet.ps1`).
3. Restart your terminal or reload your profile.

## Removal/Disabling

- To disable, simply comment out or remove the profile snippet from your PowerShell profile.
- Alternatively, set an environment variable (e.g., `$env:LLM_TIMEOUT_DISABLE=1`) to bypass the enforcement logic.
- You can always open a non-LLM terminal (not Cursor/VSCode/Windsurf) to avoid the wrapper.

## Troubleshooting

- If you are locked out of your terminal, open a new terminal outside of Cursor/VSCode/Windsurf and remove or comment out the profile snippet.
- The script is designed to be safe and only affect LLM/IDE terminals.

## Extending

- To add support for more IDEs or LLM environments, update the detection logic in the profile snippet.
- To intercept more commands, add more aliases in the profile snippet.

---

**This system is designed to protect your workflow and teach LLMs best practices for safe, reliable terminal automation.**
