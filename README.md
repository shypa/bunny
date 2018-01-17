# bunny

bunny is a lightweight test framework to write and run tests in bash

## Write a test

A test in bunny is a shell function whose name starts with "test\_".
Its return code is used to determine whether the test passed or not
(0 means "success", 75 means the test was skipped, any other integer means
"error").

## Run a test

bunny provides its own test discoverer/runner tool. It may run either
every test, or a set of test suites and/or a set of tests (potentially from
different test suites). Tests are run in parallel.

Example:

bunny test\_suite.sh:test\_one
