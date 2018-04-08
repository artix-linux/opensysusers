This is a utility written to process sysusers.d files so that they can be handled on systems with or without systemd installed.

For more information on the files this utility can process, see the
sysusers.d man page [1].

For more information on the systemd-sysuser command, see the
systemd-sysuers man page [2].

If built with the make flag SYSTEMDCOMPAT=FALSE, it will only install the basic script to process sysusers.d conf files. Otherwise it installs a script that imitates systemd-sysusers command.

[1] https://www.freedesktop.org/software/systemd/man/sysusers.d.html

[2] https://www.freedesktop.org/software/systemd/man/systemd-sysusers.html