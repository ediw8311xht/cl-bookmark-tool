
(in-package :cl-bookmark-tool)

(defun split-url (url)
  "split url into scheme host path
  \"https://www.google.com/ihategoogle/\" -> (\"https://\" \"www.google.com\" \"/ihategoogle/\") "
  (ppcre:register-groups-bind (scheme host path)
                              ("^([^:]*[:][/]{2})([^/]*)(.*)$" url)
                              (values scheme host path)))

(defstruct-with-helpers (bookmark (:with-get-set slot) (:export t))
  "Bookmark information

  SCHEME:      url scheme
  HOST:        url host
  PATH:        url path
  NAME:        bookmark name
  FOLDER-PATH: folder path of bookmark

  Example:
      SCHEME:        \"https://\"
      HOST:          \"example.com\"
      PATH:          \"/something/here\"
      NAME:          \"An Example\"
      FOLDER-PATH:   \"/Programming/Examples/\""
  (scheme      "https://" :type string)
  (host        ""         :type string)
  (path        ""         :type string)
  (name        ""         :type string)
  (folder-path ""         :type string))

(defun bookmark-url (bmark)
  (format nil "~A~A~A"
          (bookmark-scheme bmark)
          (bookmark-host   bmark)
          (bookmark-path   bmark)))

#| 
`bookmark-slot` generic and methods for slots are defined by defstruct-with-helpers
since url isn't a slot, I define it manually
|#
(defmethod bookmark-slot ((slot (eql :url)) obj &key set-value)
  (if set-value
      (multiple-value-bind (scheme host path) (split-url set-value)
        (bookmark-slot :scheme obj :set-value scheme)
        (bookmark-slot :host   obj :set-value host)
        (bookmark-slot :path   obj :set-value path))
      (bookmark-url obj)))

(defun create-bookmark (url &key (name "") (folder-path '()))
  "create struct bookmark with url"
  (multiple-value-bind (scheme host path) (split-url url)
    (make-bookmark :scheme scheme :host host :path path :name name :folder-path folder-path)))

(defun compare-field-bookmark (field bmark bmark2)
  (equal (bookmark-slot field bmark)
         (bookmark-slot field bmark2)))
