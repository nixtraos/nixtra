ignore memory-deny-write-execute
ignore no3d
ignore net none
ignore nosound
ignore seccomp
ignore seccomp.block-secondary
ignore restrict-namespaces

include /etc/firejail/common.inc

whitelist ${HOME}/.config/FreeTube
whitelist ${HOME}/.config/dconf
