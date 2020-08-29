__path_prepend() {
	for __path in "${@}"; do
		case "${PATH}" in
			*${__path}*)	;;
			*)	export PATH="${__path}:${PATH}"	;;
		esac
	done
}

##########################################################################################

__set_editor() {
	for __editor; do
		[[ -x $(which "${__editor}" 2>/dev/null) ]] || continue;
		export EDITOR="${__editor}";
		break;
	done
}
