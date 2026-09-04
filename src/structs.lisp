
(in-package :cl-bookmark-tool)

(defparameter *POISON-PILL* (gensym "POISON-PILL"))

(defun split-url (url)
  "split url into proto host path
  \"https://www.google.com/ihategoogle/\" -> (\"https://\" \"www.google.com\" \"/ihategoogle/\") "
  (ppcre:register-groups-bind (proto host path)
                              ("^([^:]*[:][/]{2})([^/]*)(.*)$" url)
                              (values proto host path)))

#| not using defstruct-with-helpers export since it can cause issues stale build
   files with adsf:make
|#
(defstruct-with-helpers (bookmark (:with-get-set slot) (:export nil))
  "Bookmark information

  proto:      url proto
  HOST:        url host
  PATH:        url path
  NAME:        bookmark name
  FOLDER-PATH: folder path of bookmark

  Example:
      proto:        \"https://\"
      HOST:          \"example.com\"
      PATH:          \"/something/here\"
      NAME:          \"An Example\"
      FOLDER-PATH:   \"/Programming/Examples/\""
  (proto      "https://" :type string)
  (host        ""         :type string)
  (path        ""         :type string)
  (name        ""         :type string)
  (folder-path ""         :type string))

(defun bookmark-url (bmark)
  (format nil "~A~A~A"
          (bookmark-proto bmark)
          (bookmark-host   bmark)
          (bookmark-path   bmark)))

#| 
`bookmark-slot` generic and methods for slots are defined by defstruct-with-helpers
since url isn't a slot, I define it manually
|#
(defmethod bookmark-slot ((slot (eql :url)) obj &key set-value)
  (if set-value
      (multiple-value-bind (proto host path) (split-url set-value)
        (bookmark-slot :proto obj :set-value proto)
        (bookmark-slot :host   obj :set-value host)
        (bookmark-slot :path   obj :set-value path))
      (bookmark-url obj)))

(defun create-bookmark (url &key (name "") (folder-path ""))
  "create struct bookmark with url"
  (multiple-value-bind (proto host path) (split-url url)
    (make-bookmark :proto proto :host host :path path :name name :folder-path folder-path)))

(defun compare-field-bookmark (field bmark bmark2)
  (equal (bookmark-slot field bmark)
         (bookmark-slot field bmark2)))
