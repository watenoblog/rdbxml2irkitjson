(use sxml.ssax)
(use sxml.sxpath)
(use srfi-60)
(use gauche.sequence)

(define (to-duration code
                     header-high header-low
                     stop-high stop-low
                     data0-high data0-low
                     data1-high data1-low)
  (define (byte-to-duration x)
    (fold-right
     (^(x y)
        `(,@(if x
                `(,data1-high ,data1-low)
              `(,data0-high ,data0-low))
          ,@y))
     '() (integer->list x 8)))
  `(,header-high ,header-low
    ,@(fold-right (^(x y) `(,@(byte-to-duration x) ,@y)) '() code)
    ,stop-high ,stop-low
    ))

(define (string->number-list x)
  (map (^x (string->number (apply string x) 16))
       (slices (string->list x) 2)))

(define (to-count x) (* x 2))

(define (to-json duration)
  (display "{")
  (display "\"format\":\"raw\",")
  (display "\"freq\":\"38\",")
  (display "\"data\":[")
  (display (string-join (map (compose x->string to-count) duration) ","))
  (display "]}")
  (newline)
  )

(define (rdbxml2irkitjson xml)
  (let* ((arg-list '(header_high header_low
                     stop_high   stop_low
                     code0_high  code0_low
                     code1_high  code1_low))
         (args (map (^x (x->number (car ((sxpath `(// ,x *text*)) xml))))
                    arg-list)))
    (for-each-with-index
     (^(i p)
        (print #`"*Page,(+ i 1)")
        (for-each
         (^(b)
            (and-let* ((signal ((sxpath '(// signal *text*)) b))
                       ((not (null? signal))))
              (display (car ((sxpath '(@ name *text*)) b)))
              (display ":")
              (to-json (apply to-duration
                              (string->number-list (car signal)) args))))
         ((sxpath '(// button)) p)))
     ((sxpath '(// page)) xml))
    ))

(define (main args)
  (let1 xml (ssax:xml->sxml (current-input-port) '())
    (rdbxml2irkitjson xml))
  0)

