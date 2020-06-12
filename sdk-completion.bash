#!/bin/bash

#    commands:
#       install   or i    <candidate> [version] [local-path]
#       uninstall or rm   <candidate> <version>
#       list      or ls   [candidate]
#       use       or u    <candidate> <version>
#       default   or d    <candidate> [version]
#       home      or h    <candidate> <version>
#       env       or e    [init]
#       current   or c    [candidate]
#       upgrade   or ug   [candidate]
#       version   or v
#       broadcast or b
#       help
#       offline           [enable|disable]
#       selfupdate        [force]
#       update
#       flush             <broadcast|archives|temp>
#
#   candidate  :  the SDK to install: groovy, scala, grails, gradle, kotlin, etc.
#                 use list command for comprehensive list of candidates
#                 eg: $ sdk list
#   version    :  where optional, defaults to latest stable if not provided
#                 eg: $ sdk install groovy
#   local-path :  optional path to an existing local installation
#                 eg: $ sdk install groovy 2.4.13-local /opt/groovy-2.4.13

cache_expire_days=${SDKMAN_CACHE_EXPIRE_DAYS:-7}

candidates_cache=~/.config/sdkman-bash-completion/.sdk-completion-candidates.cache
a_versions_cache=~/.config/sdkman-bash-completion/.sdk-completion-a-versions.cache
i_versions_cache=~/.config/sdkman-bash-completion/.sdk-completion-i-versions.cache

_is_cache_expired(){
	test "$(find -wholename "$1" -atime $cache_expire_days)"
}

_get_candidates(){
	_is_cache_expired "$candidates_cache" && sdk list | sed -n "s/ *\$ sdk install \([a-z]\+\)$/\1/p" > "$candidates_cache"
	cat "$candidates_cache"
}

_get_installed_versions(){
	_is_cache_expired "$a_versions_cache" && sdk ls $1 | sed -n "/installed/{s/ //g;s/^/$1|/p}" | cut -d '|' -f 1,7 > "$a_versions_cache"
	sed -n "s/^$1|//p" "$a_versions_cache"
}

_get_available_versions(){
	_is_cache_expired "$i_versions_cache" && sdk ls $1 | sed -n "/^---/,/^===/{/installed/d;/ /{s/ //g;s/^/$1|/p}}" | cut -d '|' -f 1,7 > "$i_versions_cache"
	sed -n "s/^$1|//p" "$i_versions_cache"
}

_get_versions(){
	echo "--$1--$2" >> /tmp/compl.txt
	case $1 in
		install)
			_get_available_versions $2
			;;
		uninstall|use|default|home)
			_get_installed_versions $2
			;;
		*)
			return;
	esac
}

_sdk_completions()
{
	if [[ "$COMP_CWORD" -eq 1 ]] ; then
		prev_word=${COMP_WORDS[0]}
	else
		prev_word=${COMP_WORDS[$(( $COMP_CWORD - 1 ))]}
	fi

	case "$prev_word" in
		sdk)
			COMPREPLY=($(compgen -W "install uninstall list use default home env current upgrade version broadcast help offline selfupdate update flush" "${COMP_WORDS[$COMP_CWORD]}"))
			;;

		install|uninstall|list|use|default|home|current|upgrade)
			COMPREPLY=($(compgen -W "$( _get_candidates )" "${COMP_WORDS[$COMP_CWORD]}"))
			;;

		offline)
			COMPREPLY=($(compgen -W "enable disable" "${COMP_WORDS[$COMP_CWORD]}"))
			;;
			
		flush)
			COMPREPLY=($(compgen -W "broadcast archives temp" "${COMP_WORDS[$COMP_CWORD]}"))
			;;

		*)
			if [[ "$COMP_CWORD" -eq 3 ]] ; then
				COMPREPLY=($(compgen -W "$( _get_versions ${COMP_WORDS[1]} ${COMP_WORDS[2]} )" "${COMP_WORDS[$COMP_CWORD]}"))
			fi
			return
			;;
	esac
}

complete -F _sdk_completions sdk
