
(in-package :cl-bookmark-tool)

(defun format-as-lines (&rest rest)
  (format nil "~{~A~%~}" rest))

(defun file-from-opts (args opt)
  (uiop:merge-pathnames*
    (clingon:getopt args opt)
    *DEFAULT-PATHNAME-DEFAULTS*))

(defun quit-with-message (exit-code &rest message)
  (apply #'format t message)
  (uiop:quit exit-code))

(defun bookmark-tool (&rest args)
  (let ((app (top-level/command)))
    (clingon:run app args)))

(defun io-main ()
  (let ((app (top-level/command)))
    (clingon:run app)))

(defun bookmark-tool-r (input-file output-file &key (input-type "html") (output-type "html") sub-filters)
  (with-open-file (output output-file :direction :output :if-exists :supersede)
    (let ((parsed-data (extract-bookmarks-file input-type input-file :filter sub-filters)))
      (convert-out output-type output parsed-data))))

(defun tool/handler (args)
  (let* ((sub-filters       '())
         (input-file        (file-from-opts args :input-file))
         (output-file       (file-from-opts args :output-file))
         (del-dupes-val     (clingon:getopt args :delete-duplicates))
         (overwrite         (clingon:getopt args :overwrite-output))
         (filter-regex-val  (clingon:getopt args :filter-regex))
         (modify-regex-val  (clingon:getopt args :modify-regex))
         (input-type        (get-file-type (namestring input-file)))
         (output-type       (get-file-type (namestring output-file))))
    (labels
      ((parse-filter-regex (opt)
         (when opt
           (push
             (list 'sub-filter-regex (maximilian-utils:string-to-keyword (aref opt 0)) (aref opt 1))
             sub-filters)))
       (parse-modify-regex (opt)
         (when opt 
           (push 
             (list 'sub-filter-modify-regex (maximilian-utils:string-to-keyword (aref opt 0))
                   (aref opt 1) (aref opt 2))
             sub-filters)))
       (parse-delete-dupes (opt) 
         (when opt 
           (push 
             (list 'sub-filter-duplicates (string-to-keyword del-dupes-val))
             sub-filters)))
       (check-opts () ; returns integer exit code on error otherwise nil
         (cond
           ((not (uiop:file-exists-p input-file))
            (error "Input file: '~A' could not be found.~%" input-file))
           ((and (uiop:file-exists-p output-file) (not overwrite))
            (error "Output file, '~A', already exists.~%Use '--overwrite' option to overwrite it.~%" output-file))
           (t nil)))
       (filter-from-opts ()
         (parse-filter-regex filter-regex-val)
         (parse-modify-regex modify-regex-val)
         (parse-delete-dupes del-dupes-val))
       (start-func ()
         (check-opts)
         (filter-from-opts)
         (bookmark-tool-r input-file
                          output-file
                          :input-type input-type
                          :output-type output-type
                          :sub-filters (make-filter sub-filters))))
      (start-func))))

(defun tool/options ()
  (list
    #|----- required -----|#
    (clingon:make-option :filepath
                         :key         :input-file
                         :required t
                         :short-name  #\i
                         :long-name   "input-file"
                         :description "input file"
                         :parameter   "FILE")
    (clingon:make-option :filepath
                         :key         :output-file
                         :required t
                         :short-name  #\o
                         :long-name   "output-file"
                         :description "output file"
                         :parameter   "FILE")
    #|----- general ----|#
    (clingon:make-option :flag
                         :key         :overwrite-output
                         :long-name   "overwrite"
                         :description "overwrite output file")
    #|----- filter -----|#
    (clingon:make-option :choice
                         :key         :delete-duplicates
                         :short-name  #\d
                         :long-name   "delete-duplicates"
                         :items       '("url" "host" "path" "name")
                         :description (format-as-lines
                                        "delete bookmarks with same value on field."
                                        "example: --delete-duplicates 'url'"))
    (clingon:make-option :group-regex
                         :pattern      "^(path|url|host|proto|folder[-]path|name)[/](.*)$"
                         :key          :filter-regex
                         :short-name   #\r
                         :long-name    "filter-regex"
                         :parameter    "FIELD-REGEX"
                         :description (format-as-lines
                                        "filter out bookmark using regex matching on field."
                                        "format: <field>/<regex>"
                                        "allowed fields: path, url, host, proto, folder-path, name"
                                        "example: --filter-regex 'path/.*google[.]com.*'"))
    #|----- modify -----|#
    (clingon:make-option :group-regex
                         :pattern      "^(path|url|host|proto|folder[-]path|name)[/](.*)[/](.*)$"
                         :key         :modify-regex
                         :short-name  #\m
                         :long-name   "modify-field-regex"
                         :parameter   "FIELD-REGEX"
                         :description (format-as-lines
                                        "modify bookmark by field."
                                        "format: <field>/<find>/<replace>"
                                        "allowed fields: path, url, host, proto, folder-path, name"
                                        "example: --modify 'path/[?][=][0-9]+$/?=0'"))))

(defun tool/command ()
  (clingon:make-command
    :name "tool"
    :description "run tool"
    :long-description
    (format-as-lines
      "Convert, modify, and/or filter bookmarks."
      "Supported filetypes:"
      "- netscape bookmark file"
      "- json")
    :options (tool/options)
    :handler #'tool/handler))

(defun print-doc/command ()
  "Returns a command which will print the app's documentation"
  (clingon:make-command
    :name "print-doc"
    :description "print the documentation"
    :usage ""
    :handler (lambda (cmd)
               (clingon:print-documentation :markdown (clingon:command-parent cmd) t))))

(defun top-level/command ()
  (clingon:make-command
    :name "cl-bookmark-tool"
    :version "0.1.0"
    :description "Tool for converting/modifying/filtering bookmarks"
    :authors '("Maximilian Ballard")
    :license "GPLv3"
    :sub-commands (list
                    (tool/command)
                    (print-doc/command))))
