;;;
;;; sb-fastcgi : http://kdr2.net/sb-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.net
;;;
;;; License : BSD License
;;;


;;; A1. load sb-fascgi asdf
(asdf:operate 'asdf:load-op 'sb-fastcgi)
;;; A2. load libfcgi.so
(sb-fastcgi:load-libfcgi "/usr/lib/libfcgi.so.0.0.0")

;;; B1. simple app using fcgi-style interface
(defun simple-app (req)
  (let ((c (format nil "Content-Type: text/plain

Hello, I am a fcgi-program using Common-Lisp~%~A~%"
                   (sb-fastcgi:fcgx-getenv req))))
    (sb-fastcgi:fcgx-puts req c)))

;;; B2. run the simple app above
(defun run-app-0 ()
  (sb-fastcgi:simple-server #'simple-app))
#+nil
(run-app-0)

;;; C1. app using WSGI-style interface
(defun wsgi-app (env start-response)
  (funcall start-response "200 OK" '(("X-author" . "Who?")
                                     ("Content-Type" . "text/html")))
  (list "ENV (show in alist format): <br>" env))

;;; C2. run app above on 0.0.0.0:9000 (by default)
(defun run-app-1 ()
  (sb-fastcgi:socket-server-threaded
   (sb-fastcgi:make-serve-function #'wsgi-app)
   :inet-addr "0.0.0.0"
   :port 9000))

;;; C3. run app above on a unix-domain-socket
(defun run-app-1-unix-sock ()
  (sb-fastcgi:socket-server-threaded
   (sb-fastcgi:make-serve-function #'wsgi-app)
   :sock-path "/tmp/sb-fastcgi.sock"))

;;; C4. a nested WSGI-style app example
(defun wsgi-app2 (app)
  (lambda (env start-response)
    (let ((content-0 (funcall app env start-response))) ; call outter app
      ;;reset X-author in headers
      (funcall start-response nil '(("X-author" . "KDr2!")))
      (append '("Prefix <br/>")  content-0 '("<br/>Postfix")))))

;;; C5. run (test-app1 test-app2) nested app
(defun run-app-2 ()
  (sb-fastcgi:socket-server-threaded
   (sb-fastcgi:make-serve-function (wsgi-app2 #'wsgi-app))
   :inet-addr "0.0.0.0"
   :port 9000))

;;; D. pack the webapp to a executable file
(defun make-exe (&optional (name "sbcl.fcgi"))
  (sb-ext:save-lisp-and-die name
                            :executable t
                            :purify t
                            :toplevel (lambda ()
                                        (unwind-protect (run-app-2)
                                          (sb-ext:quit)))))

