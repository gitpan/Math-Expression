#!/usr/bin/perl -w -I ..
#      /\
#     /  \		(C) Copyright 2003 Parliament Hill Computers Ltd.
#     \  /		All rights reserved.
#      \/
#       .		Author: Alain Williams, January 2003
#       .		addw@phcomp.co.uk
#        .
#          .
#
#	SCCS: @(#)test.pl	1.10 03/25/03 14:16:15
#
# Test program for the module Math::Expression.
# This also serves as a demonstration program on how to use the module.
#
# May want to run as:
#	PERL5LIB=.. ./test.pl

# Copyright (c) 2003 Parliament Hill Computers Ltd/Alain D D Williams. All rights reserved.
# This module is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself. You must preserve this entire copyright
# notice in any use or distribution.
# The author makes no warranty what so ever that this code works or is fit
# for purpose: you are free to use this code on the understanding that any problems
# are your responsibility.

# Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is
# hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and
# this permission notice appear in supporting documentation.

use strict;
use Math::Expression;
use POSIX;


# Values of variables in here
my %Vars = (
	'var'		=>	[42],
	'foo'		=>	[6],
	'bar'		=>	['bar'],
	'variable'	=>	[9],
);

# Return the value of a variable - return an array
# 0	Magic value to Math::Expression
# 1	Variable name
sub VarValue {
	my ($self, $name) = @_;

	my @nil;
	return @nil unless(exists($Vars{$name}));

	return @{$Vars{$name}};
}

# Return 1 if a variable is defined - ie has been assigned to
# 0	Magic value to Math::Expression
# 1	Variable name
sub VarIsDef {
	my ($self, $name) = @_;

	return exists($Vars{$name}) ? 1 : 0;
}

my $NumFails = 0;
my $ExprError;
my $RunError;
my $verbose = 0;
my $var=0;
my @arr = (1,2,3);

my $OriginalExpression;
my $Operation;

sub MyPrintError {
	printf "Error in $Operation '%s': ", $OriginalExpression;
	printf @_;
	print "\n";

	if($Operation eq 'parsing') {
		$ExprError = 1;
	} else {
		$RunError = 1;
	}
}

sub printv {
	return unless($verbose);

	if($#_ > 0) {
		my $fmt = shift @_;
		printf $fmt, @_;
	} else {
		print $_[0];
	}
}

# **** Start here ****

printf "Math::Expression Version '%s'\n", $Math::Expression::VERSION;

my $ArithEnv = new Math::Expression;

$ArithEnv->SetOpt('VarHash' => \%Vars,
		  'VarGetFun' => \&VarValue,
		  'VarIsDefFun' => \&VarIsDef,
#		  'VarSetValueFunction' => \&VarSet,
		  'PrintErrFunc' => \&MyPrintError,
		);

my $Now = time;

