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

## Bottle status

### Ignition Citadel

* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_cmake2-install_bottle-homebrew-amd64/)           [ignition_cmake2](https://build.osrfoundation.org/view/ign-citadel/job/ignition_cmake2-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_tools1-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_tools1-install_bottle-homebrew-amd64/)           [ignition_tools1](https://build.osrfoundation.org/view/ign-citadel/job/ignition_tools1-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_math6-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_math6-install_bottle-homebrew-amd64/)             [ignition_math6](https://build.osrfoundation.org/view/ign-citadel/job/ignition_math6-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_common3-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_common3-install_bottle-homebrew-amd64/)         [ignition_common3](https://build.osrfoundation.org/view/ign-citadel/job/ignition_common3-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_msgs5-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_msgs5-install_bottle-homebrew-amd64/)             [ignition_msgs5](https://build.osrfoundation.org/view/ign-citadel/job/ignition_msgs5-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_fuel-tools4-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_fuel-tools4-install_bottle-homebrew-amd64/) [ignition_fuel-tools4](https://build.osrfoundation.org/view/ign-citadel/job/ignition_fuel-tools4-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_plugin1-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_plugin1-install_bottle-homebrew-amd64/)         [ignition_plugin1](https://build.osrfoundation.org/view/ign-citadel/job/ignition_plugin1-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_transport8-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_transport8-install_bottle-homebrew-amd64/)   [ignition_transport8](https://build.osrfoundation.org/view/ign-citadel/job/ignition_transport8-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_physics2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_physics2-install_bottle-homebrew-amd64/)       [ignition_physics2](https://build.osrfoundation.org/view/ign-citadel/job/ignition_physics2-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_rendering3-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_rendering3-install_bottle-homebrew-amd64/)   [ignition_rendering3](https://build.osrfoundation.org/view/ign-citadel/job/ignition_rendering3-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_gui3-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_gui3-install_bottle-homebrew-amd64/)               [ignition_gui3](https://build.osrfoundation.org/view/ign-citadel/job/ignition_gui3-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_sensors3-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_sensors3-install_bottle-homebrew-amd64/)       [ignition_sensors3](https://build.osrfoundation.org/view/ign-citadel/job/ignition_sensors3-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_gazebo3-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_gazebo3-install_bottle-homebrew-amd64/)         [ignition_gazebo3](https://build.osrfoundation.org/view/ign-citadel/job/ignition_gazebo3-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_launch2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_launch2-install_bottle-homebrew-amd64/)         [ignition_launch2](https://build.osrfoundation.org/view/ign-citadel/job/ignition_launch2-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_citadel-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-citadel/job/ignition_citadel-install_bottle-homebrew-amd64/)         [ignition_citadel](https://build.osrfoundation.org/view/ign-citadel/job/ignition_citadel-install_bottle-homebrew-amd64/)

### Ignition Blueprint

* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_cmake2-install_bottle-homebrew-amd64/)           [ignition_cmake2](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_cmake2-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_tools1-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_tools1-install_bottle-homebrew-amd64/)           [ignition_tools1](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_tools1-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_math6-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_math6-install_bottle-homebrew-amd64/)             [ignition_math6](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_math6-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_common3-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_common3-install_bottle-homebrew-amd64/)         [ignition_common3](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_common3-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_msgs4-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_msgs4-install_bottle-homebrew-amd64/)             [ignition_msgs4](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_msgs4-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_fuel-tools3-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_fuel-tools3-install_bottle-homebrew-amd64/) [ignition_fuel-tools3](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_fuel-tools3-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_plugin1-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_plugin1-install_bottle-homebrew-amd64/)         [ignition_plugin1](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_plugin1-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_transport7-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_transport7-install_bottle-homebrew-amd64/)   [ignition_transport7](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_transport7-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_physics1-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_physics1-install_bottle-homebrew-amd64/)       [ignition_physics1](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_physics1-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_rendering2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_rendering2-install_bottle-homebrew-amd64/)   [ignition_rendering2](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_rendering2-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_gui2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_gui2-install_bottle-homebrew-amd64/)               [ignition_gui2](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_gui2-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_sensors2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_sensors2-install_bottle-homebrew-amd64/)       [ignition_sensors2](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_sensors2-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_gazebo2-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_gazebo2-install_bottle-homebrew-amd64/)         [ignition_gazebo2](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_gazebo2-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_launch1-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_launch1-install_bottle-homebrew-amd64/)         [ignition_launch1](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_launch1-install_bottle-homebrew-amd64/)
* [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_blueprint-install_bottle-homebrew-amd64)](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_blueprint-install_bottle-homebrew-amd64/)         [ignition_blueprint](https://build.osrfoundation.org/view/ign-blueprint/job/ignition_blueprint-install_bottle-homebrew-amd64/)
