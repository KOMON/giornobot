(require json)
(require net/url-string)
(require request)

(define slack-requester
  (make-domain-requester
   "slack.com/api/"
   (make-https-requester http-requester)))

(define slack-token (make-parameter ""))

(define (make-json-body jsexpr)
  (with-output-to-bytes
   (lambda () (write-json jsexpr))))

(define-syntax-rule (with-slack-auth token body)
  (parameterize ([slack-token token]) body))

(define (slack-request method endpoint [body ""] #:headers [headers '()])
  (let ([request-headers (cons (format "Authorization: Bearer ~s"
                                       (slack-token))
                               headers)])
    (http-response-body (cond [(eq? method 'get)  (get slack-requester
                                                       endpoint
                                                       #:headers request-headers)]
                              [(eq? method 'post) (post slack-requester
                                                        endpoint body
                                                        #:headers
                                                        (cons
                                                         "Content-type: application/json"
                                                         request-headers))]))))

(define (channels/list)
  (slack-request 'get "channels.list"))

(define (users/list)
  (slack-request 'get "users.list"))

(define (chat/postMessage channel text #:icon_emoji [icon_emoji ""])
  (let ([body (make-json-body (hasheq 'channel channel
                                      'text text
                                      'icon_emoji icon_emoji))])
    (slack-request 'post "chat.postMessage" body)))


(define (chat/postEphemeral channel text user)
  (let ([body (make-json-body (hasheq 'channel channel
                                      'text text
                                      'user user))])
    (slack-request 'post "chat.postEphemeral" body)))

