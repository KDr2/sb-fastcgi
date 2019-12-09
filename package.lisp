;;;
;;; sb-fastcgi : http://kdr2.com/project/sb-fastcgi.html
;;;
;;; Author : KDr2 <zhuo.dev@gmail.com>  http://kdr2.com
;;;
;;; License : BSD License
;;;


(defpackage #:sb-fastcgi
  (:use :cl :sb-alien)
  (:nicknames #:cl-fastcgi)
  (:export #:load-libfcgi
           ;;internal
           #:fcgx-init
           #:fcgx-init-request
           #:fcgx-accept
           #:fcgx-finish
           #:fcgx-puts
           #:fcgx-puts-utf-8
           #:fcgx-read
           #:fcgx-read-all
           #:fcgx-getparam
           #:fcgx-getenv
           ;;servers
           #:simple-server
           #:simple-server-threaded
           #:socket-server
           #:socket-server-threaded
           ;;wsgi interface
           #:make-serve-function))
