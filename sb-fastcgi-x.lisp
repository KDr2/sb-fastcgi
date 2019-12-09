;;;
;;; sb-fastcgi : http://kdr2.com/project/sb-fastcgi.html
;;;
;;; Author : KDr2 <zhuo.dev@gmail.com>  http://kdr2.com
;;;
;;; License : BSD License
;;;


(in-package :sb-fastcgi)


(defvar *read-buffer-size* 1024)

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

(defun fcgx-puts-utf-8 (req content &key (stream :out))
  (let ((ostr nil))
    (cond
      ((eql stream :err)
       (setf ostr (slot req 'err)))
      (t (setf ostr (slot req 'out))))
    (alien-funcall (extern-alien "FCGX_PutS"
				 (function int (c-string
						:external-format :utf-8
						:element-type character)
					   (* t)))
                   content ostr)))

;;TODO : make these bufffers thread-local?
(defun fcgx-read (req)
  (let* ((buf (make-alien char *read-buffer-size*))
         (istr (slot req 'in))
         (content
          (make-array *read-buffer-size*
                      :fill-pointer 0
                      :element-type '(unsigned-byte 8)))
         (readn
          (alien-funcall (extern-alien "FCGX_GetStr"
                                       (function int c-string int (* t)))
                         buf *read-buffer-size* istr)))
    ;;copy data
    (loop for i from 0 upto (1- readn) do
         (vector-push (deref buf i) content))
    (free-alien buf)
    (values content readn)))

(defun fcgx-read-all (req)
  (let ((contents nil)
        (length 0)
        (last-read *read-buffer-size*))
    (do ()
        ((< last-read *read-buffer-size*))
      (multiple-value-bind (c l) (fcgx-read req)
        (push c contents)
        (setf length (+ length l))
        (setf last-read l)))
    (setf contents (nreverse contents))
    (push 'vector contents)
    (values contents length)))

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
