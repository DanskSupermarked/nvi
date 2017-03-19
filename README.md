# Node.js Version Installer

A command-line tool to make Node.js binaries available in CI environments.

## Dependencies

OS | Will it work?
-- | --
GNU/Linux | :white_check_mark: **Yes**. Just ensure you have all the GNU software mentioned below.
macOS | :warning: **Probably**. The coreutils shipped with OS X do not work, but you can install the GNU versions using [brew](https://brew.sh/).
Windows | :white_check_mark: **With Bash for Windows, yes**. We've successfully used `nvi` in Bash for Windows. It works out of the box.

In order to run, `nvi` assumes the following software is available:

*   GNU coreutils
*   Other GNU software: `bash`, `grep`, `tar`, `tput`, `wget`

These are available in most GNU/Linux distributions and certainly through their
various package managers.

**Note**: `nvi` is tested on Ubuntu 16.04 and only Ubuntu 16.04.

## Can't I just use nvm?

We've used `nvm` for local Node.js development for a long time. It works very
well on your local machine, where you tend to have long-running bash sessions
and tend to frequently switch between Node.js versions. However, it has not been
as painless to use in CI environments, where your bash sessions tend to be very
brief and interspersed across machines, docker containers, and build jobs.

What causes this friction between CI environments and `nvm`? The answer is
essentially: bash functions.

The way `nvm` makes its functionality available to the user is as a bash
function by the same name. This bash function is loaded using your `~/.bashrc`
or `~/.bash_profile` file, and it lives while your bash session does. In
particular, `nvm` is not an executable file, it is not on your `$PATH`, and it
is not a system-wide command.

The way most recent CI environments work is by letting you group several
statements into a "job", "stage", or something similar, and then execute these
jobs in fresh Docker containers based on a small set of common images. In this
setup everything is running in its own containerized little world, and there is
no guarantee that each step in a CI job is executed within a bash context. In
our current CI, there is no such bash context, no `.bashrc` or `.bash_profile`
is loaded, and it generally requires additional workarounds to make this happen.

## Another approach: `nvi`

We really want to use containerized CI, so we considered how other dependencies
are injected in our Docker containers, and how to do the same for our Node.js
version installer. A common solution is to download an executable, put it on the
path, and then build it into the image used by your CI. This is exactly what
`nvi` strives to support.

### Design criteria

`nvi` strives to:

1.  Be a simple way to install Node.js versions in CI environments.
1.  Let you install specific versions of executables for `node` and `npm`.
1.  Let you place these `node` and `npm` executables on your `$PATH`.
1.  Let you specify your desired Node.js version in package.json.

`nvi` avoids:

1.  Providing its functionality as bash functions.
1.  Providing more features than what CI needs.
1.  Needing exotic dependencies. See the dependencies section.
1.  Having more source code than what you can skim in a few minutes.

### Usage

There is one major use case for `nvi`: install node and npm executables on your
system. To facilitate this, `nvi` has a bunch of default options, each of which
can be overridden independently if you disagree with them using CLI flags.

There are a number of paths used in downloading, extracting, and storing both
the necessary JavaScript source and executables. See `nvi --help`.

If not told otherwise, `nvi` will attempt to read `./package.json` to infer the
right version of Node.js to install. You need to either override this default
using `--node-version` or make sure your `./package.json` file contains the
following keys:

```json
{
  "engines": {
    "node": "6.10.0"
  }
}
```

This will make `nvi` install version `6.10.0`. Note that `nvi` just installs the
executables. It's up to you to put them on the `$PATH` if necessary.

## References

*   `nvi`: https://github.com/DanskSupermarked/nvi
*   `nvm`: https://github.com/creationix/nvm
