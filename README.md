# NAME

Testament - TEST AssignMENT

# SYNOPSIS

To show failure report for your module,

    $ testament failures Your::Module
    0.05 perl-5.12.1 OpenBSD 5.1 OpenBSD.amd64-openbsd-thread-multi
    0.05 perl-5.10.0 OpenBSD 5.1 OpenBSD.i386-openbsd
    0.05 perl-5.14.4 FreeBSD 9.1-release amd64-freebsd-thread-multi

And, you can create a new box

    $ testament create OpenBSD 5.1 OpenBSD.i386-openbsd

# DESCRIPTION

Testament is a testing environment builder tool.

# USAGE

    testament subcommand [arguments]

## subcommand

- boot \[os-test os-version architecture\] : boot-up specified box
- create \[os-test os-version architecture\] : create environment
- put \[os-test os-version architecture source-file dest-path\] : put file into specified box
- help \[(no arguments)\] : show this help
- failures \[cpan-module-name\] : fetch and show boxes that failures testing
- get \[os-test os-version architecture source-file dest-path\] : get file from specified box
- kill \[os-test os-version architecture\] : kill specified box
- setup\_chef \[os-test os-version architecture\] : setup chef-solo into specified box
- list \[(no arguments)\] : show boxes in your machine
- install \[os-test os-version architecture\] : alias for create
- enter \[os-test os-version architecture\] : enter into box
- version \[(no arguments)\] : show testament version
- delete \[os-test os-version architecture\] : delete specified box
- exec \[os-test os-version architecture commands...\] : execute command into box

# BUILD STATUS

<img src="https://travis-ci.org/ytnobody/Testament.png?branch=master">

# LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

ytnobody <ytnobody aaaaatttttt gmail>

moznion
