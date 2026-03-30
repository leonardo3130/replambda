-- Alpha conversion on AST
module Alpha where

import Parser
import Utils

-- alpha conversion function
alphaConvert :: Variable -> Variable -> AST -> AST
alphaConvert oldVar newVar = substitute oldVar (NodeVar newVar)
