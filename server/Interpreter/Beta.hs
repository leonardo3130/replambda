-- Beta reduction on AST
module Beta where

import Parser
import Utils

-- function that performs beta reduction on an AST
betaReduce :: AST -> AST
betaReduce (Application (Abstraction (NodeVar v) t2) t1) = substitute v t1 t2
betaReduce (Application t1 t2) = Application (betaReduce t1) (betaReduce t2)
betaReduce (Abstraction (NodeVar v) t) = Abstraction (NodeVar v) (betaReduce t)
betaReduce varnode@(NodeVar _) = varnode
