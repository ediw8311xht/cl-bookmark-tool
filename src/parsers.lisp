
(in-package :cl-bookmark-tool)

(defparameter *HTML-NODE*
  (ppcre:create-scanner 
    "([^<]|\\r|\\n)*?  # group 1: any extra characters before tag
     <                 #
     ([^>\ ]+)         # group 2: tag name
     ([^>]*?)          # group 3: attributes
     >                 #
     (([^<]|\\r|\\n)*) # group 4: text of element or proceeding characters" 
     :case-insensitive-mode t :multi-line-mode t :extended-mode t))
(defparameter *HTML-COMMENT*
  (ppcre:create-scanner
    "(<!--)
     (.|\\r|\\n)+?
     (-->)"
    :case-insensitive-mode t :multi-line-mode t :extended-mode t))
(defparameter *HTML-ATTRIBUTE*
  (ppcre:create-scanner 
    "[\\s|\\r|\\n]* # 
    ([^=\\s]+)      # group 1: attribute
    (               # group 2: checking if attribute has value 
       [=]          #   |
       (['\"])      #   | group 3: character for grouping value
       (.+?)        #   | group 4: attribute value
       (?<!\\\\)\\3 #
    )?              #"
    :case-insensitive-mode t :multi-line-mode t :extended-mode t))

(defun clean-folder (folder) (remove #\/ folder))

#|
-------------------------
-- JSON -----------------
-------------------------
|#
(defun json-parse (input-table &key filter
                               &aux output)
  (labels
    ((recurse-else (&rest args) (declare (ignore args)) t)
     (recurse-list (data folder-path)
       (dolist (el data) (recurse el folder-path)))
     (recurse-hash-table (data folder-path 
                               &aux (data-type (gethash "type" data)))
       (cond
         ((string-equal "folder" data-type)
          (recurse (gethash "children" data)
                   (concatenate 'string folder-path (clean-folder (gethash "name" data)) "/")))
         ((string-equal "url" data-type)
          (let* ((url (gethash  "url" data))
                 (name (gethash "name" data))
                 (bookmark (create-bookmark url :name name :folder-path folder-path)))
            (setf output (funcall filter bookmark output))))
         (t
          (maphash #'(lambda (key value)
                       (declare (ignore key))
                       (recurse value folder-path))
                   data))))
     (recurse (data folder-path)
       (typecase data
         (hash-table (recurse-hash-table data folder-path))
         (list       (recurse-list       data folder-path))
         (t          (recurse-else       data folder-path)))))

    (recurse input-table "")
    output))

#|
-------------------------
-- HTML -----------------
-------------------------
|#
(defun html-remove-extra (str) (ppcre:regex-replace-all *HTML-COMMENT* str ""))

(defun subseq-create (str start end &key (default ""))
  (if (and start end)
      (subseq str start end)
      default))

(defun get-el-type (str start end)
  (if (equalp (aref str start) #\/)
      (string-to-keyword (format nil "~A-END" (subseq str (+ 1 start) end)))
      (string-to-keyword (subseq str start end))))

(defun next-element (str &key (start 0))
  (multiple-value-bind (match-start match-end group-start group-end) (ppcre:scan *HTML-NODE* str :start start)
    (when (and match-start match-end)
      (values (get-el-type str (aref group-start 1) (aref group-end 1))
              match-end
              (subseq-create str (aref group-start 2) (aref group-end 2))
              (subseq-create str (aref group-start 3) (aref group-end 3))))))

(defun extract-bookmark-href (str &key (start 0))
  (multiple-value-bind (match-start match-end group-start group-end) (ppcre:scan *HTML-ATTRIBUTE* str :start start)
    (when match-start
      (if (string-equal "HREF" (subseq-create str (aref group-start 0) (aref group-end 0)))
          (subseq-create str (aref group-start 3) (aref group-end 3))
          (extract-bookmark-href str :start match-end)))))

(defun html-parse (str &key filter)
  (let ((str (html-remove-extra str))
        (current-pos 0)
        (str-end-pos (length str))
        (output      nil)
        (folder-path ""))
    (labels
      ((push-folder (new-folder)
         (setf folder-path (concatenate 'string folder-path (clean-folder new-folder) "/")))
       (pop-folder ()
         (setf folder-path (ppcre:regex-replace "[^/]*[/]$" folder-path "")))
       (handle-bookmark (info text) 
         (setf output 
               (funcall filter 
                        (create-bookmark (extract-bookmark-href info) 
                                         :name text 
                                         :folder-path folder-path)
                        output)))
       (rec ()
         (if (>= current-pos str-end-pos)
             output
             (multiple-value-bind (el-type match-end el-info el-text) (next-element str :start current-pos)
               (setf current-pos (or match-end str-end-pos))
               (case el-type
                 ; folder start
                 ((:H3 :H1) (push-folder el-text))
                 ; folder end
                 ((:DL-END) (pop-folder))
                 ; bookmark
                 (:A      (handle-bookmark el-info el-text))
                 ; we can ignore the other tags
                 (t nil))
               (rec)))))
      (rec)
      output)))
#|
-------------------------
-- ENTRY ----------------
-------------------------
|#
(defgeneric extract-bookmarks (data-type string-data &key filter)
  (:documentation "Handle extraction of bookmarks from a string of data.
   Output: output of the extracted bookmarks (list or hash-table).
   data-type: keyword denoting type of data to parse (html or json). (or lisp ) to-do
   string-data: data to parse.
   filter: excludes bookmarks from being added if returns non nil"))

(defmethod extract-bookmarks ((data-type (eql :json)) string-data &key filter)
  (let ((json-table  (yason:parse string-data)))
    (json-parse json-table :filter filter)))

(defmethod extract-bookmarks ((data-type (eql :html)) string-data &key filter)
  (html-parse string-data :filter filter))

(defun extract-bookmarks-file (data-type file &key filter)
  "Wraps extract-bookmark, handles detection of data type and reading in the file.
  Alternatively, user may manually provide data-type using :filetype"
  (let ((string-data (uiop:read-file-string file)))
    (extract-bookmarks data-type string-data :filter filter)))

