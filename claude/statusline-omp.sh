#!/usr/bin/env bash
# Claude Code status line that follows the oh-my-pi (OMP) 18.13.1 custom preset:
# Titanium theme, Nerd Font symbols, thin chevrons, and a rule between the groups.
# Requires bash 4.3 or later, jq, git, a Nerd Font, and a true-color terminal.

# macOS ships bash 3.2. Run the script again under Homebrew bash if it is older than 4.3.
if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3))); then
  for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    [[ -x $candidate ]] && exec "$candidate" "$0" "$@"
  done
  echo 'statusline-omp.sh requires bash 4.3 or later'
  exit 0
fi

# Bash counts characters only in a UTF-8 locale. macOS may not have C.UTF-8.
if [[ $OSTYPE == darwin* ]]; then
  export LC_ALL=en_US.UTF-8
else
  export LC_ALL=C.UTF-8
fi
shopt -s extglob

# Columns to keep free for the margins that Claude Code adds to the row.
RESERVED_COLUMNS=4
PATH_MAX_LENGTH=40
MIN_SHRUNK_WIDTH=8

fg() { printf '\e[38;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
bg() { printf '\e[48;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }

# Titanium theme colors.
BLUE=$(fg 00b4ff)
ALUMINUM=$(fg e8ecf4)
GREEN=$(fg 00ff88)
AMBER=$(fg ffb347)
RED=$(fg ff4757)
GOLD=$(fg d4c090)
MUTED=$(fg 9ca3b0)
SEPARATOR=$(fg 2a3038)
BAND_FG=$(fg 0f1216)
BAND_BG=$(bg 0f1216)
# Claude Code renders a default-foreground reset as dim gray, so set the text color.
TEXT=$ALUMINUM
RESET=$'\e[0m'

# Nerd Font symbols.
ICON_MODEL=$''
ICON_FAST=$''
ICON_FOLDER=$''
ICON_BRANCH=$''
ICON_PR=$''
ICON_CONTEXT=$''
ICON_TIME=$''
ICON_SUBSCRIPTION=$'\U000F067A'
CHEVRON_LEFT=$''
CHEVRON_RIGHT=$''
CAP_ROUND=$''
CAP_LEFT=$''
CAP_RIGHT=$''
RULE=$'─'
DOT=' · '

# Print one unit-separated record. Control characters are removed so that a
# session name cannot send escape sequences to the terminal.
IFS=$'\x1f' read -r vim_mode model fast effort cwd session pr_number pr_url \
  cost has_limits ctx_pct ctx_size ctx_level \
  five_pct five_level five_reset seven_pct seven_level seven_reset < <(jq -r '
  def tokens:
    def trim: (. * 10 | round / 10 | tostring);
    if . < 1000 then tostring
    elif . < 10000 then (. / 1000 | trim) + "K"
    elif . < 1000000 then (. / 1000 | round | tostring) + "K"
    elif . < 10000000 then (. / 1000000 | trim) + "M"
    else (. / 1000000 | round | tostring) + "M" end;
  def level: if . >= 80 then "error" elif . >= 50 then "warning" else "muted" end;
  def duration($minutes):
    def join_units($a; $b; $x; $y): if $b > 0 then "\($a)\($x) \($b)\($y)" else "\($a)\($x)" end;
    if $minutes < 60 then "\($minutes)m"
    elif $minutes < 1440 then join_units($minutes / 60 | floor; $minutes % 60; "h"; "m")
    else ($minutes / 60 | floor) as $hours | join_units($hours / 24 | floor; $hours % 24; "d"; "h") end;
  def days_hours($minutes):
    ($minutes / 60 | ceil) as $hours
    | if $hours < 24 then "\($hours)h"
      elif $hours % 24 > 0 then "\($hours / 24 | floor)d \($hours % 24)h"
      else "\($hours / 24 | floor)d" end;
  def remaining: ((.resets_at // now) - now) / 60 | ceil | if . < 0 then 0 else . end;

  (.context_window.context_window_size // 0) as $size
  | (.context_window.total_input_tokens // 0) as $input
  | (.context_window.used_percentage) as $used
  | (if $used == null then null elif $input > 0 and $size > 0 then $input / $size * 100 else $used end) as $pct
  | (if $size > 0 then [50, 15000000 / $size] | min else 50 end) as $warn
  | (if $size > 0 then [70, 27000000 / $size] | min else 70 end) as $high
  | (if $size > 0 then [90, 50000000 / $size] | min else 90 end) as $crit
  | ($pct // 0) as $p
  | .rate_limits.five_hour as $five
  | .rate_limits.seven_day as $seven
  | [
      .vim.mode, .model.display_name, .fast_mode, .effort.level,
      (.workspace.current_dir // .cwd), .session_name,
      .pr.number, .pr.url,
      (.cost.total_cost_usd // 0), (.rate_limits != null),
      (if $pct == null then null else ($pct * 10 | round / 10) end),
      (if $size > 0 then ($size | tokens) else null end),
      (if $p >= $crit then "error" elif $p >= $high then "high" elif $p >= $warn then "warning" else "normal" end),
      ($five.used_percentage | if . == null then null else round end),
      ($five.used_percentage | if . == null then null else level end),
      (if $five then duration($five | remaining) else null end),
      ($seven.used_percentage | if . == null then null else round end),
      ($seven.used_percentage | if . == null then null else level end),
      (if $seven then days_hours($seven | remaining) else null end)
    ]
  | map(if . == null then "" else (tostring | gsub("[[:cntrl:]]"; " ")) end)
  | join("\u001f")
')

level_color() {
  case $1 in
    error) printf '%s' "$RED" ;;
    warning) printf '%s' "$AMBER" ;;
    high) printf '%s' "$BLUE" ;;
    *) printf '%s' "$MUTED" ;;
  esac
}

visible_width() {
  local text=$1
  text=${text//$'\e['*([0-9;])m/}
  text=${text//$'\e]8;;'*([!$'\a'])$'\a'/}
  printf '%d' "${#text}"
}

render_path() {
  local max=$1 shown=$cwd root
  for root in "$HOME/Projects" "$HOME/repos" /work; do
    if [[ $shown == "$root"/* ]]; then
      shown=${shown#"$root"/}
      break
    fi
  done
  [[ $shown == "$HOME"* ]] && shown="~${shown#"$HOME"}"
  if ((${#shown} > max)); then
    shown="…${shown: -$((max - 1))}"
  fi
  printf '%s%s %s%s' "$ALUMINUM" "$ICON_FOLDER" "$shown" "$TEXT"
}

render_vim() {
  local color=$BLUE label=$vim_mode
  case $vim_mode in
    '') return ;;
    INSERT) color=$GREEN ;;
    VISUAL) color=$AMBER ;;
    'VISUAL LINE') color=$AMBER label='V-LINE' ;;
  esac
  printf '%s%s%s' "$color" "$label" "$TEXT"
}

render_model() {
  [[ -n $model ]] || return
  local text="$ICON_MODEL $model"
  [[ $fast == true ]] && text+=" $ICON_FAST"
  [[ -n $effort ]] && text+="$DOT$effort"
  printf '%s%s%s' "$BLUE" "$text" "$TEXT"
}

# Use --no-optional-locks so that the status line never competes with your own
# git commands for the index lock.
render_git() {
  local line branch='' oid='' unstaged=0 staged=0 untracked=0 color=$GREEN text
  while IFS= read -r line; do
    case $line in
      '# branch.head '*) branch=${line#'# branch.head '} ;;
      '# branch.oid '*) oid=${line#'# branch.oid '} ;;
      '? '*) ((untracked += 1)) ;;
      'u '*) ((unstaged += 1)) ;;
      [12]' '*)
        [[ ${line:2:1} != . ]] && ((staged += 1))
        [[ ${line:3:1} != . ]] && ((unstaged += 1))
        ;;
    esac
  done < <(git --no-optional-locks -C "$cwd" status --porcelain=v2 --branch 2>/dev/null)
  [[ -n $branch ]] || return
  [[ $branch == '(detached)' ]] && branch=${oid:0:7}
  ((unstaged + staged + untracked > 0)) && color=$AMBER
  text="$color$ICON_BRANCH $branch"
  ((unstaged > 0)) && text+=" $AMBER*$unstaged"
  ((staged > 0)) && text+=" $GREEN+$staged"
  ((untracked > 0)) && text+=" $MUTED?$untracked"
  printf '%s%s' "$text" "$TEXT"
}

render_pr() {
  [[ -n $pr_number ]] || return
  local label="$ICON_PR #$pr_number"
  [[ -n $pr_url ]] && label=$'\e]8;;'"$pr_url"$'\a'"$label"$'\e]8;;\a'
  printf '%s%s%s' "$BLUE" "$label" "$TEXT"
}

render_cost() {
  local amount
  printf -v amount '%.2f' "$cost"
  if [[ $has_limits == true ]]; then
    printf '%s%s %s%s' "$GOLD" "$ICON_SUBSCRIPTION" "$amount" "$TEXT"
  elif [[ $amount != 0.00 ]]; then
    printf '%s$%s%s' "$GOLD" "$amount" "$TEXT"
  fi
}

render_context() {
  [[ -n $ctx_size ]] || return
  local value="$ctx_size"
  [[ -n $ctx_pct ]] && printf -v value '%.1f%%/%s' "$ctx_pct" "$ctx_size"
  printf '%s %s%s%s' "$ICON_CONTEXT" "$(level_color "$ctx_level")" "$value" "$TEXT"
}

render_usage() {
  local windows=()
  [[ -n $five_pct ]] && windows+=("5h $(level_color "$five_level")$five_pct%$TEXT $MUTED($five_reset)$TEXT")
  [[ -n $seven_pct ]] && windows+=("7d $(level_color "$seven_level")$seven_pct%$TEXT $MUTED($seven_reset)$TEXT")
  ((${#windows[@]} > 0)) || return
  local joined=${windows[0]}
  ((${#windows[@]} > 1)) && joined+="$DOT${windows[1]}"
  printf '%s %s' "$ICON_TIME" "$joined"
}

render_session() {
  [[ -n $session ]] || return
  local max=${1:-${#session}} shown=$session
  if ((${#shown} > max)); then
    shown="${shown:0:max-1}…"
  fi
  printf '%s%s%s' "$BLUE" "$shown" "$TEXT"
}

add() {
  local -n target=$1
  [[ -n $3 ]] || return 0
  target+=("$2=$3")
}

left=()
right=()
add left vim "$(render_vim)"
add left model "$(render_model)"
add left path "$(render_path "$PATH_MAX_LENGTH")"
add left git "$(render_git)"
add left pr "$(render_pr)"
add right session "$(render_session)"
add right cost "$(render_cost)"
add right context "$(render_context)"
add right usage "$(render_usage)"

# Print the width of a group: its segments, a separator and two spaces between
# each pair, two outer spaces, and its end caps.
group_width() {
  local -n items=$1
  local caps=$2 total=0 item
  ((${#items[@]} > 0)) || { printf 0; return; }
  for item in "${items[@]}"; do
    ((total += $(visible_width "${item#*=}")))
  done
  printf '%d' $((total + (${#items[@]} - 1) * 3 + 2 + caps))
}

index_of() {
  local -n items=$1
  local i
  for i in "${!items[@]}"; do
    [[ ${items[i]%%=*} == "$2" ]] && { printf '%d' "$i"; return; }
  done
  printf -- -1
}

# Shrink the bar in the OMP order: session name, right segments from the end,
# path, then left segments from the end.
available=$((${COLUMNS:-120} - RESERVED_COLUMNS))
overflow() { printf '%d' $(($(group_width left 2) + $(group_width right 1) + 1 - available)); }

over=$(overflow)
session_index=$(index_of right session)
if ((over > 0 && session_index >= 0)); then
  width=${#session}
  cut=$((width - MIN_SHRUNK_WIDTH))
  ((cut > over)) && cut=$over
  ((cut > 0)) && right[session_index]="session=$(render_session $((width - cut)))"
  over=$(overflow)
fi
while ((over > 0 && ${#right[@]} > 0)); do
  unset 'right[-1]'
  over=$(overflow)
done
path_index=$(index_of left path)
if ((over > 0 && path_index >= 0)); then
  width=$(visible_width "${left[path_index]#*=}")
  path_width=$((width - over))
  ((path_width < MIN_SHRUNK_WIDTH)) && path_width=$MIN_SHRUNK_WIDTH
  # The icon and its space take two columns of the segment width.
  left[path_index]="path=$(render_path $((path_width - 2)))"
  over=$(overflow)
fi
while ((over > 0 && ${#left[@]} > 1)); do
  for ((i = ${#left[@]} - 1; i >= 0; i--)); do
    if [[ ${left[i]%%=*} != path ]]; then
      unset "left[i]"
      left=("${left[@]}")
      break
    fi
  done
  over=$(overflow)
done

join_group() {
  local -n items=$1
  local chevron=$2 out='' item
  for item in "${items[@]}"; do
    [[ -n $out ]] && out+=" $SEPARATOR$chevron$TEXT "
    out+=${item#*=}
  done
  printf '%s' "$out"
}

output=''
if ((${#left[@]} > 0)); then
  output+="$BAND_FG$CAP_ROUND$RESET$BAND_BG$TEXT $(join_group left "$CHEVRON_LEFT") $RESET$BAND_FG$CAP_RIGHT$RESET"
fi

# The rule shows context use: blue for the used share and gray for the rest.
gap=$((available - $(group_width left 2) - $(group_width right 1)))
if ((gap > 0)); then
  filled=0
  if [[ -n $ctx_pct ]]; then
    filled=$(awk -v pct="$ctx_pct" -v gap="$gap" 'BEGIN { n = int(pct / 100 * gap + 0.5); if (n > gap) n = gap; if (n < 1) n = 1; print n }')
  fi
  printf -v used '%*s' "$filled" ''
  printf -v rest '%*s' "$((gap - filled))" ''
  output+="$BLUE${used// /$RULE}$SEPARATOR${rest// /$RULE}$RESET"
fi

if ((${#right[@]} > 0)); then
  output+="$BAND_FG$CAP_LEFT$RESET$BAND_BG$TEXT $(join_group right "$CHEVRON_RIGHT") $RESET"
fi

printf '%s\n' "$output"
