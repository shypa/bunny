.. SPDX-License-Identifier: MIT

   author: ypsah <asyph@tutanota.com>

#####
bunny
#####

bunny is a lightweight test framework to write and run tests in bash

Writing a test
==============

A test in bunny is a shell function whose name starts with "test\_".
Its return code is used to determine whether the test passed or not:

- ``0`` means "success";
- ``75`` means the test was skipped;
- any other integer means "error".

Running tests
=============

bunny provides its own test discoverer/runner tool (ie. ``bunny``). It may run
either:

- every test;
- a set of test suites;
- a set of tests (potentially from different test suites).

Tests are run in parallel.

Example
-------

.. code:: console

    $ ./bunny test_harness.sh:test_fail
    test_harness.sh:test_fail
    --------------------------------------------------------------------------------
    failure: This is a test

    Passed in 0.008s


    Ran 1 tests: 1 passed
