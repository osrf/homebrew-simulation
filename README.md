Build | Status
-- | --
brew test-bot GitHub action | ![brew test-bot](https://github.com/osrf/homebrew-simulation/workflows/brew%20test-bot/badge.svg?branch=master&event=push)

homebrew-simulation
===================

Homebrew tap for osrf simulation software

To use:

    brew tap osrf/simulation
    brew install gz-harmonic

## Bottle status

Status        | Fortress | Harmonic | Ionic
------------- | -------- | -------- | --------
gz-cmake      | [![gz-cmake2](https://build.osrfoundation.org/buildStatus/icon?job=gz_cmake2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_cmake2-install_bottle-homebrew-amd64/)                | [![gz-cmake3](https://build.osrfoundation.org/buildStatus/icon?job=gz_cmake3-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_cmake3-install_bottle-homebrew-amd64/)                | [![gz-cmake4](https://build.osrfoundation.org/buildStatus/icon?job=gz_cmake4-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_cmake4-install_bottle-homebrew-amd64/)
gz-common     | [![gz-common4](https://build.osrfoundation.org/buildStatus/icon?job=gz_common4-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_common4-install_bottle-homebrew-amd64/)             | [![gz-common5](https://build.osrfoundation.org/buildStatus/icon?job=gz_common5-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_common5-install_bottle-homebrew-amd64/)             | [![gz-common6](https://build.osrfoundation.org/buildStatus/icon?job=gz_common6-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_common6-install_bottle-homebrew-amd64/)
gz-fuel-tools | [![gz-fuel_tools7](https://build.osrfoundation.org/buildStatus/icon?job=gz_fuel_tools7-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_fuel_tools7-install_bottle-homebrew-amd64/) | [![gz-fuel_tools9](https://build.osrfoundation.org/buildStatus/icon?job=gz_fuel_tools9-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_fuel_tools9-install_bottle-homebrew-amd64/) | [![gz-fuel_tools10](https://build.osrfoundation.org/buildStatus/icon?job=gz_fuel_tools10-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_fuel_tools10-install_bottle-homebrew-amd64/)
gz-gui        | [![gz-gui6](https://build.osrfoundation.org/buildStatus/icon?job=gz_gui6-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_gui6-install_bottle-homebrew-amd64/)                      | [![gz-gui8](https://build.osrfoundation.org/buildStatus/icon?job=gz_gui8-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_gui8-install_bottle-homebrew-amd64/)                      | [![gz-gui9](https://build.osrfoundation.org/buildStatus/icon?job=gz_gui9-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_gui9-install_bottle-homebrew-amd64/)
gz-launch     | [![gz-launch5](https://build.osrfoundation.org/buildStatus/icon?job=gz_launch5-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_launch5-install_bottle-homebrew-amd64/)             | [![gz-launch7](https://build.osrfoundation.org/buildStatus/icon?job=gz_launch7-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_launch7-install_bottle-homebrew-amd64/)             | [![gz-launch8](https://build.osrfoundation.org/buildStatus/icon?job=gz_launch8-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_launch8-install_bottle-homebrew-amd64/)
gz-math       | [![gz-math6](https://build.osrfoundation.org/buildStatus/icon?job=gz_math6-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_math6-install_bottle-homebrew-amd64/)                   | [![gz-math7](https://build.osrfoundation.org/buildStatus/icon?job=gz_math7-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_math7-install_bottle-homebrew-amd64/)                   | [![gz-math8](https://build.osrfoundation.org/buildStatus/icon?job=gz_math8-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_math8-install_bottle-homebrew-amd64/)
gz-msgs       | [![gz-msgs8](https://build.osrfoundation.org/buildStatus/icon?job=gz_msgs8-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_msgs8-install_bottle-homebrew-amd64/)                   | [![gz-msgs10](https://build.osrfoundation.org/buildStatus/icon?job=gz_msgs10-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_msgs10-install_bottle-homebrew-amd64/)                | [![gz-msgs11](https://build.osrfoundation.org/buildStatus/icon?job=gz_msgs11-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_msgs11-install_bottle-homebrew-amd64/)
gz-physics    | [![gz-physics5](https://build.osrfoundation.org/buildStatus/icon?job=gz_physics5-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_physics5-install_bottle-homebrew-amd64/)          | [![gz-physics7](https://build.osrfoundation.org/buildStatus/icon?job=gz_physics7-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_physics7-install_bottle-homebrew-amd64/)          | [![gz-physics8](https://build.osrfoundation.org/buildStatus/icon?job=gz_physics8-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_physics8-install_bottle-homebrew-amd64/)
gz-plugin     | [![gz-plugin1](https://build.osrfoundation.org/buildStatus/icon?job=gz_plugin1-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_plugin1-install_bottle-homebrew-amd64/)             | [![gz-plugin2](https://build.osrfoundation.org/buildStatus/icon?job=gz_plugin2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_plugin2-install_bottle-homebrew-amd64/)             | [![gz-plugin3](https://build.osrfoundation.org/buildStatus/icon?job=gz_plugin3-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_plugin3-install_bottle-homebrew-amd64/)
gz-rendering  | [![gz-rendering6](https://build.osrfoundation.org/buildStatus/icon?job=gz_rendering6-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_rendering6-install_bottle-homebrew-amd64/)    | [![gz-rendering8](https://build.osrfoundation.org/buildStatus/icon?job=gz_rendering8-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_rendering8-install_bottle-homebrew-amd64/)    | [![gz-rendering9](https://build.osrfoundation.org/buildStatus/icon?job=gz_rendering9-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_rendering9-install_bottle-homebrew-amd64/)
gz-sensors    | [![gz-sensors6](https://build.osrfoundation.org/buildStatus/icon?job=gz_sensors6-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_sensors6-install_bottle-homebrew-amd64/)          | [![gz-sensors8](https://build.osrfoundation.org/buildStatus/icon?job=gz_sensors8-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_sensors8-install_bottle-homebrew-amd64/)          | [![gz-sensors9](https://build.osrfoundation.org/buildStatus/icon?job=gz_sensors9-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_sensors9-install_bottle-homebrew-amd64/)
gz-sim        | [![gz-sim6](https://build.osrfoundation.org/buildStatus/icon?job=gz_sim6-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_sim6-install_bottle-homebrew-amd64/)                      | [![gz-sim8](https://build.osrfoundation.org/buildStatus/icon?job=gz_sim8-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_sim8-install_bottle-homebrew-amd64/)                      | [![gz-sim9](https://build.osrfoundation.org/buildStatus/icon?job=gz_sim9-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_sim9-install_bottle-homebrew-amd64/)
gz-tools      | [![gz-tools1](https://build.osrfoundation.org/buildStatus/icon?job=gz_tools1-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_tools1-install_bottle-homebrew-amd64/)                | [![gz-tools2](https://build.osrfoundation.org/buildStatus/icon?job=gz_tools2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_tools2-install_bottle-homebrew-amd64/)                | [![gz-tools2](https://build.osrfoundation.org/buildStatus/icon?job=gz_tools2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_tools2-install_bottle-homebrew-amd64/)
gz-transport  | [![gz-transport11](https://build.osrfoundation.org/buildStatus/icon?job=gz_transport11-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_transport11-install_bottle-homebrew-amd64/) | [![gz-transport13](https://build.osrfoundation.org/buildStatus/icon?job=gz_transport13-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_transport13-install_bottle-homebrew-amd64/) | [![gz-transport14](https://build.osrfoundation.org/buildStatus/icon?job=gz_transport14-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_transport14-install_bottle-homebrew-amd64/)
gz-utils      | [![gz-utils1](https://build.osrfoundation.org/buildStatus/icon?job=gz_utils1-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_utils1-install_bottle-homebrew-amd64/)                | [![gz-utils2](https://build.osrfoundation.org/buildStatus/icon?job=gz_utils2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_utils2-install_bottle-homebrew-amd64/)                | [![gz-utils3](https://build.osrfoundation.org/buildStatus/icon?job=gz_utils3-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_utils3-install_bottle-homebrew-amd64/)
sdformat      | [![sdformat12](https://build.osrfoundation.org/buildStatus/icon?job=sdformat12-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/sdformat12-install_bottle-homebrew-amd64/)             | [![sdformat14](https://build.osrfoundation.org/buildStatus/icon?job=sdformat14-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/sdformat14-install_bottle-homebrew-amd64/)             | [![sdformat15](https://build.osrfoundation.org/buildStatus/icon?job=sdformat15-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/sdformat15-install_bottle-homebrew-amd64/)
collection    | [![gz-fortress](https://build.osrfoundation.org/buildStatus/icon?job=gz_fortress-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-fortress/job/gz_fortress-install_bottle-homebrew-amd64/)          | [![gz-harmonic](https://build.osrfoundation.org/buildStatus/icon?job=gz_harmonic-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-harmonic/job/gz_harmonic-install_bottle-homebrew-amd64/)          | [![gz-ionic](https://build.osrfoundation.org/buildStatus/icon?job=gz_ionic-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/gz-ionic/job/gz_ionic-install_bottle-homebrew-amd64/)

## To build bottles

The https://build.osrfoundation.org jenkins instance is used for building bottles with the following job
(configured in [brew_release.dsl](https://github.com/ignition-tooling/release-tools/blob/master/jenkins-scripts/dsl/brew_release.dsl)):

* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=generic-release-homebrew_triggered_bottle_builder)](https://build.osrfoundation.org/job/generic-release-homebrew_triggered_bottle_builder/) https://build.osrfoundation.org/job/generic-release-homebrew_triggered_bottle_builder/

This jenkins job is triggered for pull requests when an administrator makes a comment
on the pull request that includes the phrase `build bottle`.
The job should appear in the GitHub build status interface for the latest commit:

![GitHub build status interface screenshot](.github/github_build_status.png)

For example, [#1157](https://github.com/osrf/homebrew-simulation/pull/1157) was created after
running our [release.py](https://github.com/ignition-tooling/release-tools/blob/master/release.py) script
and [this comment](https://github.com/osrf/homebrew-simulation/pull/1157#issuecomment-698111311)
triggered the bottle build, resulting in a successful bottle upload and [a4793387](https://github.com/osrf/homebrew-simulation/commit/a47933878a7e073225acf5ceef0960cd6cfd50b2).

Bottle builds are not triggered automatically for every pull request for several reasons:

* Not all pull requests require a bottle to be rebuilt (such as
  [#1007](https://github.com/osrf/homebrew-simulation/pull/1007) that added this text to the README)
* Successful bottle builds result in binary artifacts being immediately uploaded to our hosting provider
  so pull requests should be screened for malicious intent by administrators before triggering
  a bottle build.
    - This process differs from the approach taken by
      [homebrew/homebrew-core](https://github.com/Homebrew/homebrew-core)
      whose bottles are hosted at GitHub Packages, which hosts files
      according to the hash of their contents rather than by filename.
      The homebrew-core CI jobs will build bottles for any incoming pull request,
      which will upload bottles directly to GitHub Packages, but the SHA hash associated with these bottles will not be
      easily available unless the pull request is merged by a homebrew maintainer.

## Reasons to prefer building bottles in one pull request at a time

When releasing multiple packages in a short period of time, there may be
multiple pull requests open at the same time. While it may feel proactive to
apply the `build bottle` comment to multiple pull requests at once, please
keep the following issues in mind before doing so:

### Issue [#1990](https://github.com/osrf/homebrew-simulation/issues/1990): bottle build may fail if target branch receives commits

As documented in [#1990](https://github.com/osrf/homebrew-simulation/issues/1990),
bottle builds may fail if a pull request is merged while another bottle build
is ongoing. Until this issue is resolved, if you trigger multiple builds at
once, merging any of them before all have completed may cause one of them to
fail. Valid strategies for avoiding build failures due to this issue include:

* Building bottles for one pull request at a time and waiting until that pull
  request is merged before starting another build. If merging the pull requests
  is not urgent and you receive GitHub notifications for pull requests to this
  repository, you can use the following procedure:
    * Check if any open pull requests have ongoing bottle builds. If so,
      come back later.
    * If there are no ongoing bottle builds, check if any pull requests have
      finished building bottles that are ready to be merged and merge them.
    * Pick a remaining pull request, update its branch with the latest changes
      from the base branch and comment `build bottle`. The order is important;
      if you start a bottle building job before updating the branch with the
      latest changes, just let the build finish.
    * When you see a notifications for a commit with message "update bottle"
      in this pull request, start this process from the beginning.

* Commenting `build bottle` on any open pull requests and waiting until all
  builds have completed before merging any pull requests. Please consider
  waiting to apply additional `build bottle` comments to new pull requests
  that are opened to avoid extending the wait time.

* Cherry-picking the changes from multiple pull requests into a single pull
  request will allow the bottle updates to be built at once. This is also
  more efficient for formulae in the same dependency chain as it eliminates
  redundant checking in separate bottle building jobs. See
  [#2949](https://github.com/osrf/homebrew-simulation/pull/2949) and
  [#2957](https://github.com/osrf/homebrew-simulation/pull/2957) for examples
  of this approach.

## To disable broken bottles

When a new major or minor version of a formula is merged to homebrew-core that is a dependency of formulae
in this tap, it may break our bottles, requiring a rebuild (see
[#1728](https://github.com/osrf/homebrew-simulation/issues/1728) or
[#1708](https://github.com/osrf/homebrew-simulation/issues/1709) for example).
As the osrf/simulation bottles will be broken immediately upon the merge in homebrew-core,
it can be useful to disable the broken bottles while waiting for new bottles to be rebuilt.
The `--remove-bottle-block` parameter to `brew bump-revision` can be used in this instance.
For example, the bottle removals from
[8ca61f3d](https://github.com/osrf/homebrew-simulation/commit/8ca61f3dce52e93d3472450e33d9dc2c59523591)
in [#1742](https://github.com/osrf/homebrew-simulation/pull/1742) could be repeated with
the following commands:

~~~
brew bump-revision --remove-bottle-block ignition-msgs1
brew bump-revision --remove-bottle-block ignition-msgs5
brew bump-revision --remove-bottle-block ignition-msgs6
brew bump-revision --remove-bottle-block ignition-msgs7
brew bump-revision --remove-bottle-block ignition-msgs8
~~~

If all broken formulae properly list an explicit dependency on the breaking formula, the following
shell script loop can be used to remove all broken bottles. For example, the following
snippet was used to remove broken protobuf bottles in https://github.com/osrf/homebrew-simulation/issues/2314#issuecomment-1626396384:

~~~
cd `brew --repo osrf/simulation`/Formula
for f in $(grep -l '^ *bottle do' $(grep -rlI depend.*protobuf .) | sort)
do
  brew bump-revision --remove-bottle-block --message="broken bottle" $f
done
~~~

## Troubleshooting

* Does a new bottle need to be built for every homebrew pull request?
    - A new bottle is not needed for all pull requests.
      For example, updates to documentation or a formula's `test do` block do not change
      the installed binary and thus don't require a new bottle.
      Changing the tarball `url`, adding patches, or bumping the formula `revision` do
      require new bottles.
      If you aren't sure, just ask in the pull request.

* Do I need to wait for the `brew test-bot / test-bot` GitHub action to succeed for starting a bottle build?
    - No, you don't need to wait. You can start the bottle build as soon as the pull request is opened.

* When can I merge a pull request? Does CI need to be finished?
    - Yes, CI must be finished and successful. If a new bottle is needed, the
      `generic-release-homebrew_triggered_bottle_builder` job must be successful as well.

* I commented `build bottle`, but it did not start a
  [generic-release-homebrew\_triggered\_bottle\_builder](https://build.osrfoundation.org/job/generic-release-homebrew_triggered_bottle_builder)
  job.
    - Confirm that the [build.osrfoundation.org](https://build.osrfoundation.org) web page loads.
      If it is not accessible, an OSRF build farmer should be notified.
    - If [build.osrfoundation.org](https://build.osrfoundation.org) is operational,
      confirm that you have adequate permissions.
      Currently, you must be a member of the [github.com/ignitionrobotics](https://github.com/ignitionrobotics)
      org in order to use the `build bottle` trigger phrase (see configuration in
      [brew_release.dsl](https://github.com/ignition-tooling/release-tools/blob/2ae0424303a5/jenkins-scripts/dsl/brew_release.dsl#L181-L185)).

* I'm updating a Formula to build from a specific commit in a git repository.
How do I get the `sha256` for the tarball corresponding to that commit?
    - First, make sure that you have updated the [url](https://github.com/osrf/homebrew-simulation/blob/376e1f471ba492a936e088596dc365f2bec43798/Formula/ignition-sensors5.rb#L4) to use the commit hash that corresponds to the commit in the repository that you'd like to use.
Also be sure to update the [version](https://github.com/osrf/homebrew-simulation/blob/376e1f471ba492a936e088596dc365f2bec43798/Formula/ignition-sensors5.rb#L5), if it exists (in the example linked here, `20201028~c02cd0` is the part that needs to be modified: `20201028` is the date (year-month-day), and `c02cd0` is the first 6 characters of the commit was used in the updated url).
    - Now, run the command `wget <url>`, where `<url>` is the updated url that was just mentioned.
Once you have the `tar` file downloaded, run the command `sha256sum <file>`, replacing `<file>` with the file that was downloaded via `wget`.
The `sha256` will be printed to the console, which can then be used to update the Formula's [sha256](https://github.com/osrf/homebrew-simulation/blob/376e1f471ba492a936e088596dc365f2bec43798/Formula/ignition-sensors5.rb#L6).

* I ran the [release.py](https://github.com/ignition-tooling/release-tools/blob/master/release.py) script multiple
  times for the same release and commented `build bottle` on the pull request, but the bottle building job failed,
  with console output containing the text `Warning: Formula reports different SHA256:`.
    - It's possible that the tarball uploaded at the time the pull request was created was overwritten
      by a subsequent call to `release.py` (see [ignition-tooling/release-tools#274](https://github.com/ignition-tooling/release-tools/issues/274)).
      If so, update the `sha256` field for the tarball (see [#1156](https://github.com/osrf/homebrew-simulation/pull/1156)
      and [57fa5defcce](https://github.com/osrf/homebrew-simulation/commit/57fa5defcce) for an example).

## Jenkins implementation details

The [generic-release-homebrew\_triggered\_bottle\_builder](https://build.osrfoundation.org/job/generic-release-homebrew_triggered_bottle_builder)
jenkins job currently builds bottles for macOS 10.15 `catalina` and 10.16 `big_sur`
using the following job configurations and the
[homebrew\_bottle\_creation.bash](https://github.com/ignition-tooling/release-tools/blob/master/jenkins-scripts/lib/homebrew_bottle_creation.bash)
script:

* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=generic-release-homebrew_triggered_bottle_builder%2Flabel%3Dosx_catalina)](https://build.osrfoundation.org/job/generic-release-homebrew_triggered_bottle_builder/label=osx_catalina/) https://build.osrfoundation.org/job/generic-release-homebrew_triggered_bottle_builder/label=osx_catalina
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=generic-release-homebrew_triggered_bottle_builder%2Flabel%3Dosx_bigsur)](https://build.osrfoundation.org/job/generic-release-homebrew_triggered_bottle_builder/label=osx_bigsur/) https://build.osrfoundation.org/job/generic-release-homebrew_triggered_bottle_builder/label=osx_bigsur

If the bottle building job finishes without errors for each build configuration,
it will trigger a subsequent [repository\_uploader\_packages](https://build.osrfoundation.org/job/repository_uploader_packages/)
job that uploads the bottles to s3
and a [generic-release-homebrew\_pr\_bottle\_hash\_updater](https://build.osrfoundation.org/job/generic-release-homebrew_pr_bottle_hash_updater/)
job that commits the changes in bottle `sha256` values to the pull request branch
using [this script](https://github.com/ignition-tooling/release-tools/blob/master/jenkins-scripts/lib/homebrew_bottle_pullrequest.bash).

## Building bottles for newly supported macOS distributions

When we add support for a new version of macOS, we need to build bottles for that formula,
while ideally keeping the existing bottles. This can be done by using the `--keep-old`
parameter with `brew test-bot` and `brew bottle`.
Since [ignition-tooling/release-tools#556](https://github.com/ignition-tooling/release-tools/pull/556),
bottle builds can be triggered for a specified version of macOS using `--keep-old`
by adding special tags to the `build bottle` comment in a homebrew-simulation pull request.
Use `brew-bot-tag:` along with `build-for-new-distro-{distro}` in the comment,
where `{distro}` is the version string used in homebrew bottle blocks
(such as `catalina` or `big_sur`). See [this comment](https://github.com/osrf/homebrew-simulation/pull/1694#issuecomment-978507608)
in [osrf/homebrew-simulation#1694](https://github.com/osrf/homebrew-simulation/pull/1694)
as an example that triggered a bottle build for `big_sur` only.
Note that the `--keep-old` flag only works if the pull request does not change the
formula version. Adding a comment to a formula (as in
[osrf/homebrew-simulation#1694](https://github.com/osrf/homebrew-simulation/pull/1694))
is sufficient.
