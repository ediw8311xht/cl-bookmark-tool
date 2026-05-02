(defpackage :cl-bookmark-tool/tests
  (:use :cl)
  (:use :fiveam)
  ;(:local-nicknames (:p :plump)
  ;                  (:pd :plump-dom))
  (:import-from #:cl-bookmark-tool
                #:bookmark-tool))

(in-package :cl-bookmark-tool/tests)

(def-suite root-suite
           :description "test bookmark-tool")

(def-suite tool-testing
           :description "testing options"
           :in root-suite)

#|
for now matching with regex will work, this is similar (ableit extremely
                                                               simplified)
method that i use in cl-bookmark-tool. wish i could use plump (here and in
                                                                    cl-bookmark-tool)
but the netscape bookmark format isn't valid html and was creating issues,
specifically with determining the correct folder path during parsing.
|#
(defparameter *BOOKMARK-SCAN*
  (ppcre:create-scanner
    "<A[^>]*HREF[=][^>]*>[^<]*</A>"
    :case-insensitive-mode t :multi-line-mode t :extended-mode t))

(defun count-bookmarks (string)
  (ppcre:count-matches *BOOKMARK-SCAN* string))


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun get-file (f)
    (asdf:system-relative-pathname
      "cl-bookmark-tool/tests" (format nil "test-files/~A" f))))

(defmacro test-with-file (name-and-options &body body)
  (let* ((in-file-g   (gensym))
         (out-file-g   (gensym))
         (name         (first name-and-options))
         (options      (rest name-and-options))
         (input-file   (get-file (getf options :input-file)))
         (output-file  (get-file (getf options :output-file "testout.html")))
         (clear-out    (getf options :clear-out   t)))
    `(test ,name
       (let ((,in-file-g  ,input-file)
             (,out-file-g ,output-file))
         (funcall (lambda  ,@body) ,in-file-g ,out-file-g)
         (when ,clear-out (uiop:delete-file-if-exists ,out-file-g))))))

(test-with-file
  (test-file-creation :input-file "test_1_33a.html")

  (in out)
  (bookmark-tool "tool" "-i" in "-o" out)
  (is (uiop:file-exists-p out))
  (let ((target-bookmark-count 33)
        (file-string (uiop:read-file-string out)))
    (is (equal target-bookmark-count (count-bookmarks file-string)))))

(test-with-file
  (test-filter-regex-host :input-file "test_1_33a.html")
  (in out)
  (bookmark-tool "tool" "-r" "host/^(.*[.])?google.com$" "-i" in "-o" out)
  (is (uiop:file-exists-p out))
  (let ((target-bookmark-count 31)
        (file-string (uiop:read-file-string out)))
    (is (equal target-bookmark-count (count-bookmarks file-string)))))

;(uiop:with-safe-io-syntax (:package :cl-bookmark-tool/tests)
;  (let ((lines (uiop:read-file-lines out)))
;    ;(is (= (length lines) 33))
;    ))

