# NAME

Testament - TEST AssignMENT

<img src="https://travis-ci.org/ytnobody/Testament.png?branch=master">

# SYNOPSIS

To show failure report for your module,

    $ testament failures Your::Module
    0.05 perl-5.12.1 OpenBSD 5.1 OpenBSD.amd64-openbsd-thread-multi
    0.05 perl-5.10.0 OpenBSD 5.1 OpenBSD.i386-openbsd
    0.05 perl-5.14.4 FreeBSD 9.1-release amd64-freebsd-thread-multi

And, you can create a new box

    $ testament create OpenBSD 5.1 OpenBSD.i386-openbsd

To show boxes-list,

    $ testament list
     KEY                             BOX-ID   STATUS      RAM SSH-PORT
       1 OpenBSD::5.1::OpenBSD.i386-openbsd      ---    256MB    50954

To boot a exists box,

    $ testament boot OpenBSD 5.1 OpenBSD.i386-openbsd
    ### or
    $ testament boot 1

# DESCRIPTION

Testament is a testing environment builder tool.

# USAGE

    testament subcommand [arguments]

## subcommand

- boot (\[boxkey\] or \[os-test os-version architecture\]) : boot-up specified box
- create (\[boxkey\] or \[os-test os-version architecture\]) : create environment
- put (\[boxkey\] or \[os-test os-version architecture source-file dest-path\]) : put file into specified box
- help (\[boxkey\] or \[(no arguments)\]) : show this help
- failures (\[boxkey\] or \[cpan-module-name\]) : fetch and show boxes that failures testing
- box\_config (\[os-test os-version architecture key=value\]) : config parameter of specified box
- get (\[boxkey\] or \[os-test os-version architecture source-file dest-path\]) : get file from specified box
- kill (\[boxkey\] or \[os-test os-version architecture\]) : kill specified box
- install\_perl (\[os-test os-version architecture version\]) : setup specified version perl into specified box
- list \[(no arguments)\] : show boxes in your machine
- install (\[boxkey\] or \[os-test os-version architecture\]) : alias for create
- enter (\[boxkey\] or \[os-test os-version architecture\]) : enter into box
- version \[(no arguments)\] : show testament version
- delete (\[boxkey\] or \[os-test os-version architecture\]) : delete specified box
- exec (\[boxkey\] or \[os-test os-version architecture commands...\]) : execute command into box
- backup\_list (\[os-text os-version architecture\]) : show backup list of specified box
- backup (\[os-text os-version architecture backup\_name\]) : backup specified box image
- restore (\[os-text os-version architecture backup\_name\]) : restore from specified backup image
- purge\_backup (\[os-text os-version architecture backup\_name\]) : purge specified backup image

# LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

ytnobody <ytnobody aaaaatttttt gmail>

moznion
