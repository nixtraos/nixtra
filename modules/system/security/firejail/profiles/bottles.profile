ignore seccomp
ignore seccomp.block-secondary
ignore restrict-namespaces
ignore no3d
ignore net none

include /etc/firejail/common.inc
include /etc/firejail/gtk.inc

mkdir ${HOME}/.local/share/bottles

whitelist ${HOME}/.local/share/bottles
