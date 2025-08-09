# Todo CLI

## Installation

Requirement: [opam](https://opam.ocaml.org/)

To install, run:

```sh
opam install .
```

To uninstall, run:

```sh
opam uninstall .
```

## Example usage

```sh
$ todo
===
Not completed todos:
===
"c" to create a new todo, input an ID to show, or "q" to quit: c
Enter todo title: My task 1
===
Not completed todos:
- 1: My task 1
===
"c" to create a new todo, input an ID to show, or "q" to quit: 1
===
Title: My task 1 (Not completed)
Created at: 2025-08-09 21:07:19
===
"u" to update, "c" to complete, "b" to go back, or "q" to quit: c
===
Not completed todos:
===
"c" to create a new todo, input an ID to show, or "q" to quit: q
```

