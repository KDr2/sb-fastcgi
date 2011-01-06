;;;
;;; sb-fastcgi : http://kdr2.net/sb-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.net
;;;
;;; License : BSD License
;;;


(in-package :sb-fastcgi)

(define-alien-type nil
    (struct fcgx-request
            (request-id int)
            (role int)
            (in (* t))
            (out (* t))
            (err (* t))
            (envp (* t))
            (params-ptr (* t))
            (ipc-fd int)
            (is-begin-processed int)
            (keep-connection int)
            (app-status int)
            (nwriters int)
            (flags int)
            (listen-sock int)))

(defun fcgx-init ()
  (alien-funcall (extern-alien "FCGX_Init" (function int))))

#+nil
(defun make-fcgx-request ()
  (make-alien (struct fcgx_request)))
#+nil
(defun free-fcgx-request (req)
  (free-alien req))

(defun fcgx-init-request (request sock flags)
  (alien-funcall (extern-alien "FCGX_InitRequest"
                               (function int (* (struct fcgx_request)) int int))
                 (cast request (* (struct fcgx_request))) sock flags))

(defun fcgx-accept (req)
  (alien-funcall (extern-alien "FCGX_Accept_r"
                               (function int (* (struct fcgx_request))))
                 (cast req (* (struct fcgx_request)))))

(defun fcgx-finish (req)
  (alien-funcall (extern-alien "FCGX_Finish_r"
                               (function void (* (struct fcgx_request))))
                 (cast req (* (struct fcgx_request)))))

(defun fcgx-puts (req content &key (stream :out))
  (let ((ostr nil))
    (cond
      ((eql stream :err)
       (setf ostr (slot req 'err)))
      (t (setf ostr (slot req 'out))))
    (alien-funcall (extern-alien "FCGX_PutS" (function int c-string (* t)))
                   content ostr)))


(defun fcgx-getparam (req key)
  (let ((env (slot req 'envp)))
        (alien-funcall (extern-alien "FCGX_GetParam"
                                     (function c-string c-string (* t)))
                       key env)))

(defun fcgx-getenv (req)
  (let ((env (slot req 'envp))
        (flag t)
        (item nil)
        (ret nil))
    (setf env (cast env (* (* char))))
    (do ((index 0 (1+ index)))
        ((not flag) 'done)
      (setf item (cast (deref env index) c-string))
      (if item
          (push item ret)
          (setf flag nil)))
    (mapcar #'split-headers-to-cons ret)))
