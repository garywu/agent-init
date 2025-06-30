#!/usr/bin/env bash
# Task completion notification script with multiple styles

# Detect OS
OS="$(uname -s)"

# Function to show usage
usage() {
  cat <<EOF
Usage: $0 [style]

Notification styles:
  red-alert     Star Trek Red Alert (default)
  bridge        Star Trek Bridge notification
  mission       Mission complete notification
  attention     Simple attention sound
  victory       Victory fanfare
  warning       Warning alarm
  incoming      Incoming transmission
  computer      Computer processing complete
  hero          Heroic completion
  morse         Morse code alert
  custom        Custom message (requires -m flag)

Options:
  -m MESSAGE    Custom message for 'custom' style
  -q            Quiet mode (no visual output)
  -h            Show this help

Examples:
  $0                     # Default red alert
  $0 bridge              # Bridge notification
  $0 custom -m "Tests complete"
EOF
  exit 0
}

# Default values
STYLE="red-alert"
CUSTOM_MESSAGE=""
QUIET=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    ;;
  -m | --message)
    CUSTOM_MESSAGE="$2"
    shift 2
    ;;
  -q | --quiet)
    QUIET=true
    shift
    ;;
  red-alert | bridge | mission | attention | victory | warning | incoming | computer | hero | morse | custom)
    STYLE="$1"
    shift
    ;;
  *)
    echo "Unknown option: $1"
    usage
    ;;
  esac
done

# macOS notification function
notify_macos() {
  case "$STYLE" in
  red-alert)
    say -v Zarvox -r 150 "Red Alert! Red Alert!" &&
      afplay /System/Library/Sounds/Sosumi.aiff &&
      afplay /System/Library/Sounds/Sosumi.aiff &&
      say -v Zarvox "All hands to battle stations. Captain to the bridge. Task complete. Awaiting orders."
    [[ "$QUIET" == "false" ]] && echo "🚨 === RED ALERT: TASK COMPLETE - AWAITING INPUT === 🚨"
    ;;

  bridge)
    afplay /System/Library/Sounds/Submarine.aiff &&
      say -v Samantha "Bridge to Captain. Task completed successfully. Awaiting your command."
    [[ "$QUIET" == "false" ]] && echo "🖖 === BRIDGE: TASK COMPLETE - AWAITING COMMAND === 🖖"
    ;;

  mission)
    say -v Daniel "Mission accomplished. All objectives completed. Standing by for new orders." &&
      afplay /System/Library/Sounds/Glass.aiff
    [[ "$QUIET" == "false" ]] && echo "✅ === MISSION COMPLETE - AWAITING ORDERS === ✅"
    ;;

  attention)
    afplay /System/Library/Sounds/Ping.aiff &&
      afplay /System/Library/Sounds/Ping.aiff &&
      afplay /System/Library/Sounds/Ping.aiff
    [[ "$QUIET" == "false" ]] && echo "🔔 === ATTENTION: TASK COMPLETE === 🔔"
    ;;

  victory)
    afplay /System/Library/Sounds/Hero.aiff &&
      say -v Zarvox "Victory! Mission accomplished. Outstanding performance, Captain." &&
      afplay /System/Library/Sounds/Glass.aiff
    [[ "$QUIET" == "false" ]] && echo "🏆 === VICTORY: TASK COMPLETE === 🏆"
    ;;

  warning)
    afplay /System/Library/Sounds/Basso.aiff &&
      afplay /System/Library/Sounds/Basso.aiff &&
      say -v Zarvox -r 180 "Warning! Warning! Task requires immediate attention. Please respond." &&
      afplay /System/Library/Sounds/Funk.aiff
    [[ "$QUIET" == "false" ]] && echo "⚠️  === WARNING: IMMEDIATE ATTENTION REQUIRED === ⚠️"
    ;;

  incoming)
    afplay /System/Library/Sounds/Blow.aiff &&
      say -v Samantha "Incoming transmission. Task completed. Message awaiting your review." &&
      afplay /System/Library/Sounds/Submarine.aiff
    [[ "$QUIET" == "false" ]] && echo "📡 === INCOMING TRANSMISSION: TASK COMPLETE === 📡"
    ;;

  computer)
    afplay /System/Library/Sounds/Pop.aiff &&
      say -v Victoria "Computer processing complete. All systems nominal. Awaiting instructions." &&
      afplay /System/Library/Sounds/Tink.aiff
    [[ "$QUIET" == "false" ]] && echo "🖥️  === COMPUTER: PROCESSING COMPLETE === 🖥️"
    ;;

  hero)
    afplay /System/Library/Sounds/Hero.aiff &&
      say -v Alex "Heroic task completed! You've saved the day. What's next, Commander?" &&
      afplay /System/Library/Sounds/Hero.aiff
    [[ "$QUIET" == "false" ]] && echo "🦸 === HEROIC: TASK COMPLETE === 🦸"
    ;;

  morse)
    afplay /System/Library/Sounds/Morse.aiff &&
      afplay /System/Library/Sounds/Morse.aiff &&
      afplay /System/Library/Sounds/Morse.aiff &&
      say -v Zarvox -r 120 "S.O.S. Task complete. Urgent response requested." &&
      afplay /System/Library/Sounds/Morse.aiff
    [[ "$QUIET" == "false" ]] && echo "📻 === MORSE: TASK COMPLETE - SOS === 📻"
    ;;

  custom)
    if [[ -z "$CUSTOM_MESSAGE" ]]; then
      echo "Error: Custom style requires -m MESSAGE"
      exit 1
    fi
    say -v Samantha "$CUSTOM_MESSAGE" &&
      afplay /System/Library/Sounds/Glass.aiff
    [[ "$QUIET" == "false" ]] && echo "📢 === $CUSTOM_MESSAGE === 📢"
    ;;
  esac
}

