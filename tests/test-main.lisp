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
         (when ,clear-out (uiop:delete-file-if-exists ,out-file-g))
         (funcall (lambda  ,@body) ,in-file-g ,out-file-g)))))


(test-with-file
  (test-file-creation :input-file "test_1_33b.html")

  (in out)
  (bookmark-tool "tool" "-i" in "-o" out)
  (is (uiop:file-exists-p out))
  (uiop:with-safe-io-syntax (:package :cl-bookmark-tool/tests)
    (let ((lines (uiop:read-file-lines out)))
      ;(is (= (length lines) 33))
      ))
  
  )


(test-with-file
  (test-filter-regex :input-file "test_1_33b.html")
  (in out)
  (bookmark-tool "tool" "-i" in "-o" out)
  (is (uiop:file-exists-p out)))
