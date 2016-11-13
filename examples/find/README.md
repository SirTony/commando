find
====

This example demonstrates using commando to build a simple file search utility.

Build the example by running `$ dub build` in this directory, the executable will be found in `./bin`

Usage: `$ find [<option>...]`

Example usage: `$ find -d "D:\Projects\commando" -p "*.d" -r`

Options
=======

- `-r`, `--recurse`

Search directory recursively

- `-R`, `--regex`

Specify that the pattern is a regular expression (defult is glob)

- `-d`, `--directory`

The directory to search

- `-p`, `--pattern`

The file name search pattern