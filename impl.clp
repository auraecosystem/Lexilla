;; Graph representation: (node neighbor-1 neighbor-2 ...)
(define sample-graph
  '((1 2)
    (2 3)
    (3 4 5)
    (4 2)   ; Cycle back to 2
    (5)))

;; Returns #t if 'target' is reachable from 'start', otherwise #f
(define (reachable? graph start target)
  (let loop ((queue (list start))
             (visited '()))
    (cond
      ;; Queue is empty: no path found
      ((null? queue) #f)
      
      ;; Target reached
      ((equal? (car queue) target) #t)
      
      ;; Node already visited: skip to prevent infinite loop on cycles
      ((member (car queue) visited)
       (loop (cdr queue) visited))
      
      ;; Explore current node and append its neighbors to the queue
      (else
       (let* ((curr (car queue))
              (neighbors (cond ((assoc curr graph) => cdr)
                               (else '()))))
         (loop (append (cdr queue) neighbors)
               (cons curr visited)))))))

;; Test executions
(display (reachable? sample-graph 1 5)) ; Returns: #t (1 -> 2 -> 3 -> 5)
(newline)
(display (reachable? sample-graph 5 1)) ; Returns: #f (no outgoing path from 5 to 1)
(newline)
(display (reachable? sample-graph 4 5)) ; Returns: #t (4 -> 2 -> 3 -> 5 through cycle)
