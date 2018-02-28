#lang racket

(require web-server/servlet
         web-server/servlet-env)

(define (start req)
  (response/xexpr
   `(html (head (title "Yes hallo"))
          (body (p "Gimme sugar water")))))

(serve/servlet start
               #:port 80
               #:listen-ip #f
               #:command-line? #t)
