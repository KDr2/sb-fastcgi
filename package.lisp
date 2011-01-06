;;;
;;; sb-fastcgi : http://kdr2.net/sb-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.net
;;;
;;; License : BSD License
;;;


(defpackage #:sb-fastcgi
  (:use :cl :sb-alien)
  (:export #:load-libfcgi
           ;;internal
           #:fcgx-init
           #:fcgx-init-request
           #:fcgx-accept
           #:fcgx-finish
           #:fcgx-puts
           #:fcgx-getparam
           #:fcgx-getenv
           ;;servers
           #:simple-server
           #:simple-server-threaded
           #:socket-server
           #:socket-server-threaded
           ;;wsgi interface
           #:make-serve-function))
