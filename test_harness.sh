#! /bin/bash
#
# Copyright (c) 2017-2018 ypsah
# Licensed under MIT (https://github.com/ypsah/bunny/blob/master/LICENSE.txt)
#

test_fail()
{
    ( fail '%s %s %s %s' "This" "is" "a" "test" )
    [ $? -eq 1 ]
}

test_skip()
{
    ( skip '%s %s %s %s' "This" "is" "a" "test" )
    [ $? -eq 75 ]
}

test_true()
{
    assert_true true
    ( assert_true false )
    [ $? -eq 1 ]
}

test_false()
{
    assert_false false
    ( assert_false true )
    [ $? -eq 1 ]
}

test_equal()
{
    assert_equal abc abc
    ( assert_equal abc bca )
    [ $? -eq 1 ]
}

test_not_equal()
{
    assert_not_equal abc bca
    ( assert_not_equal abc abc )
    [ $? -eq 1 ]
}

test_empty()
{
    assert_empty
    ( assert_empty " " )
    [ $? -eq 1 ]
}

test_not_empty()
{
    assert_not_empty " "
    ( assert_not_empty )
    [ $? -eq 1 ]
}

test_in()
{
    local array=("abc" "def" "ghi")
    assert_in "def" "${array[@]}"
    ( assert_in "a" "${array[@]}" )
    [ $? -eq 1 ]
}

test_not_in()
{
    local array=("abc" "def" "ghi")
    assert_not_in "a" "${array[@]}"
    ( assert_not_in "def" "${array[@]}" )
    [ $? -eq 1 ]
}

test_greater()
{
    assert_greater "1" "0"
    ( assert_greater "0" "0" )
    [ $? -eq 1 ]
}

test_greater_equal()
{
    assert_greater_equal "1" "0"
    assert_greater_equal "0" "0"
    ( assert_greater_equal "0" "1" )
    [ $? -eq 1 ]
}

test_less()
{
    assert_less "0" "1"
    ( assert_less "0" "0" )
    [ $? -eq 1 ]
}

test_less_equal()
{
    assert_less_equal "0" "1"
    assert_less_equal "0" "0"
    ( assert_less_equal "1" "0" )
    [ $? -eq 1 ]
}

test_exists()
{
    local file="$(mktemp)"
    stack_trap "rm -f '$file'" EXIT

    assert_exists "$file"
    rm "$file"
    ( assert_exists "$file" )
    [ $? -eq 1 ]
}

test_missing()
{
    local file="$(mktemp)"
    stack_trap "rm -f '$file'" EXIT

    ( assert_missing "$file" ) && exit 1
    rm "$file"
    assert_missing "$file"
}

test_file()
{
    local file="$(mktemp)"
    stack_trap "rm -f '$file'" EXIT

    assert_file "$file"

    local directory="$(mktemp -d)"
    stack_trap "rm -rf '$directory'" EXIT

    ( assert_file "$directory" )
    [ $? -eq 1 ]
}

test_not_file()
{
    local directory="$(mktemp -d)"
    stack_trap "rm -rf '$directory'" EXIT

    assert_not_file "$directory"

    local file="$(mktemp)"
    stack_trap "rm -f '$file'" EXIT

    ( assert_not_file "$file" )
    [ $? -eq 1 ]
}

test_directory()
{
    local directory="$(mktemp -d)"
    stack_trap "rm -rf '$directory'" EXIT

    assert_directory "$directory"

    local file="$(mktemp)"
    stack_trap "rm -f '$file'" EXIT

    ( assert_directory "$file" )
    [ $? -eq 1 ]
}

test_not_directory()
{
    local file="$(mktemp)"
    stack_trap "rm -f '$file'" EXIT

    assert_not_directory "$file"

    local directory="$(mktemp -d)"
    stack_trap "rm -rf '$directory'" EXIT

    ( assert_not_directory "$directory" )
    [ $? -eq 1 ]
}

test_empty_directory()
{
    local directory="$(mktemp -d)"
    stack_trap "rm -rf '$directory'" EXIT

    assert_empty_directory "$directory"

    local file="$(mktemp)"
    stack_trap "rm -f '$file'" EXIT

    ( assert_empty_directory "$file" )
    [ $? -eq 1 ] || exit 1

    touch "$directory/${file##*/}"

    ( assert_empty_directory "$directory" )
    [ $? -eq 1 ] || exit 1
}

test_not_empty_directory()
{
    local directory="$(mktemp -d)"
    stack_trap "rm -rf '$directory'" EXIT

    ( assert_not_empty_directory "$directory" )
    [ $? -eq 1 ] || exit 1

    local file="$(mktemp)"
    stack_trap "rm -f '$file'" EXIT

    ( assert_not_empty_directory "$file" )
    [ $? -eq 1 ] || exit 1

    touch "$directory/${file##*/}"

    assert_not_empty_directory "$directory"
}

test_completes()
{
    sleep 1 &

    ( timeout=0 assert_completes $! )
    [ $? -eq 1 ] || exit 1

    assert_completes $!
}
