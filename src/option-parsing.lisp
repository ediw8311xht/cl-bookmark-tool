

(in-package :clingon.extensions/regex-options)

(defclass option-group-regex (option)
  ((pattern
     :initarg :pattern
     :initform (error "Must specify regix pattern")
     :reader option-group-regex-pattern))
  (:default-initargs
    :parameter "REGEX")
  (:documentation "An option which matches on regex and returns group captures"))

(defmethod make-option ((kind (eql :group-regex)) &rest rest)
  (apply #'make-instance 'option-group-regex rest))

(defmethod derive-option-value ((option option-group-regex) arg &key)
  (multiple-value-bind (a b)
    (ppcre:scan-to-strings (option-group-regex-pattern option) arg)
    (declare (ignore a))
    (or b (error 'option-derive-error :reason (format nil "'~A' doesn't fit required pattern" arg)))))


(defmethod initialize-option ((option option-group-regex) &key)
  "Initializes the switch option kind"
  (call-next-method)
  (unless (option-value option)
    (return-from initialize-option)))
