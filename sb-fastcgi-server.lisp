;;;
;;; sb-fastcgi : http://kdr2.net/sb-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.net
;;;
;;; License : BSD License
;;;

(in-package :sb-fastcgi)

(defun server-on-fd (func fd &key (flags 0))
  (fcgx-init)
  (with-alien ((req (struct fcgx-request)))
    (fcgx-init-request (addr req) fd flags)
    (do ((rc (fcgx-accept (addr req)) (fcgx-accept (addr req))))
        ((< rc 0) "ACCEPT ERROR")
      (funcall func (addr req))
      (sb-fastcgi:fcgx-finish (addr req)))))

(defun server-on-fd-threaded (func fd &key (flags 0) (threads 4))
  (fcgx-init)
  (do ((count 0 (1+ count)))
      ((>= count (1- threads)) 'THREADS-START-DONE)
    (sb-thread:make-thread (lambda ()
                             (server-on-fd func fd :flags flags))))
  (server-on-fd func fd :flags flags))

(defun simple-server (func)
  (server-on-fd func 0))

(defun simple-server-threaded (func &key (threads 4))
  (server-on-fd-threaded func 0 :threads threads))

(defun socket-server (func &key
                      (inet-addr "0.0.0.0")
                      (sock-path nil)
                      (port 9000))
  (let ((sock nil))
    (if (and (stringp sock-path) (> (length sock-path) 0))
        (progn
          (if (probe-file sock-path) (delete-file sock-path))
          (setf sock (make-instance 'sb-bsd-sockets::local-socket
                                    :type :stream))
          (sb-bsd-sockets:socket-bind sock sock-path))
        (progn
          (setf sock (make-instance 'sb-bsd-sockets::inet-socket
                                    :type :stream
                                    :protocol (sb-bsd-sockets::get-protocol-by-name "tcp")))
          (sb-bsd-sockets:socket-bind sock (sb-bsd-sockets:make-inet-address inet-addr) port)))
    (sb-bsd-sockets:socket-listen sock 128)
    (setf (sb-bsd-sockets:sockopt-reuse-address sock) t)
    (server-on-fd func (sb-bsd-sockets:socket-file-descriptor sock))))

(defun socket-server-threaded (func &key
                               (inet-addr "0.0.0.0")
                               (port 9000)
                               (sock-path nil)
                               (threads 4))
  (let ((sock nil))
    (if (and (stringp sock-path) (> (length sock-path) 0))
        (progn
          (if (probe-file sock-path) (delete-file sock-path))
          (setf sock (make-instance 'sb-bsd-sockets::local-socket
                                    :type :stream))
          (sb-bsd-sockets:socket-bind sock sock-path))
        (progn
          (setf sock (make-instance 'sb-bsd-sockets::inet-socket
                                    :type :stream
                                    :protocol (sb-bsd-sockets::get-protocol-by-name "tcp")))
          (sb-bsd-sockets:socket-bind sock (sb-bsd-sockets:make-inet-address inet-addr) port)))
    (sb-bsd-sockets:socket-listen sock 128)
    (setf (sb-bsd-sockets:sockopt-reuse-address sock) t)
    (server-on-fd-threaded func
                           (sb-bsd-sockets:socket-file-descriptor sock)
                           :threads threads)))

