#!/bin/sh
# Copyright (c) 2018 Chris Cromer
# Copyright (c) 2012 Gentoo Foundation
# Released under the 2-clause BSD license.
#
# Common functions and variables needed by opensysusers

warninvalid() {
	printf "sysusers: %s on line %d of \`%s'\n" "${1:-ignoring invalid entry}" "${line}" "${file}"
	: "$((error += 1))"
} >&2

add_group() {
	# add_group <name> <id>
	if ! grep -q "^$1:" /etc/group; then
		if [ "$2" = '-' ]; then
			groupadd -r "$1"
		elif ! grep -q "^[^:]*:[^:]*:$2:[^:]*$" /etc/group; then
			groupadd -g "$2" "$1"
		fi
	fi
}

add_user() {
	# add_user <name> <id> <gecos> <home>
	if ! id "$1" >/dev/null 2>&1; then
		if [ "$2" = '-' ]; then
			useradd -rc "$3" -g "$1" -d "$4" -s '/sbin/nologin' "$1"
		else
			useradd -rc "$3" -u "$2" -g "$1" -d "$4" -s '/sbin/nologin' "$1"
		fi
		passwd -l "$1" >/dev/null 2>&1
	fi
}

update_login_defs() {
	# update_login_defs <name> <id>
	[ "$1" != '-' ] && warninvalid && return
	i=0
	IFS='-'
	for part in $2; do
		case "$((i += 1))" in
			1) min="${part}" ;;
			2) max="${part}" ;;
			3) warninvalid && return ;;
		esac
	done
	IFS="${_IFS}"
	[ "${min}" -ge "${max}" ] && warninvalid "invalid range" && return

	while read -r NAME VALUE; do
		case "${NAME}" in
			SYS_UID_MAX) suid_max="${VALUE}" ;;
			SYS_GID_MAX) sgid_max="${VALUE}" ;;
		esac
	done < /etc/login.defs
	[ "${min}" -lt "${suid_max}" ] && warninvalid "invalid range" && return
	[ "${min}" -lt "${sgid_max}" ] && warninvalid "invalid range" && return

	sed -e "s/^\([GU]ID_MIN\)\([[:space:]]\+\)\(.*\)/\1\2${min}/" \
		-e "s/^\([GU]ID_MAX\)\([[:space:]]\+\)\(.*\)/\1\2${max}/" \
		-i /etc/login.defs
}

parse_file() {
	if [ -f "$1" ]; then
		line=0
		while read -r cline; do
			: "$((line += 1))"
			case "${cline}" in [!#]*) parse_string "${cline}"; esac
		done < "$1"
	fi
}

parse_string() {
	case "$1" in '#'*) return; esac
	eval "set -- $1"
	i=0
	for part in "$@"; do
		case "$((i += 1))" in
			1) type="${part}" ;;
			2) name="${part}" ;;
			3) id="${part}" ;;
			4) gecos="${part}" ;;
			5) home="${part}" ;;
		esac
	done
	: "$((line += 1))"

	case "${type}" in
		u)
			case "${id}" in 65535|4294967295) warninvalid; return; esac
			case "${home#-}" in '') home='/'; esac
			add_group "${name}" "${id}"
			[ "${id}" = '-' ] && id="$(id -g "${name}")"
			add_user "${name}" "${id}" "${gecos}" "${home}"
		;;
		g)
			case "${id}" in 65535|4294967295) warninvalid; return; esac
			[ "${home:--}" = '-' ] && home='/'
			add_group "${name}" "${id}"
		;;
		m)
			add_group "${name}" '-'
			if id "${name}" >/dev/null 2>&1; then
				usermod -a -G "${id}" "${name}"
			else
				useradd -r -g "${id}" -s '/sbin/nologin' "${name}"
				passwd -l "${name}" >/dev/null 2>&1
			fi
		;;
		r)
			update_login_defs "${name}" "${id}"
		;;
		*) warninvalid; return ;;
	esac
}

# this part is based on OpenRC's opentmpfiles
# Build a list of sorted unique basenames
# directories declared later in the sysusers_d array will override earlier
# directories, on a per file basename basis.
# `/etc/sysusers.d/foo.conf' supersedes `/usr/lib/sysusers.d/foo.conf'.
# `/run/sysusers.d/foo.conf' will always be read after `/etc/sysusers.d/bar.conf'

get_conf_files() {
	IFS=':'
	for dir in ${sysusers_dirs}; do
		[ -d "${dir}" ] && for file in "${dir}"/*.conf; do
			[ -n "${replace}" ] &&
				[ "${dir}" = "$(dirname "${replace}")" ] &&
				[ "${file##*/}" = "${replace##*/}" ] &&
				continue
			[ -f "${file}" ] && sysusers_basenames="${sysusers_basenames}
${file##*/}"
		done
	done
	FILES="$(printf '%s\n' "${sysusers_basenames}" | sort -u)"
}

get_conf_paths() {
	IFS="${_IFS}"
	for b in ${FILES}; do
		real_f='' IFS=':'
		for d in ${sysusers_dirs}; do
			[ -n "${replace}" ] &&
				[ "${d}" = "$(dirname "${replace}")" ] &&
				[ "${b}" = "${replace##*/}" ] && continue
			[ -f "${d}/${b}" ] && real_f="${d}/${b}"
		done
		[ -f "${real_f}" ] && sysusers_d="${sysusers_d}:${real_f}"
	done
}

_IFS="${IFS}"
error=0
FILES=''
sysusers_basenames=''
sysusers_d=''
replace=''

sysusers_dirs="${root:=}/usr/lib/sysusers.d:${root}/run/sysusers.d:${root}/etc/sysusers.d"
