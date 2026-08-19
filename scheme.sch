;; --- Core Meta-Circular Evaluator ---

(define (mc-eval exp env)
  (cond ((symbol? exp) (env-lookup exp env))
        ((not (pair? exp)) exp)
        ((eq? (car exp) 'quote) (cadr exp))
        ((eq? (car exp) 'if)
         (if (mc-eval (cadr exp) env)
             (mc-eval (caddr exp) env)
             (mc-eval (cadddr exp) env)))
        ((eq? (car exp) 'lambda)
         (lambda args (mc-eval (caddr exp) (extend-env (cadr exp) args env))))
        (else
         (mc-apply (mc-eval (car exp) env)
                   (map (lambda (e) (mc-eval e env)) (cdr exp))))))

(define (mc-apply proc args)
  (if (procedure? proc)
      (apply proc args)
      (error "Unknown procedure type" proc)))

;; --- Environment Representation ---

(define (extend-env params args env)
  (cons (map cons params args) env))

(define (env-lookup var env)
  (cond ((null? env) (error "Unbound variable" var))
        ((assoc var (car env)) => cdr)
        (else (env-lookup var (cdr env)))))
