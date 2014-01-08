;;;
;;; sb-fastcgi : http://kdr2.com/project/sb-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.com
;;;
;;; License : BSD License
;;;

(in-package :sb-fastcgi)

(defun gen-start-response ()
  (let ((save-status "200 OK")
        (save-headers (default-headers)))
    (lambda (status headers)
      (if status
          (setf save-status status))
      (setf save-headers (merge-headers save-headers headers))
      (values save-status save-headers))))


(defun make-serve-function (app)
  (lambda (request)
    (let* ((env (fcgx-getenv request))
           (start-response (gen-start-response))
           (content nil))
      (setf env (acons :POST-READER #'(lambda ()
                                        (fcgx-read request)) env))
      (setf content (funcall app env start-response))
      (multiple-value-bind (status headers) (funcall start-response nil nil)
        (fcgx-puts request (format nil "Status: ~A~%" status))
        (dolist (item headers)
          (fcgx-puts request (format nil "~A: ~A~%" (car item) (cdr item))))
        (fcgx-puts request (format nil "~%~%"))
        (dolist (item content)
          (fcgx-puts request (format nil "~A" item)))))))
