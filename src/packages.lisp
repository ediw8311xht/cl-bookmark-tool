
(defpackage :clingon.extensions/regex-options
  (:use :cl)
  (:import-from #:ppcre
                #:register-groups-bind
                #:scan-to-strings
                )
  (:import-from #:clingon
                #:option
                #:initialize-option
                #:derive-option-value
                #:make-option
                #:option-value
                #:option-derive-error)
  (:export :option-group-regex))

(defpackage #:cl-bookmark-tool
  (:use #:cl)
  (:nicknames #:bookmark-tool)
  (:use #:clingon.extensions/regex-options)
  (:import-from #:maximilian-utils
                #:gethash-init
                #:create-plist
                #:split-by-char
                #:defstruct-with-helpers
                #:get-file-type
                #:bind
                #:string-to-keyword)
  (:export #:bookmark-tool
           #:json-parse
           #:html-parse
           #:convert-out
           #:extract-bookmarks
           #:extract-bookmarks-file
           #:defun-sub-filter
           #:sub-filter-duplicates
           #:sub-filter-regex
           #:make-filter
           #:bookmark
           #:bookmark-scheme
           #:bookmark-host
           #:bookmark-path
           #:bookmark-name
           #:bookmark-folder-path))

