# How to contribute without stepping over each other

## Reporting bugs
Before you do anything, make sure to look at existing issues to not make a duplicate.
If you have the same issue follow the steps below but leave it as a comment

Steps to submit a proper bug issue:
1. Make sure your installation is valid by refering to the [wiki](https://github.com/ItJustWorksTM/smce-gd/wiki)
2. Actually verify that all dependencies work (e.g. invoke cmake, arduino-cli on the commandline)
3. Write the issue, explain what happens, explain what the expected outcome should be and explain the steps to reproduce the bug
4. Include as much info as possible (operating system, version, logs gained from smce-gd itself, the arduino file you were using, ...)
5. Profit.

## Proposing features or improvements
It's best to start a [discussion](https://github.com/ItJustWorksTM/smce-gd/discussions) to propose a new feature, describe the core idea and describe how it would realistically look.
Once a core developer has shown interest to implement it, go ahead and make an actual issue reiterating the feature concretely.

## Contributing PRs
To find something to work on, refer to the [issues](https://github.com/ItJustWorksTM/smce-gd/issues) or [discussion](https://github.com/ItJustWorksTM/smce-gd/discussions) page.
Longer standing issues probably can use an extra brain to think about.

The majority of this project solely developed [@RuthgerD](https://github.com/RuthgerD) which means development plans are often offline, as such be sure to contact him or even better, make an [issues](https://github.com/ItJustWorksTM/smce-gd/issues) or start a [discussion](https://github.com/ItJustWorksTM/smce-gd/discussions) to talk about implementation details.

Once you have your changes, make a PR merging into ``devel`` and make sure to have:
* A PR description explaining the rationale of your solution
* Small commits that touch a small part of the project individually
* Meaningful commit messages that explain what part of the project they touch and what they do (refer to existing commits as examples)
* Properly formatted code (clang-format is checked on ci)
* Code comments/docs in the right places that briefly explain what the code does



