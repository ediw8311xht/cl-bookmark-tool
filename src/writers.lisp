

(in-package :cl-bookmark-tool)

(defvar *NETSCAPE-HTML-HEADER*
  '("<!DOCTYPE NETSCAPE-Bookmark-file-1>"
    "<META HTTP-EQUIV='Content-Type' CONTENT='text/html; charset=UTF-8'>"
    "<TITLE>Bookmarks</TITLE>"
    "<H1>Bookmarks</H1>"))

(defun prepare-data (data-in
                      &aux (output (make-hash-table :test #'equalp)))
  (labels
    ((folder-split (bmark)
       (split-by-char (bookmark-folder-path bmark) :split-char #\/))
     (get-init-table-path (folder-path &key (out output) &aux (next (first folder-path)))
       (if (or (null next) (string= next ""))
           out
           (get-init-table-path (rest folder-path)
                                :out (gethash-init next out (make-hash-table :test #'equalp)))))
     (prepare (data)
       (loop for bmark in data
             for folder-split = (folder-split bmark)
             for pos = (get-init-table-path folder-split)
             do (push bmark (gethash "data" pos)))))
    (prepare data-in)
    output))

(defgeneric convert-out (output-type output input-data)
  (:documentation "Converts bookmarks data to output-type and sends to output (destination)."))
(defmethod convert-out ((output-type (eql :lisp)) output input-data)
  (print input-data output))
(defmethod convert-out ((output-type (eql :json)) output input-data)
  (error "Function not implemented."))
(defmethod convert-out ((output-type (eql :html)) output input-data)
  (labels
    ((write-header () (format output "~{~A~%~}~%" *NETSCAPE-HTML-HEADER*))
     (output-bookmark (bmark)
       (format output "<DT><A HREF=\"~A\">~A</A>~%"
               (bookmark-url bmark)
               (bookmark-name bmark)))
     (write-body (data &key (bookmark-folder nil))
       (when bookmark-folder (format output "<DT><H3>~A</H3>~%" bookmark-folder))
       (format output "<DL><p>~%")
       (loop for key being the hash-keys of data
             using (hash-value value)
             if (hash-table-p value)
               do (write-body value :bookmark-folder key)
             else
               do (dolist (bmark value) (output-bookmark bmark)))
       (format output "</DL><p>~%")))
    (write-header)
    (write-body (prepare-data input-data))))
