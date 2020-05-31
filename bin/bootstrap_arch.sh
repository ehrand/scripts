#!/usr/bin/env bash

set -x
set -u
set -e

# pacaur bootstrap packages
__aur_url=(\
	"https://aur.archlinux.org/cgit/aur.git/snapshot/auracle-git.tar.gz" \
	"https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz" \
	);
__aur_dep=(\
	"base-devel" \
	"cmake" \
	"gcc" \
	"pkg-config" \
	"wget" \
	);

__packages=();
# development
__packages+=(\
	"clang" "cmake" "ctags" \
	"git" \
	"linux-headers" "linux-lts" "linux-lts-headers" \
	"ninja" \
	"pkgfile" \
	"python-pip" \
	);
# firmware (run 'sudo mkinitcpio -p linux' after installing them)
__packages+=(\
	"aic94xx-firmware" \
	"intel-ucode" \
	"linux-firmware" \
	"wd719x-firmware" \
	);
# fonts
__packages+=(\
	"adobe-source-code-pro-fonts" \
	"ttf-font-awesome" \
	"ttf-dejavu" "ttf-liberation" \
	);
# internet \
__packages+=(\
	"google-chrome" \
	"firefox" \
	"jdownloader2" \
	);
# multimedia
__packages+=(\
	"alsa-lib" "alsa-utils" \
	"gst-plugins-base" "gst-plugins-base" "gst-plugins-good" \
	"pulseaudio" "pulseaudio-alsa" \
	"vlc"
	);
# network
__packages+=(\
	"networkmanager" \
	);
# printing
__packages+=(\
	"cups" \
	"cups-pdf" \
	"hplip" \
	"python-pillow" \
	"python-reportlab" \
	"rpcbind" \
	"python-pyqt5" \
	"sane" \
	"xsane" \
	);
# terminals & utilities
__packages+=(\
	"alacritty" \
	"bash" "bash-completion" \
	"conky" \
	"crda" \
	"dmenu" \
	"dos2unix" \
	"feh" "fortune-mod" \
	"htop" \
	"iotop" \
	"ltrace" "lrzip" "lzop" \
	"man-db" "man-pages" "mc" \
	"ncdu" "neofetch" "neovim" "nload" \
	"pacman-contrib" "p7zip" \
	"strace" "sysstat" \
	"tig" \
	"tmux" \
	"unrar" "unarchiver" \
	"xorg-xsetroot" \
	"zip" \
	"zsh" \
	);
# X
__packages+=(\
	"ark" \
	"breeze-gtk" \
	"calibre" \
	"dolphin" \
	"gwenview" \
	"konsole" \
	"plasma-meta" \
	"qt5-imageformats" \
	"xorg-server" "xorg-xinit" \
	"adobe-source-code-pro-fonts" \
	"ttf-dejavu" \
	"ttf-font-awesome" \
	"ttf-liberation" \
	);

__tmp_dir="$(mktemp -d)";

cleaup() {
	rm -rf "${__tmp_dir}";
}

trap cleaup EXIT SIGINT

install_when_missing() {
	local __installer="";
	for i in pacaur pacman; do
		${i} --version || continue;
		__installer="${i}";
		break;
	done

	case "${__installer}" in
		pacaur) ;;
		pacman) [[ $(id -u) -eq 0 ]] || __installer="sudo ${__installer}";;
		*)		return 1;;
	esac


	${__installer} -Syu;
	${__installer} -S --needed $@;
}

# bootstrap pacaur
install_when_missing ${__aur_dep[@]};
for __pkg_url in "${__aur_url[@]}"; do
	__pkg_name="${__pkg_url##*/}";
	__pkg_name="${__pkg_name%.tar*}";

	which "${__pkg_name%-git}" && continue || true;

	wget -qO- "${__pkg_url}" | tar xvz -C "${__tmp_dir}";

	pushd "${__tmp_dir}/${__pkg_name}";
	makepkg -si;
	popd;
done

install_when_missing ${__packages[@]};
sudo pkgfile --update;

