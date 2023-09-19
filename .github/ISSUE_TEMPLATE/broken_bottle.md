---
name: Broken bottle
about: Report a broken bottle
labels: broken-bottle
---

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

### Checklist

- [ ] Identify change in homebrew-core that broke the bottle
- [ ] Identify list of affected formulae
    - [ ] gz-*
- [ ] Remove broken bottles: for each affected formula, run `brew bump-revision --remove-bottle-block`
- [ ] Rebuild broken bottles