my @Test = (
#	'TRACE'					=>	1,		# Switch trace on
	'TRACE'					=>	0,

	'123'					=>	'123',
	'1.23'					=>	'1.23',
	'"string"'				=>	'string',
	'1 + 2 - 3'				=>	'0',
	'1 * 2 + 3'				=>	'5',
	'1 + 2 * 3'				=>	'7',
	"1 + 2 + 3 + 4"				=>	'10',
	'2 * 3 / 4'				=>	'1.5',
	'1.23 + 2'				=>	'3.23',
	'10 % 4'				=>	'2',
	'6 * 5 / 3'				=>	'10',
	'6 * 5 / 3 % 4'				=>	'2',
	'2 + 3 * 4 + 5'				=>	'19',
	'1 + 2 * 3 / 4 - 5'			=>	'-2.5',
	'2 + 3 * 4 + 5 . "foo"'			=>	'19foo',
	'"foo" . 2 + 3 * 4 - 5'			=>	'foo9',
	'"foo" . 2 + 3 * 4 - 5 . "bar"'		=>	'foo9bar',
	'1 . 2 * 3 + 4 + ( 5 . 6 )',		=>	'166',
	'2 * (3 + 4) * 5'			=>	'70',
	'2 * (3 + 4) * 5 * (1 + 2) . "bar"'	=>	'210bar',
	'(15 / 3)'				=>	'5',
	'0 + (44, 66, 22 + 1)'			=>	'23',
	'(44, 66, 22)'				=>	'44, 66, 22',
	'1 > 2'					=>	'0',
	'2 > 2'					=>	'0',
	'3 > 2'					=>	'1',

	'3 < 2'					=>	'0',
	'2 < 2'					=>	'0',
	'2 < 3'					=>	'1',

	'2 >= 3'				=>	'0',
	'3 >= 3'				=>	'1',
	'3 >= 3'				=>	'1',

	'2 <= 3'				=>	'1',
	'2 <= 2'				=>	'1',
	'3 <= 2'				=>	'0',

	'3 == 2'				=>	'0',
	'3 == 3'				=>	'1',

	'3 != 2'				=>	'1',
	'3 != 3'				=>	'0',
	'3 <> 2'				=>	'1',
	'3 <> 3'				=>	'0',

	'3 > 2 && 4 > 5'			=>	'0',
	'3 > 2 ? 99 : 200'			=>	'99',
	'3 > 4 ? 99 : 200'			=>	'200',
	'3 > 4 ? 6 + 7 : 2 + 3'			=>	'5',
	'3 > 2 ? 6 + 7 : 2 + 3'			=>	'13',

	'"abc" lt "def"'			=>	'1',
	'"abc" lt "abc"'			=>	'0',
	'"def" lt "abc"'			=>	'0',

	'"abc" gt "def"'			=>	'0',
	'"abc" gt "abc"'			=>	'0',
	'"def" gt "abc"'			=>	'1',

	'"abc" le "def"'			=>	'1',
	'"abc" le "abc"'			=>	'1',
	'"def" le "abc"'			=>	'0',

	'"abc" ge "def"'			=>	'0',
	'"abc" ge "abc"'			=>	'1',
	'"def" ge "abc"'			=>	'1',

	'"abc" eq "def"'			=>	'0',
	'"abc" eq "abc"'			=>	'1',

	'"abc" ne "def"'			=>	'1',
	'"abc" ne "abc"'			=>	'0',

	'2 && 1'				=>	'1',
	'2 && 0'				=>	'0',
	'0 && 1'				=>	'0',
	'0 && 0'				=>	'0',
	'2 || 1'				=>	'1',
	'2 || 0'				=>	'1',
	'0 || 1'				=>	'1',
	'0 || 0'				=>	'0',
	'"abc" lt "def" ? (1 + 2) : (30 * 40)'	=>	'3',
	'"abc" gt "def" ? (1 + 2) : 30 * 40'	=>	'1200',
	'"abc" gt "def" ? 1 + 2 : (30 * 40)'	=>	'1200',
	'"abc" gt "def" ? 1 + 2 : 30 * 40'	=>	'1200',


	# Variables can contain '_'
	'_fred := 10'				=>	'10',
	'_ := 9'				=>	'9',

	# Perl would treat 012 as an octal number, that would confuse.
	# Test that it is treated as a decimal number
	'1 + 012'				=>	'13',

	# Test variables defined elsewhere:
	'$var'					=>	'42',
	'1 * 2 + $variable'			=>	'11',
	'"foo" . $bar'				=>	'foobar',
	'$foo . $bar'				=>	'6bar',

	# Assignment to variables & the different forms that a variable can take:
	'$a := 10'				=>	'10',
	'3 * $a'				=>	'30',
	'3 * a'					=>	'30',
	'3 * ${a}'				=>	'30',

	# Multiple assignment:
	'$b := ($c := 98)'			=>	'98',
	'$b := $c := 99'			=>	'99',
	'b'					=>	'99',
	'c'					=>	'99',

	# This checks the code that checks that operands to numeric operators
	# are numeric. The point is that it failed for -ve numbers 'till I fixed it.
	'a := 0 - 2'				=>	'-2',
	'b := 3 + a'				=>	'1',

	# LH of := can yeild a variable that gets assigned to:
	'aa := 8'				=>	'8',
	'bb := 9'				=>	'9',
	'1 ? aa : bb := 123'			=>	'123',
	'aa'					=>	'123',
	'bb'					=>	'9',
	'0 ? aa : bb := 124'			=>	'124',
	'aa'					=>	'123',
	'bb'					=>	'124',

#	'(e := 10 );( f := 11)'			=>	'11',
#	'e'					=>	'10',
#	'f'					=>	'11',

	# Variable with no value:
	'notset'				=>	'EmptyArray',

	# A variable can be assigned an array
	'y := (13, 14, 15, 16)'			=>	'13, 14, 15, 16',

	# The simple operand value is the last element of the array:
	'y + 1'					=>	'17',

	# Array assignment:
	'z := y'				=>	'13, 14, 15, 16',

	# Check that assignment to the original does affact what we assigned to:
	'y := (42, 43)'				=>	'42, 43',
	'z'					=>	'13, 14, 15, 16',

	# Array concatenation:
	'a1 := (1, 2, 3, 4)'			=>	'1, 2, 3, 4',
	'a2 := (9, 8, 7, 6)'			=>	'9, 8, 7, 6',
	'a1 . a2'				=>	'46',		# Last values of each array
	'a1 , a2'				=>	'1, 2, 3, 4, 9, 8, 7, 6',

	# Check multiple assignment, assign corresponding values:
	'(v1, v2, v3) := (42, 44, 48)'		=>	'42, 44, 48',
	'v1'					=>	'42',
	'v2'					=>	'44',
	'v3'					=>	'48',

	# The last one gets the remaining values:
	'(v4, v5) := (42, 44, 48)'		=>	'42, 44, 48',
	'v4'					=>	'42',
	'v5'					=>	'44, 48',

	# Not enough values, so the last one is unchanged:
	'v8 := 1234'				=>	'1234',
	'(v6, v7, v8) := (42, 44)'		=>	'42, 44',
	'v6'					=>	'42',
	'v7'					=>	'44',
	'v8'					=>	'1234',

	# Assignment of arrays as part of multiple works:
	'(w1, w2) := ( 2, ( 3, 4) )'		=>	'2, 3, 4',
	'w1'					=>	'2',
	'w2'					=>	'3, 4',

	# Array assignment, where the array is one of the RH values:
	'ar := ("cat", "dog")'			=>	'cat, dog',
	'ar := (ar, "cow")'			=>	'cat, dog, cow',
	'ar'					=>	'cat, dog, cow',
	'ar := ("ant", ar)'			=>	'ant, cat, dog, cow',
	'ar'					=>	'ant, cat, dog, cow',
	'ar := ("bee", ar, "duck")'		=>	'bee, ant, cat, dog, cow, duck',
	'ar'					=>	'bee, ant, cat, dog, cow, duck',

	# Conditional actions:
	'z := 10'				=>	'10',
	'1 ? ( z := 22 ) : 9'			=>	'22',
	'z'					=>	'22',
	'0 ? ( z := 25 ) : 9'			=>	'9',
	'z'					=>	'22',

	'zl := ""'				=>	'',
	'zl := zl, "fish"'			=>	', fish',

	# Note that is it OK to string concat undef/empty and join undef/empty lists
	'zl := EmptyList',			=>	'EmptyArray',
	'zl . "foo"'				=>	'foo',
	'zl := zl, zl'				=>	'EmptyArray',
	'zl := zl, "fish"'			=>	'fish',

	# Functions:
	'printf(">>%3.3d<<", 12)'		=>	'>>012<<',
	'int(0 - 16 / 3)'			=>	'-5',
	'int(16 / 3) + 1'			=>	'6',
	'round( 1.2 )'				=>	'1',
	'round( 1.7 )'				=>	'2',
	'1 + int(16 / 3)'			=>	'6',
	'1 + int(16 / 3) * 2'			=>	'11',

	"loc := localtime($Now)"		=>	(join ', ', localtime($Now)),
	"strftime('%H:%M:%S' , loc)"		=>	strftime('%H:%M:%S', localtime($Now)),
	"mktime(loc)"				=>	"$Now",

	# Array value search:
	# (Could have also initialised with split)
	"months := 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'"	=>
		'Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec',
	"Feb := aindex(months, 'Feb')"		=>	1,
	"Sep := aindex(months, 'Sep')"		=>	8,
	"aindex(months, 'September')"		=>	-1,	# -1 is 'not found'

	'strs := split("[, ]+", "1, 2,3, 4")'	=>	'1, 2, 3, 4',
	'strs := split("[, ]+", "1")'		=>	'1',

	'list := (1, "abc", 44)'		=>	'1, abc, 44',
	'str := join("_", list)'		=>	'1_abc_44',
	'str := join("_", (1, "abc", 44))'	=>	'1_abc_44',
	'str := join("_", (144))'		=>	'144',

	# Variables defined or not, this function has special status in the evaluator:
	'defined(FooBar)'			=>	'0',
	'FooBar := "baz"'			=>	'baz',
	'defined(FooBar)'			=>	'1',

	# Here is another way that we could do a sort of defined, not not so nice:
	'BarFoo . "" ne "" ? 1 : 0'		=>	'0',
	'BarFoo := "value"'			=>	'value',
	'BarFoo . "" ne "" ? 1 : 0'		=>	'1',

	# The following cause syntax errors:
	'^ xxx'					=>	'SyntaxError',
	'2 ? 3'					=>	'SyntaxError',
	'2 +'					=>	'SyntaxError',
	'2 ++ 3'				=>	'SyntaxError',
	'+ 2'					=>	'SyntaxError',
	'+'					=>	'SyntaxError',
	'2 3'					=>	'SyntaxError',
	'2 + ( 1 +'				=>	'SyntaxError',
	'2 + ( 1'				=>	'SyntaxError',
	'2 + ('					=>	'SyntaxError',
	') + 2'					=>	'SyntaxError',
	'3 ) + 2'				=>	'SyntaxError',
	'( 3 ) 2'				=>	'SyntaxError',
	'2 ( 3 )'				=>	'SyntaxError',
	'int( 3 '				=>	'SyntaxError',

	# The following generate run time errors
	'1 + "fred"'				=>	'RunTimeError',
	'foo(3)'				=>	'RunTimeError',
);

