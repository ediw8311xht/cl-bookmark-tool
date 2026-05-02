
(defpackage :clingon.extensions/regex-options
  (:use :cl)
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
                #:bind-places
                #:string-to-keyword)
  (:export #:bookmark-tool
           ; parsers
           #:json-parse
           #:html-parse
           ; conversion/output
           #:convert-out
           #:extract-bookmarks
           #:extract-bookmarks-file
           ; filters
           #:make-filter
           #:defun-sub-filter
           #:sub-filter-handler
           #:sub-filter-duplicates
           #:sub-filter-regex
           ; for bookmark struct
           #:bookmark
           #:bookmark-url
           #:bookmark-path
           #:bookmark-proto
           #:bookmark-folder-path
           #:bookmark-slot
           #:create-bookmark
           ))

