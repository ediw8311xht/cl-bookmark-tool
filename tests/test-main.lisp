(defpackage :cl-bookmark-tool/tests
  (:use :cl)
  (:use :fiveam)
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
  "Handles creating fiveam test that deals with a file.
   first argument is a list containing the name and keyword list of options

   :default-lambda-args "
  (let* ((in-file-g   (gensym))
         (out-file-g   (gensym))
         (name         (first name-and-options))
         (options      (rest name-and-options))
         (input-file   (get-file (getf options :input-file)))
         (output-file  (get-file (getf options :output-file "testout.html")))
         (clear-out    (getf options :clear-out   t))
         (default-lambda-args (getf options :default-lambda-args nil))
         )
    `(test ,name
       (let ((,in-file-g  ,input-file)
             (,out-file-g ,output-file))
         ,(if default-lambda-args
              `(funcall (lambda (infile outfile) ,@body) ,in-file-g ,out-file-g)
              `(funcall (lambda ,@body) ,in-file-g ,out-file-g))
         ;(funcall (lambda  ,@body) ,in-file-g ,out-file-g)
         (when ,clear-out (uiop:delete-file-if-exists ,out-file-g))))))

(in-suite tool-testing)
(test-with-file
  (test-file-creation :input-file "test_1_33a.html" :default-lambda-args t)
  (bookmark-tool "tool" "-i" infile "-o" outfile)
  (is (uiop:file-exists-p outfile))
  (let ((target-bookmark-count 33)
        (file-string (uiop:read-file-string outfile)))
    (is (equal target-bookmark-count (count-bookmarks file-string)))))

(test-with-file
  (test-filter-regex-host :input-file "test_1_33a.html" :default-lambda-args t)
  (bookmark-tool "tool" "-r" "host/^(.*[.])?google.com$" "-i" infile "-o" outfile)
  (is (uiop:file-exists-p outfile))
  (let ((target-bookmark-count 31)
        (file-string (uiop:read-file-string outfile)))
    (is (equal target-bookmark-count (count-bookmarks file-string)))))


(test-with-file
  (test-filter-missing :input-file "test_2_missing.html" :default-lambda-args t)
  (bookmark-tool "tool" "--delete-missing" "-i" infile "-o" outfile)
  (let ((target-bookmark-count 31)
        (file-string (uiop:read-file-string outfile)))
    (is (equal target-bookmark-count (count-bookmarks file-string)))))
;(uiop:with-safe-io-syntax (:package :cl-bookmark-tool/tests)
;  (let ((lines (uiop:read-file-lines out)))
;    ;(is (= (length lines) 33))
;    ))

