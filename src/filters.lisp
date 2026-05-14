
(in-package :cl-bookmark-tool)

(defmacro defun-sub-filter (type name args &body body)
  "Used to create sub-filter function.
  Type corresponds to how the function is ran in the wrapper:

  Build in sub-filter types: 
  :independent (bookmark) -> t/nil
  -    filter based on only the bookmark,
  -    takes only the bookmark as an argument
  :relational  (bookmark, bookmark) -> t/nil
  -    use if you are filtering based on bookmark and other bookmarks in data-structure
  -    takes the bookmark and bookmark to compare to
  :modify (bookmark) -> bookmark/nil
  -    the same as :independent except may modify the bookmark
  Other args may appear before, to be passed as list to `make-filter`.


  Return values from sub-filter:
  -          t: add bookmark to output
  -        nil: don't add bookmark to output
  -   bookmark: (only with type :modify) add returned bookmark to output
  "
  (if (symbolp name)
      `(progn
         (defun ,name ,args ,@body)
         (setf (get ',name :type) ,type)
         ',name)
      (let ((e-name (gensym)))
        `(let ((,e-name (intern (string-upcase,name))))
           (setf (symbol-function ,e-name) (lambda ,args ,@body))
           (setf (get ',e-name :type) ,type)
           ',e-name))))

(defgeneric sub-filter-handler (type sub-filters bookmark output)
  (:documentation "handles specific types of bookmark sub-filters.
   returns nil if any sub-filters are false (to be sorted out)
   otherwise bookmark (to be added)"))

(defmethod sub-filter-handler ((type (eql :relational)) sub-filters bookmark output)
  (loop for bmark-i in output
        when (some #'(lambda (fn) (funcall fn bookmark bmark-i)) sub-filters)
          return nil
        finally (return t)))

(defmethod sub-filter-handler ((type (eql :independent)) sub-filters bookmark output)
  (declare (ignore output))
  (notany #'(lambda (fn) (funcall fn bookmark)) sub-filters))

(defmethod sub-filter-handler ((type (eql :modify)) sub-filters bookmark output)
  (declare (ignore output))
  (reduce #'(lambda (bmark func) (funcall func bmark)) sub-filters :initial-value bookmark))

(defmethod sub-filter-handler ((type null) sub-filters bookmark output)
  (declare (ignore sub-filters bookmark output))
  (error "No :type for symbol set on property list."))

(defmethod sub-filter-handler ((type t) sub-filters bookmark output)
  (declare (ignore sub-filters bookmark output))
  (error "No handler for :type '~S'." type))

(defun make-filter (sub-filters &key (order '(:modify)))
  "Handles calling of sub-filters and modification function.

  required_arg sub-filters - list of sub-filters
  - Sub-filters should have :type specified on the property list so they are properly handled.
  - To specify additional arguments to be called with function pass as a list:
  e.g. (list 'function-name 1 2)


  &key order - Order of functions to call
  - Description: Types not specified by order are called first. Then each type as specified by order.
  - Default: '(:modify)
  - functions with :type :modify are called last
  "
  (let ((sub-filters-plist (create-plist order)))
    (loop for sub in sub-filters
          for (func . args) = (if (listp sub) sub (list sub))
          for func-type = (get func :type)
          do (push (apply #'bind func args) (getf sub-filters-plist func-type)))
    (if (not sub-filters)
        #'cons
        #'(lambda (bookmark output)
            (loop with bmark = bookmark
                  for (fn-type fn-list) on sub-filters-plist by #'cddr
                  for res = (sub-filter-handler fn-type fn-list bmark output)
                  if res
                    do (when (bookmark-p res) (setf bmark res))
                  else
                    return output
                  finally (return (cons bmark output)))))))

#| Provided sub-filters |#

#|---- relational -----|#
(defun-sub-filter :relational
  sub-filter-duplicates (field bmark bmark2)
  (compare-field-bookmark field bmark bmark2))

#|---- independent ----|#
(defun-sub-filter :independent
  sub-filter-regex (field regex bmark)
  (ppcre:scan regex (bookmark-slot field bmark)))

(defun-sub-filter :independent
  sub-filter-missing (bmark)
  ; https://edicl.github.io/drakma/#http-request
  (let ((status-code (nth-value 1 (drakma:http-request (bookmark-url bmark) :method :HEAD))))
    (< status-code 400)))

#|---- modify ---------|#
(defun-sub-filter :modify
  sub-filter-modify-regex (field match replace bmark)
  (bookmark-slot field bmark
                 :set-value (ppcre:regex-replace-all match (bookmark-slot field bmark) replace))
  bmark)

