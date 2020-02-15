Build | Status
-- | --
macOS 10.14 azure pipeline | [![Build Status](https://dev.azure.com/william0339/osrf%20homebrew-simulation/_apis/build/status/osrf.homebrew-simulation?branchName=master)](https://dev.azure.com/william0339/osrf%20homebrew-simulation/_build/latest?definitionId=1&branchName=master)

homebrew-simulation
===================

Homebrew tap for osrf simulation software

To use:

brew tap osrf/simulation

## To build bottles

The https://build.osrfoundation.org jenkins instance is used for building bottles with the following job:

* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=generic-release-homebrew_bottle_builder)](https://build.osrfoundation.org/job/generic-release-homebrew_bottle_builder/) https://build.osrfoundation.org/job/generic-release-homebrew_bottle_builder/

If you are using the `release.py` script from [osrf/release-tools](https://bitbucket.org/osrf/release-tools),
a Jenkins bottle builder job will be started automatically.
Otherwise, create a pull request to this repository and paste the pull request url into the `PULL_REQUEST_URL`
build parameter.
