ignore private-dev
ignore private-cache
ignore nou2f
ignore net none
ignore nodbus
ignore nosound
ignore novideo
ignore no3d
ignore memory-deny-write-execute
ignore seccomp
ignore seccomp.block-secondary
ignore restrict-namespaces

include /etc/firejail/common.inc
include /etc/firejail/gtk.inc

whitelist ${HOME}/.librewolf
whitelist ${HOME}/.cache/librewolf
whitelist ${HOME}/.pulse
whitelist ${HOME}/.config/pulse
whitelist ${HOME}/.local/share/themes

private-bin firefox,firefox-esr,which,sh,env,bash
private-etc hosts,passwd,mime.types,fonts,mailcap,firefox,xdg,gtk-3.0,X11,pulse,alternatives,localtime,nsswitch.conf,resolv.conf,ssl,pki,static
