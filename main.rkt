#lang racket
(require racket/runtime-path
         web-server/templates
         web-server/servlet-env
         web-server/servlet)

(define most-recent-messages-box (box empty))
(define users (make-hasheq))
(define (user-messages-box user)
  (hash-ref! users user (λ () (box empty))))
(define (push! box m)
  (set-box! box (list* m (unbox box))))
(define (install! msg)  
  (push! (user-messages-box (message-sender msg)) msg)
  (push! most-recent-messages-box msg))

(define-struct message (sender content secs) #:prefab)

; This is a really stupid "database" :)
(define-runtime-path log-path "log")
(define (replay-log!)
  (with-handlers ([exn:fail? void])
    (with-input-from-file log-path
      (lambda ()
        (for ([v (in-port read)])
          (install! v))))))
(replay-log!)
(define log-port
  (open-output-file log-path #:exists 'append))
(define (log! msg)
  (write msg log-port))

(define-values (dispatch our-url)
  (dispatch-rules
   [("home") home-page]
   [("") home-page]
   [() home-page]
   [("register") make-user!]
   [("users" (symbol-arg)) user-page]
   [("users" (symbol-arg) "post") user-post!]))

(define (home-page req)
  (list #"text/html" (include-template "templates/home.html")))

(define (req->string req k)
  (bytes->string/utf-8
   (binding:form-value
    (bindings-assq k (request-bindings/raw req)))))

(define (make-user! req)
  (define user (string->symbol (req->string req #"user")))
  (if (hash-has-key? users user)
      (redirect-to (our-url user-page user))
      (user-update! user "Dude, I'm on PLTwitter")))

(define (user-page req user)
  (list #"text/html" (include-template "templates/user.html")))

(define (user-update! user content)
  (define msg (make-message user content (current-seconds)))
  (log! msg)
  (install! msg)  
  (redirect-to (our-url user-page user)))

(define (user-post! req user)
  (user-update! user (req->string req #"content")))

(define (start req)
  (with-handlers 
      ([exn:fail? (lambda (_) (list #"text/html" (include-template "templates/error.html")))])
    (dispatch req)))

(define-runtime-path static-files "static")
(serve/servlet start
               #:servlet-path "/home"
               #:servlet-regexp #rx""
               #:extra-files-paths
               (list static-files))