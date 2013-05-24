package Testament::Virt::QEMU::Monitor;
use strict;
use warnings;
use Expect;
use Class::Accessor::Lite (
    new => 1,
    ro => [qw[boot_cmd]],
    rw => [qw[spawn boot_wait]],
);

our %METAMAP = (
    '\s' => 'shift',         '\S' => 'shift_r',
    '\a' => 'alt',           '\A' => 'alt_r',
    '\g' => 'altgr',         '\G' => 'altgr_r',
    '\c' => 'ctrl',          '\C' => 'ctrl_r',
    '\m' => 'menu',          '\e' => 'esc',
    '-'  => 'minus',         '='  => 'equal',
    '\b' => 'backspace',     '\t' => 'tab',
    '['  => 'bracket_left',  ']'  => 'bracket_right',
    '\r' => 'ret',           ';'  => 'semicolon',
    '`'  => 'grave_accent',  '\\' => 'backslash',
    ','  => 'comma',         '.'  => 'dot',
    '/'  => 'slash',         '*'  => 'asterisk',
    '\ ' => 'spc',           '\L' => 'caps_lock',
    '\1' => 'f1',            '\2' => 'f2',
    '\3' => 'f3',            '\4' => 'f4',
    '\5' => 'f5',            '\6' => 'f6',
    '\7' => 'f7',            '\8' => 'f8',
    '\9' => 'f9',            '\0' => 'f10',
    '\!' => 'f11',           '\@' => 'f12',
    '\N' => 'num_lock',      '\l' => 'scroll_lock',
    '\/' => 'kp_divide',     '\*' => 'kp_multiply',
    '\-' => 'kp_subtract',   '\+' => 'kp_add',
    '\n' => 'kp_enter',      '\D' => 'kp_decimal',
    '\Q' => 'sysrq',         '_0' => 'kp_0',
    '_1' => 'kp_1',          '_2' => 'kp_2',
    '_3' => 'kp_3',          '_4' => 'kp_4',
    '_5' => 'kp_5',          '_6' => 'kp_6',
    '_7' => 'kp_7',          '_8' => 'kp_8',
    '_9' => 'kp_9',          '\p' => 'print',
    '_H' => 'home',          '_U' => 'pgup',
    '_D' => 'pgdn',          '_E' => 'end',
    '_l' => 'left',          '_u' => 'up',
    '_n' => 'down',          '_r' => 'right',
    '_i' => 'insert',        '_d' => 'delete',
);

our $META_CHAR_REGEXP = qr/(_\\)/;

sub boot {
    my ($self, $boot_opt) = @_;
    my $boot_wait = $self->boot_wait || 10;
    my $spawn = Expect->spawn(@{$self->boot_cmd}, $boot_opt) or die sprintf('%s [CMD=%s BOOT_OPTION=%s]', $!, $self->boot_cmd, $boot_opt);
    $self->spawn($spawn);
    sleep $boot_wait;
    $self->type($boot_opt);
}

sub sendkey {
    my ($self, $key) = @_;
    $self->spawn->send("sendkey $key\n") if length($key) > 0;
}

sub type {
    my ($self, $str) = @_;
    my @chars = split(//, $str);
    my $key = '';
    for my $char ( @chars ) {
        if ($char =~ $META_CHAR_REGEXP) {
            $key = $char;
            next;
        }
        $key .= $char;
        my $key = $METAMAP{$key} ? $METAMAP{$key} : $key;
        $self->sendkey($key);
        $key = '';
    }
    $self->sendkey('kp_enter');
}

1;

__END__
### available keys for sendkey
keyname		metachar

shift		\s
shift_r		\S
alt		\a
alt_r		\A
altgr		\g
altgr_r		\G
ctrl		\c
ctrl_r		\C
menu		\m
esc		\e
1		
2		
3		
4		
5		
6		
7		
8		
9		
0		
minus		-
equal		=
backspace	\b
tab		\t
q		
w		
e		
r		
t		
y		
u		
i		
o		
p		
bracket_left	[
bracket_right	]
ret		\r
a		
s		
d		
f		
g		
h		
j		
k		
l		
semicolon	;
apostrophe	'
grave_accent	`	
backslash	\\	
z		
x		
c		
v		
b		
n		
m		
comma		,
dot		.
slash		/
asterisk	*	
spc		\ (backslash and real-space)
caps_lock	\L
f1		\1
f2		\2
f3		\3
f4		\4
f5		\5
f6		\6
f7		\7
f8		\8
f9		\9
f10		\0
num_lock	\N
scroll_lock	\l
kp_divide	\/	
kp_multiply	\*	
kp_subtract	\-	
kp_add		\+
kp_enter	\n	
kp_decimal	\D
sysrq		\Q
kp_0		_0
kp_1		_1
kp_2		_2
kp_3		_3
kp_4		_4
kp_5		_5
kp_6		_6
kp_7		_7
kp_8		_8
kp_9		_9
<		
f11		\!
f12		\@
print		\p
home		_H
pgup		_U
pgdn		_D
end		_E
left		_l
up		_u
down		_n
right		_r
insert		_i
delete		_d

