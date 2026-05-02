
(asdf:defsystem #:cl-bookmark-tool
  :author  "Maximilian Ballard"
  :version "0.1.1"
  :license "GPLv3"
  :depends-on (
               :uiop     ; files
               :clingon  ; option handling
               :cl-ppcre ; regex filtering
               :yason    ; json parsing
               :maximilian-utils ; general utilities
               )
  :serial t
  :components ((:module "src"
                :components
                ((:file "packages")
                 (:file "structs")
                 (:file "filters")
                 (:file "parsers")
                 (:file "writers")
                 (:file "option-parsing")
                 (:file "main"   )))
               (:static-file "LICENSE" :pathname #P"LICENSE")
               (:static-file "README.md" :pathname #P"README.md"))
  :description "Tool to convert and filter bookmarks.
  Supported input/output: json, netscape bookmark file"
  :long-description #.(uiop:read-file-string  (merge-pathnames "README.md" *load-pathname*))
  :in-order-to ((test-op (test-op "cl-bookmark-tool/tests")))
  :build-operation program-op
  :build-pathname "cl-bookmark-tool"
  :entry-point "cl-bookmark-tool::io-main")

(asdf:defsystem #:cl-bookmark-tool/tests
  :depends-on (
               :cl-bookmark-tool
               :fiveam   ; testing framework
               :uiop     ; getting/reading system files
               :cl-ppcre ; checking for occurrences of string in output/file
               ;:plump    ; checking elements in output/file
               )
  :serial t
  :components ((:module "tests"
                :components
                ((:file "test-main")))
               (:module "test-files"
                :components ((:static-file "test_1_33b.html"))))
  :description "Testing cl-bookmark-tool"
  :perform (test-op (o c) (symbol-call :fiveam '#:run-all-tests)))