my $Tests = 0;
for(my $inx = 0; $inx < $#Test; $inx += 2 ) {

	my $in = $Test[$inx];
	my $result = $Test[$inx + 1];

	if($in eq 'TRACE') {
		$verbose = $result;
		next;
	}

	$Tests++;

	$OriginalExpression = $in;
	$RunError = $ExprError = 0;

	print "\nParse: ''$in'' fails=$NumFails\n";
	$Operation = 'parsing';
	my $tree = $ArithEnv->Parse($in);

	if($ExprError) {
		if($result eq 'SyntaxError') {
			print "Parse fail -- as expected\n";
		} else {
			print "Parse fail -- unexpectedly\n";
			$NumFails++;
		}
		next;
	}

	unless(defined($tree)) {
		print "Tree undefined for expression ''$in''\n";
		$NumFails++;
		next;
	}

	&printv("parse => $tree\n");

	$ArithEnv->PrintTree($tree) if($verbose);

	$Operation = 'evaluating';
	my @res = $ArithEnv->EvalTree($tree, 0);

	if($#res == -1 and $result eq 'EmptyArray') {
		if($RunError) {
			printf "Failed unexpectedly\n";
			$NumFails++;
		}
		printf "Result is empty array, as expected\n";
		next;
	}

	if($#res == -1 or $RunError) {
		my $rterp = $RunError ? "run time error reported" : "run time error not reported";
		if($result eq 'RunTimeError') {
			printf "Failed at run time - as expected, %s\n", $rterp;
			next;
		}
		printf "Failed unexpectedly, %s\n", $rterp;
		$NumFails++;
		next;
	}

	&printv("expr ''$in'' ");
	if($#res == 0) {
		printf "res='$res[0]' %s\n", ($res[0] eq $result) ? 'OK' : "Should be '$result'  FAIL";
		$NumFails++ unless($res[0] eq $result);
	} else {
		my @ref = reverse split /, /, $result;
		my $ok = 'OK';
		print "Array #=$#res vals=";
		my $ev = 'Extra val ';
		foreach my $x (@res) {
			 print "'$x' ";
			 my $ref = pop @ref;
			 unless(defined($ref)) {
				print "$ev";
				$ev = '';
				$ok = 'FAIL';
				next;
			 }
			 next if($ref eq $x);
			 print "!= '$ref', ";
			 $ok = 'FAIL'
		}
		print " $ok \n";
		$NumFails++ if($ok ne 'OK');
	}
}

print "\n\n";
print "$Tests tests run\n";
print $NumFails == 0 ? "All tests OK\n" : "$NumFails tests failed\n";

# end
