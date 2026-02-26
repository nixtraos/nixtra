ignore memory-deny-write-execute
ignore noinput

include /etc/firejail/common.inc
include /etc/firejail/qt.inc

mkdir ${HOME}/.local/share/krita

whitelist ${HOME}/.local/share/krita
whitelist ${HOME}/.config/kritarc
whitelist ${HOME}/.config/kritadisplayrc
whitelist ${HOME}/.local/share/fonts
