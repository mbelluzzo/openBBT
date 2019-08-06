# Clear Linux OS* Bundle-based Test (BBT) Suite

This repository contains build acceptance tests used to evaluate the functional
correctness of content assembled into a distribution based on groups of
packages.

## Running Tests and Getting Results

Generally speaking, to run tests, execute `<repodir>/control/run.sh`.  If no
options are passed, all possible BAT tests are executed for the bundles that
are installed.  Options may be passed to filter which tests get run by group
(bundle folder name) or by label (arbitrary tag associated with a test).  Pass
the `-h` option for more information on how to filter tests that get run.  With
this manner of running tests, results will be saved to `<repodir>/results`.

To run tests at an individual file level, execute `bats -t ./<test_file_name>`
while changed into the working direcotry of the test file.  With this manner of
running tests, results will be logged to the standard output.

## Test Result Output

All test results are formatted according to the Test Anything Protocol (TAP).
This was chosen to allow all build and release systems work with test results
in a single format.

## Writing Tests

When writing a test, it is important to fully define all of the requirements
for running the test properly.  Answering the following questions defines the
necessary requirements:
* What bundles are needed?
* How much disk space is needed?
* How much RAM and CPU is needed?
* What other characteristics of the environment are required?

After defining all testing requirements, tests may be written.  Tests for this
repository are written to execute with `bats`.  The
[README.md](https://github.com/bats-core/bats-core/blob/master/README.md) for
`bats` descirbes how to write tests.  Conventionally, tests written to execute
with `bats` are saved in a test file with a `.bats` extension.  However, this
repository names test files with a `.t` extension.  Changing the test file
extension does not affect execution.

While not recommended, depending on the test process, a test file may be a bash
script without any `bats` tests in it.  While `bats` is the usual TAP producer,
any shell script capable of producing TAP results may be constructed to achieve
more complex integration.  This may include calling out to `bats` again,
because it is a TAP producer.

### What bundles are needed?

Relevant files:
* requirements
  * Defines the bundles being tested and the bundles required for proper test
    execution
  * Used by `run.sh` to determine if an environment has the required bundles
    installed and can run tests
* clr-installer.yaml
  * Defines a raw image
  * Used by clr-installer to provision a virtual environment for running tests

Tests will need some number of bundles to execute properly.  The smallest
possible bundle list should be defined in the `requirements` file.   This
bundle list should not include the standard `os-core`, `os-core-update`,
`os-testsuite`, and `kernel-*` bundles required for any environment to operate
and run tests.  This same bundle list must also be present in the `Bundles`
section of the clr-installer.yaml file.

### How much disk space is needed?

Relevant files:
* clr-installer.yaml

Tests will need some amount of disk space during exeution. The virtual
environment will need some amount of disk space for the bundles listed in the
`requirements` file in addition to that needed by the standard bundles required
for any environment to operate and run tests.  A general rule of thumb to
follow:

```
space needed during test execution + 2 * space needed for all bundles = total space
```

The multiplier is required to allow for a fast install of content into the raw
image file with swupd.  The swupd state directory can be placed inside the
image and content may be hardlinked to avoid a slow copy over a partition
boundary.  The end result is a reduction in image creation time.

### How much RAM and CPU is needed?

Relevant files:
* clear.xml
  * Defines the full domain description of a virtual machine
  * Used by `libvirt` to start a virtual machine

Tests will need some amount of RAM and CPU in order to execute correctly.
Under provisioning resources to a virtual machine may cause tests to falsely
fail.  Over provisioning creates competition for resources as multiple virtual
machines may be executed on a single server.

### What other characteristics of the environment are required?

Relevant files:
* labels
  * CSV format: `<label>,<test_file_name>`
  * Used by `run.sh` to limit which tests get run

Tests will need executed in particular contexts.  A test may need run
physically, but not virtually.  Or, a test may need run virtually, but not
physically.  Still yet, a test may require specialized hardware support.  To
identify which contexts in which a test needs to run, a label describing the
context can be created with a label-to-test file name mapping in the `labels`
file.  A test file may show up multiple times but under different labels, or
for only one label.  Each line in the `labels` file can only contain one
label-to-test file name mapping.

The main labels that exist are:
* virtual
  * Usage requires the presence of `clr-installer.yaml` and `clear.xml` files
  * Tests will run in a full virtual environment defined by the relevant files
* physical
  * A subset of tests that are important to run on a baremetal system
  * Only use for when virtual validation is not enough

If specialized hardware support is required, a new label indicating the
specific hardware may be added to the `labels` file.  To have tests requiring
specialized hardware support run regularly, engage with the DevOps and QA team
for provisioning.

*OTHER NAMES AND BRANDS MAY BE CLAIMED AS THE PROPERTY OF OTHERS
