SEGMENT_SEPARATOR=$'\uE0B2' # 

CURRENT_BG_COLOR=darkgrey
CURRENT_FG_COLOR=default
CURRENT_FORMAT=default

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
start_segment() {
  local segment_color text_color format
  [[ -n $1 ]] && segment_color="$1" || segment_color=$CURRENT_BG_COLOR
  [[ -n $2 ]] && text_color="$2" || text_color=$CURRENT_FG_COLOR
	[[ -n $3 ]] && format="$3" || format=$CURRENT_FORMAT

	echo -en "$(setcolor -f $segment_color -b $CURRENT_BG_COLOR)$SEGMENT_SEPARATOR$(setcolor -o $format -f $text_color -b $segment_color) "
	CURRENT_BG_COLOR=$segment_color
	CURRENT_FG_COLOR=$text_color
	CURRENT_FORMAT=$format
}

end_segment() {
	echo -en " \e[m"
	CURRENT_BG_COLOR=darkgrey
	CURRENT_FG_COLOR=default
	CURRENT_FORMAT=default
}

function _append {
  local var=$1
  local result
  shift
  local IFS=''
  "$@" > /tmp/_appendfifo
  read result < /tmp/_appendfifo
  eval "$var+=\"$result\""
}

function _ceil_div {
	local result=($1+${2:-1}-1)/${2:-1}
	echo $result
}

function user_prompt {
	command -v _lp_sudo_check >/dev/null && unset -f _lp_sudo_check

	local section_color=""
	# Yellow for root, bold if the user is not the login one, else no color.
	if (( EUID != 0 )); then  # if user is not root
		# if user is not login user
		if [[ "${USER}" != "$(logname 2>/dev/null || echo "$LOGNAME")" ]]; then
			start_segment $LP_COLOR_USER_ALT black
		elif (( LP_USER_ALWAYS )); then
			start_segment $LP_COLOR_USER_LOGGED black
		else
			section_color=""
		fi
		# "sudo -n" is only supported from sudo 1.7.0
		if (( LP_ENABLE_SUDO )) \
			&& command -v sudo >/dev/null \
			&& LC_MESSAGES=C sudo -V | GREP_OPTIONS= \grep -qE '^Sudo version (1(\.([7-9]\.|[1-9][0-9])|[0-9])|[2-9])'
		then
			LP_COLOR_MARK_NO_SUDO="$LP_COLOR_MARK"
			# Test the code with the commands:
			#   sudo id   # sudo, enter your credentials
			#   sudo -K   # revoke your credentials
			_lp_sudo_check()
			{
				if sudo -n true 2>/dev/null; then
					LP_COLOR_MARK=$LP_COLOR_MARK_SUDO
				else
					LP_COLOR_MARK=$LP_COLOR_MARK_NO_SUDO
				fi
			}
		fi
	else # root!
		start_segment $LP_COLOR_USER_ROOT black
		LP_COLOR_MARK="${LP_COLOR_MARK_ROOT}"
		LP_COLOR_PATH="${LP_COLOR_PATH_ROOT}"
		# Disable VCS info for all paths
		if (( ! LP_ENABLE_VCS_ROOT )); then
			LP_DISABLED_VCS_PATH=/
			LP_MARK_DISABLED="$_LP_MARK_SYMBOL"
		fi
	fi

	# Empty _lp_sudo_check if root or sudo disabled
	if ! command -v _lp_sudo_check >/dev/null; then
		_lp_sudo_check() { :; }
	fi

	echo -n "$(whoami)"
}

# TODO: Add support for other VCS.(hg, svn, fossil, bzr)
function batt_prompt {
	(( LP_ENABLE_BATT )) || return

	local percent batt_status

	case "$LP_OS" in
		Darwin)
			eval "$(pmset -g batt | sed -n 's/^ -InternalBattery.*\([1-9][0-9]\{1,2\}\)%; \([^;]*\).*$/percent=\1 batt_status="\2"/p')"
			;;
		Linux)
			local acpi
			acpi="$(acpi --battery 2>/dev/null)"
			# Extract the battery load value in percent
			# First, remove the beginning of the line...
			local bat="${acpi#Battery *, }"
			percent="${bat%%%*}" # remove everything starting at '%'

			if [[ -z "${bat}" ]]; then
				return # no battery level found
			fi

			if [[ "$acpi" == *"Discharging"* ]]; then
				batt_status="discharging"
			elif (( $percent == 100 )); then
				batt_status="charged"
			else
				batt_status="charging"
			fi
			;;
	esac

	local indicator=""
	local status_symbol="$LP_MARK_ADAPTER"

	if [[ "$batt_status" == "discharging" ]]; then
		status_symbol="$LP_MARK_BATTERY"
	fi

	case "$batt_status" in
		charged | "")
			return
			;;
		*)
			if (( $percent == 100 )); then
				indicator="$(setcolor -f green)\uf240"
			elif (( $percent >= 75 )); then
				indicator="$(setcolor -f green)\uf241"
			elif (( $percent >= 50 )); then
				indicator="$(setcolor -f orange)\uf242"
			elif (( $percent >= 25 )); then
				indicator="$(setcolor -f red)\uf243"
			else
				indicator="$(setcolor -f red)\uf244"
			fi
	esac

	echo -en "$indicator $status_symbol$(setcolor -f $CURRENT_FG_COLOR)"
}

