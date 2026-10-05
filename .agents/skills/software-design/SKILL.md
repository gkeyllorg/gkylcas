---
name: software-design.
description: Consider established design practices when implementing new scripts or modifying existing ones.
---

# Instructions

* Load this skill whenever new scripts are to be created, or when existing ones will be edited.

## Software design elements

### Module structure

Within each solver (e.g. core, gyrokinetic, etc), each there is (more or less) a separate folder
whose task it is to generate the kernels for a specific object or updater in Gkeyll (that is,
kernels for objects in Gkeyll's zero/ folders). Most of these gkylcas folders have two types of files:

1. A Maxima script to be run, whose name typically starts with ms-.
2. A file with functions called by ms- scripts.

In general the ms- scripts decide which kernels to generate for various dimensionalities, basis
types, and other varying properties.

### Module best practices

- The functions that ms- scripts call should have a `block([],` list in which
  all variables or local to the function should be listed. Failing to include private variables in
  this list can lead to memory leaks and erroneous results.

### Other principles to follow

- Consider extensibility, maintainability, simplicity and how modular design.
- Avoid code duplication whenever possible (e.g. write functions called
  multiple times) and without breaking layering.
- Write shorter code and refactor into a sub-module whenever possible.
