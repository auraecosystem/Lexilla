(deffacts network-data
   (edge 1 2) (edge 2 3))

(defrule infer-reachability
   (edge ?x ?y)
   =>
   (assert (reachable ?x ?y)))
