;;;
;;; sb-fastcgi : https://kdr2.com/project/sb-fastcgi.html
;;;
;;; Author : KDr2 <zhuo.dev@gmail.com>  https://kdr2.com
;;;
;;; License : BSD License
;;;

(in-package :sb-fastcgi)

;;/home/kdr2/work/mine/sb-fastcgi/c_src/libfcgi.so

(defparameter *libfcgi-loaded* nil)

(defun load-libfcgi (&optional (path "/usr/lib/libfcgi.so"))
  (if *libfcgi-loaded*
      "libfcgi already loaded!"
      (progn
        (sb-alien:load-shared-object (make-pathname :name path))
        (setf *libfcgi-loaded* t))))


(defun split-headers-to-cons (str)
  (let ((pos (position #\= str :start 1)))
    (if pos
        (cons (subseq str 0 pos) (subseq str (1+ pos)))
        nil)))


(defun default-headers ()
  (list (cons "X-powered-by" "SBCL:sb-fastcgi")
        (cons "Content-Type" "text/html")))

(defun merge-headers (old-headers new-headers)
  (dolist (item new-headers)
    (let ((v (member (car item) old-headers :key #'car :test #'equal)))
      (if v
          (setf (cdar v) (cdr item))
          (push item old-headers))))
  old-headers)
