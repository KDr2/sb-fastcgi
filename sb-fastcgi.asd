;;;
;;; sb-fastcgi : http://kdr2.net/sb-fastcgi.html
;;;
;;; Author : KDr2 <killy.draw@gmail.com>  http://kdr2.net
;;;
;;; License : BSD License
;;;

(asdf:defsystem #:sb-fastcgi
  :name "sb-fastcgi"
  :author "KDr2 <killy.draw@gmail.com>"
  :licence "BSD License"
  :description "FastCGI wrapper for SBCL"
  :depends-on (#-sbcl #:babel #-sbcl #:sb-alien #:sb-bsd-sockets)
  :serial t
  :components ((:file "package")
               (:file "sb-fastcgi")
               (:file "sb-fastcgi-x")
               (:file "sb-fastcgi-server")
               (:file "sb-fastcgi-wsgi")))
