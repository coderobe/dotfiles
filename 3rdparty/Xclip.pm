#! /usr/bin/perl -w
package Xclip;
#
# Invoke as Xclip::copy2("some stuff");
#
# Copy given string to X-windows 'primary selection'
#    (so it can be pasted with middle-mouse)
# and also to X-windows 'clipboard'
#    (so it can be pasted with ^V).
# Reference: https://linux.die.net/man/1/xsel
#
# Errors are non-fatal;
# we just print a warning message and return.
#
# Requires either 'xsel' or 'xclip' to be installed.

use strict;
use File::Which 'which';
use Symbol;     ## for gensym
use POSIX;      ## for WIFEXITED

sub copy2 {
  my ($str) = @_;
  my $prog = which('xsel');
  if ($prog) {
    copy2_guts($str, $prog, qw(-i -p));
    copy2_guts($str, $prog, qw(-i -b));
    return;
  }
  $prog = which('xclip');
  if ($prog) {
    copy2_guts($str, $prog, qw(-i -selection primary));
    copy2_guts($str, $prog, qw(-i -selection clipboard));
    return;
  }
  print STDERR "Neither xsel nor xclip is available\n";
}

sub copy2_guts {
  my ($str, $cmd, @args) = @_;
  my $pipe = Symbol::gensym;
  # Use @args because it protects against shell-escapes.
  if (!open($pipe, '|-', $cmd, @args)) {
    #!! Obnoxious error message already printed by open();
    #!! no known good way to prevent that;
    #!! no need to print our own message.
    #!! print STDERR "Unable to start cmd: $!\n";
    #!! print STDERR " +++ $cmd ", join(' ', @args), "\n";
    return;
  }
  print $pipe $str;
  if (!close $pipe) {
    my $x = ${^CHILD_ERROR_NATIVE};
    if (WIFEXITED($x)) {
      print STDERR "cmd exited with status ", WEXITSTATUS($x), "\n";
    }
    if (WIFSIGNALED($x)) {
      print STDERR "cmd killed by signal ", WTERMSIG($x), "\n";
    }
    print STDERR " +++ $cmd ", join(' ', @args), "\n";
  }
}

1;
