# Overview

Parses bookmarks from json or html format and filtering them based on function.

### Features currently implemented:

1.  Conversion between Netscape Bookmark File, JSON
2.  Filtering out bookmarks based on regex
3.  Filtering out duplicate bookmarks
4.  Modifying bookmark based on regex

### Features to be implemented:

1.  Removing/ Modifying bookmarks with urls that no longer exist or return error (e.g. 403, 404, 500)
2.  Binary Releases (for linux, windows, mac)

# Installing:

1.  clone repository
2.  cd into repo and run `make`
3.  run `./cl-bookmark-tool tool`

# Using

`cl-bookmark-tool tool` accepts the following options:

``` shell
--help                                  display usage information and exit
--overwrite                             overwrite output file
--version                               display version and exit
-d, --delete-duplicates <CHOICE>        delete bookmarks with same value on field.
                                        example: --delete-duplicates 'url'
                                          [choices: url, host, path, name]
-i, --input-file <FILE>                  input file
-m, --modify-field-regex <FIELD-REGEX>  Modify bookmark by field.
                                        Format: <field>/<find>/<replace>
                                        Allowed Fields: path, url, host, proto, folder-path, name
                                        Example: --modify 'path/[?][=][0-9]+$/?=0'

-o, --output-file <FILE>                output file
-r, --filter-regex <STRING>             filter out bookmark using regex matching on field.
                                        format: <field>/<regex>
                                        allowed fields: path, url, host, proto, folder-path, name
                                        example: --filter-regex 'path/.*google[.]com.*'
```



# Dependencies:
You don't need to manually install dependencies. Dependencies are automatically installed by `make`, using quicklisp and asdf. Dependency `maximilian-utils` is cloned into repository as it's not (yet) available on quicklisp. Source code can be found on my github.

1.  `quicklisp` - remote package installing/handling
2.  `asdf` - system/package configuration
3.  `uiop` - system/file handling
4.  `clingon` - option handling
5.  `yason` - handling json
6.  `cl-ppcre` - regex library
7.  `maximilian-utils` - utilities

# License

GPLv3