function git_prompt {
	(( LP_ENABLE_GIT )) || return

	local branch="$(_lp_git_branch)"
	if [[ -n "$branch" ]]; then
		local remote="$(\git config --get branch.${branch}.remote 2>/dev/null)"
		local has_commit=""
		local commit_ahead
		local commit_behind
		if [[ -n "$remote" ]]; then
			local remote_branch="$(\git config --get branch.${branch}.merge)"
			if [[ -n "$remote_branch" ]]; then
				remote_branch=${remote_branch/refs\/heads/refs\/remotes\/$remote}
				commit_ahead="$(\git rev-list --count $remote_branch..HEAD 2>/dev/null)"
				commit_behind="$(\git rev-list --count HEAD..$remote_branch 2>/dev/null)"

				if [[ "$commit_ahead" -ne "0" && "$commit_behind" -ne "0" ]]; then
					has_commit="${LPE_GIT_COMMIT_AHEAD_MARK:-+}$commit_ahead/${LPE_GIT_COMMIT_BEHIND_MARK:--}$commit_behind"
				elif [[ "$commit_ahead" -ne "0" ]]; then
					has_commit="${LPE_GIT_COMMIT_AHEAD_MARK:-+}$commit_ahead"
				elif [[ "$commit_behind" -ne "0" ]]; then
					has_commit="${LPE_GIT_COMMIT_BEHIND_MARK:--}$commit_behind"
				fi
			fi
		fi

		local shortstat #only check for uncommitted changes
		shortstat="$(LC_ALL=C \git diff --shortstat HEAD 2>/dev/null)"

		local ret="${branch}"
		if [[ -n "$shortstat" ]]; then
			start_segment red black

			local u_stat # shortstat of *unstaged* changes
			u_stat="$(LC_ALL=C \git diff --shortstat 2>/dev/null)"
			u_stat=${u_stat/*changed, /} # removing "n files9s0 changed"

			local i_lines # inserted lines
			if [[ "$u_stat" = *insertion* ]]; then
				i_lines=${u_stat/ inser*}
			else
				i_lines=0
			fi

			local d_lines # deleted lines
			if [[ "$u_stat" = *deletion* ]]; then
				d_lines=${u_stat/*\(+\), }
				d_lines=${d_lines/ del*/}
			else
				d_lines=0
			fi

			local has_lines="${LPE_GIT_INSERTED_LINES_MARK:-+}$i_lines/${LPE_GIT_DELETED_LINES_MARK:--}$d_lines"
			ret+=" [$has_lines"
			if [[ -n "$has_commit" ]]; then
				ret+="|$has_commit"
			fi
			ret+="]"
		elif [[ -n "$has_commit" ]]; then
			start_segment orange black

			ret+="[$has_commit]"
		else
			start_segment green black
		fi

		# if  [[ -n "$LPE_GIT_MARK" ]]; then
			# ret="$LPE_GIT_MARK $ret"
		# fi
		local vcs_mark=$(_lp_as_text "$(_lp_smart_mark)")
		vcs_mark=${vcs_mark%[*}
		# echo $vcs_mark
		echo -en "$(_lp_sr "$vcs_mark")$ret"
	fi
}

LP_PS1="╭─"
#_append LP_PS1 start_segment blue black
_append LP_PS1 user_prompt
LP_PS1+="$(_lp_as_text ${LP_HOST})"

_append LP_PS1 git_prompt

# echo $(_lp_git_branch)

_append LP_PS1 start_segment darkgrey default default

LP_PS1+=${LP_PWD}

AUX_INFO=""

_append AUX_INFO batt_prompt

AUX_INFO+="${LP_LOAD}"

if (( EUID == 0 )); then
	AUX_INFO+="$(setcolor -f ${LP_COLOR_USER_ROOT})${LPE_MARK_ROOT:-""}$(setcolor reset)"
fi

if [[ "$AUX_INFO" != "" ]]; then 
	AUX_INFO="[$AUX_INFO]─"
  AUX_INFO="$(sed -E 's/[[:cntrl:]]\[([0-9]{1,2};)*[0-9]{0,2}m/\\\[&\\\]/g' <<< "${AUX_INFO}")"
fi

LP_PS1+="\n╰─${AUX_INFO}▶︎\[ \]" 

# vim: set ft=sh :
