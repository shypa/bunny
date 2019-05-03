#! /bin/bash
#
# Copyright (c) 2017-2018 ypsah
# Licensed under MIT (https://github.com/ypsah/bunny/blob/master/LICENSE.txt)
#

function fail()
{
    local message="$1"
    shift

    printf "failure: $message\n" "$@" >&2
    exit 1
}

function skip()
{
    local message="$1"
    shift

    printf "skipping: $message\n" "$@" >&2
    exit 75 # EX_TEMPFAIL
}

function assert_error()
{
    local message="$1"
    shift

    printf "assertion error: $message\n" "$@" >&2

    local -i i=2
    printf "from: " >&2
    while ((i < ${#BASH_SOURCE[@]} - 1)); do
        [ $i -gt 2 ] && printf "%6s" ""
        printf "l.%i " "${BASH_LINENO[i-1]}" >&2
        printf "%s: " "${BASH_SOURCE[i]}" >&2
        printf "%s\n" "${FUNCNAME[i]}" >&2
        i+=1
    done
    exit 1
}

function assert_true()
{
    "$@" || assert_error "'%s' failed with the return code %i" "$*" "$?"
}

function assert_false()
{
    "$@" && assert_error "'%s' did not fail" "$*"
}

function assert_equal()
{
    [ "$1" == "$2" ] || assert_error "'%s' != '%s'" "$1" "$2"
}

function assert_not_equal()
{
    [ "$1" != "$2" ] || assert_error "'%s' == '%s'" "$1" "$2"
}

function assert_empty()
{
    [ -z "$1" ] || assert_error "'%s' is not empty" "$1"
}

function assert_not_empty()
{ 
    [ -n "$1" ] || assert_error "'%s' is empty" "$1"
}

function assert_in()
{
    local target="$1"
    shift

    for element in "$@"; do
        [ "$element" == "$target" ] && return
    done

    local array
    printf -v array "'%s' " "$@"
    assert_error "'%s' is not in (%s)" "$target" "${array% }"
}

function assert_not_in()
{
    local target="$1"
    shift

    for element in "$@"; do
        if [ "$element" == "$target" ]; then
            local array
            printf -v array "'%s' " "$@"
            assert_error "'%s' is in (%s)" "$target" "${array% }"
        fi
    done
}

function assert_greater()
{
    [ "$1" -gt "$2" ] || assert_error "%s <= %s" "$1" "$2"
}

function assert_greater_equal()
{
    [ "$1" -ge "$2" ] || assert_error "%s < %s" "$1" "$2"
}

function assert_less()
{
    [ "$1" -lt "$2" ] || assert_error "%s >= %s" "$1" "$2"
}

function assert_less_equal()
{
    [ "$1" -le "$2" ] || assert_error "%s > %s" "$1" "$2"
}

function assert_exists()
{
    [ -e "$1" ] || assert_error "'%s' does not exist" "$1"
}

function assert_missing()
{
    [ ! -e "$1" ] || assert_error "'%s' exists" "$1"
}

function assert_file()
{
    [ -f "$1" ] || assert_error "'%s' is not a file" "$1"
}

function assert_not_file()
{
    [ ! -f "$1" ] || assert_error "'%s' is a file" "$1"
}

function assert_directory()
{
    [ -d "$1" ] || assert_error "'%s' is not a directory" "$1"
}

function assert_not_directory()
{
    [ ! -d "$1" ] || assert_error "'%s' is a directory" "$1"
}

function assert_empty_directory()
{
    assert_directory "$1"

    (
        shopt -s dotglob nullglob
        for _ in "$1"/*; do
            exit 1
        done
    ) || assert_error "'%s' is not an empty directory" "$1"
}

function assert_not_empty_directory()
{
    assert_directory "$1"

    (
        shopt -s dotglob nullglob
        for _ in "$1"/*; do
            exit 0
        done
        exit 1
    ) || assert_error "'%s' is an empty directory" "$1"
}

function stack_trap()
{
    local arg="$1"
    local sigspec="$2"

    local oldtrap="$(trap -p "$sigspec")"
    oldtrap="${oldtrap:+"; ${oldtrap#trap -- \'}"}"

    local newtrap="$(trap -- "$arg" "$sigspec"
                     trap -p "$sigspec"
                     trap -- '' "$sigspec")"

    eval "${newtrap%\' $sigspec}${oldtrap:-"' $sigspec"}"
}

function assert_completes()
{
    local pid="$1"
    local -i timeout=${timeout:-1} # seconds
    local -i deadline=$((SECONDS + timeout))
    local -i tempo=10000 # microseconds
    local -i max_tempo=$((timeout * 1000000 / 10))

    local cmd
    cmd="$(ps --no-header -o args "$pid")"

    while true; do
        kill -0 "$pid" 2>/dev/null || return 0
        if ((SECONDS > deadline)); then
           break
        elif ((SECONDS + tempo / 1000000 > deadline)); then
            sleep $((deadline - SECONDS))
        else
            usleep $tempo
            ((tempo < max_tempo)) && ((tempo += tempo))
        fi
    done

    assert_error "'%s' did not complete in '%i' seconds" "$cmd" "$timeout"
}
