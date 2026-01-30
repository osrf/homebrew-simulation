---
name: Broken bottle
about: Report a broken bottle
labels: broken-bottle
---

### Checklist

- [ ] Identify change in homebrew-core that broke the bottle
    - [ ]
    - [ ] Previous similar issue
- [ ] Identify list of affected formulae
    - [ ] gz-*
- [ ] Remove broken bottles: [generic-release-homebrew_remove_dependent_bottles]([url](https://build.osrfoundation.org/job/generic-release-homebrew_remove_dependent_bottles))
    - [ ] 
- [ ] Rebuild broken bottles: [generic-release-homebrew_bump_unbottled_dependencies](https://build.osrfoundation.org/job/generic-release-homebrew_bump_unbottled_dependencies)
    - [ ] 

### Optional

Please supply your brew configuration:

### Brew configuration

<!-- Please paste your brew configuration into the following block -->

~~~
$ brew config

~~~

### Brew linkage test result

<!-- If you are reporting a broken bottle, please replace gz-common5 in the
block below with the name of the broken bottle and paste the output of
`brew linkage --test` for the broken bottle in the following block -->

~~~
$ brew linkage --test gz-common5

~~~
