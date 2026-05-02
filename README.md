# Overview

Parses bookmarks from json or html format and filtering them based on function.

## Usage:


``` bash
cl-bookmark-tool tool <OPTS> -i <INPUT-FILE> -o <OUTPUT-FILE>
```

### Options:
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
-r, --filter-regex <FIELD-REGEX>        filter out bookmark using regex matching on field.
                                        format: <field>/<regex>
                                        allowed fields: path, url, host, proto, folder-path, name
                                        example: --filter-regex 'path/.*google[.]com.*'
```

Note on fields: 
- `{url}` = `{proto}{host}{path}`
- example: 
  - `url   = "https://www.example.com/abcd/wer?=someattr"`
  - `proto = "https://"`
  - `host  = "www.example.com"`
  - `path  = "/abcd/wer?=someattr"`

## Installing:

#### Before building
You don't need to manually install dependencies, just ensure you have `sbcl` and `quicklisp` installed and set up. 

- sbcl: https://www.sbcl.org/platform-table.html
- quicklisp: https://www.quicklisp.org/beta/#installation

#### Building
1.  clone repository
2.  cd into repo and run `make`
3.  run `./cl-bookmark-tool tool`

### Dependencies:

Dependencies can be found in the [quicklisp repo](https://github.com/quicklisp/quicklisp-projects/tree/master/projects), excluding  `maximilian-utils`, which is hosted on github ([link](https://github.com/ediw8311xht/maximilian-utils/)).

1.  `quicklisp` - remote package installing/handling
2.  `asdf` - system/package configuration
3.  `uiop` - system/file handling
4.  `clingon` - option handling
5.  `yason` - handling json
6.  `cl-ppcre` - regex library
7.  `maximilian-utils` - utilities



## Features
#### Currently implemented:

1.  Conversion between Netscape Bookmark File, JSON
2.  Filtering out bookmarks based on regex
3.  Filtering out duplicate bookmarks
4.  Modifying bookmark fields based on regex

#### In Progress:
1.  Removing/ Modifying bookmarks with urls that no longer exist or return error (e.g. 403, 404, 500)
2.  Binary Releases (order of importance: linux, mac, windows)
3.  Extracting/pushing using browser database directly

# License

GPLv3

