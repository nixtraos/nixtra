ignore noinput
ignore no3d
ignore restrict-namespaces
ignore seccomp
ignore seccomp.block-secondary
ignore noroot
ignore nodbus
ignore memory-deny-write-execute

include /etc/firejail/common.inc

whitelist ${HOME}/.config/draw.io