# Linux notification function
notify_linux() {
  # Check if espeak is available
  if command -v espeak &>/dev/null; then
    case "$STYLE" in
    red-alert)
      espeak "Red Alert! Red Alert! Task complete. Awaiting orders." 2>/dev/null
      ;;
    bridge)
      espeak "Task completed successfully. Awaiting command." 2>/dev/null
      ;;
    mission)
      espeak "Mission accomplished. Standing by." 2>/dev/null
      ;;
    attention)
      espeak "Attention. Task complete." 2>/dev/null
      ;;
    custom)
      if [[ -z "$CUSTOM_MESSAGE" ]]; then
        echo "Error: Custom style requires -m MESSAGE"
        exit 1
      fi
      espeak "$CUSTOM_MESSAGE" 2>/dev/null
      ;;
    esac
  fi

  # Try system bell as fallback
  echo -e "\a\a\a"

  # Visual notification
  if [[ "$QUIET" == "false" ]]; then
    case "$STYLE" in
    red-alert) echo "🚨 === RED ALERT: TASK COMPLETE - AWAITING INPUT === 🚨" ;;
    bridge) echo "🖖 === BRIDGE: TASK COMPLETE - AWAITING COMMAND === 🖖" ;;
    mission) echo "✅ === MISSION COMPLETE - AWAITING ORDERS === ✅" ;;
    attention) echo "🔔 === ATTENTION: TASK COMPLETE === 🔔" ;;
    custom) echo "📢 === $CUSTOM_MESSAGE === 📢" ;;
    esac
  fi

  # Try notify-send if available
  if command -v notify-send &>/dev/null && [[ "$QUIET" == "false" ]]; then
    case "$STYLE" in
    red-alert) notify-send -u critical "RED ALERT" "Task complete - Awaiting orders" ;;
    bridge) notify-send "Bridge Notification" "Task complete - Awaiting command" ;;
    mission) notify-send "Mission Complete" "Standing by for orders" ;;
    attention) notify-send "Attention" "Task complete" ;;
    custom) notify-send "Notification" "$CUSTOM_MESSAGE" ;;
    esac
  fi
}

# Windows (via WSL or Git Bash) notification function
notify_windows() {
  # Try PowerShell for speech
  if command -v powershell.exe &>/dev/null; then
    case "$STYLE" in
    red-alert)
      powershell.exe -Command "Add-Type -AssemblyName System.Speech; \$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$speak.Speak('Red Alert! Task complete. Awaiting orders.')"
      ;;
    bridge)
      powershell.exe -Command "Add-Type -AssemblyName System.Speech; \$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$speak.Speak('Task completed. Awaiting command.')"
      ;;
    mission)
      powershell.exe -Command "Add-Type -AssemblyName System.Speech; \$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$speak.Speak('Mission accomplished.')"
      ;;
    attention)
      powershell.exe -Command "[console]::beep(800,200); [console]::beep(800,200); [console]::beep(800,200)"
      ;;
    custom)
      if [[ -z "$CUSTOM_MESSAGE" ]]; then
        echo "Error: Custom style requires -m MESSAGE"
        exit 1
      fi
      powershell.exe -Command "Add-Type -AssemblyName System.Speech; \$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$speak.Speak('$CUSTOM_MESSAGE')"
      ;;
    esac
  else
    # Fallback to terminal bell
    echo -e "\a\a\a"
  fi

  # Visual notification
  if [[ "$QUIET" == "false" ]]; then
    case "$STYLE" in
    red-alert) echo "🚨 === RED ALERT: TASK COMPLETE - AWAITING INPUT === 🚨" ;;
    bridge) echo "🖖 === BRIDGE: TASK COMPLETE - AWAITING COMMAND === 🖖" ;;
    mission) echo "✅ === MISSION COMPLETE - AWAITING ORDERS === ✅" ;;
    attention) echo "🔔 === ATTENTION: TASK COMPLETE === 🔔" ;;
    custom) echo "📢 === $CUSTOM_MESSAGE === 📢" ;;
    esac
  fi
}

# Main execution
case "$OS" in
Darwin)
  notify_macos
  ;;
Linux)
  notify_linux
  ;;
MINGW* | CYGWIN* | MSYS*)
  notify_windows
  ;;
*)
  # Unknown OS - use terminal bell
  echo -e "\a\a\a"
  if [[ "$QUIET" == "false" ]]; then
    echo "🔔 === TASK COMPLETE === 🔔"
  fi
  ;;
esac
