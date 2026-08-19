(defrule infer-direct-reachability
   (edge ?x ?y)
   =>
   (assert (reachable ?x ?y)))

(defrule infer-transitive-reachability
   (reachable ?x ?z)
   (edge ?z ?y)
   =>
   (assert (reachable ?x ?y)))
