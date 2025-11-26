export const helpMessage: string = `
Lambda Calculus Tool — Help

Usage:
  parse <lambda calc expression>
      Parses the given lambda calculus expression and displays its AST.

  tokenize <lambda calc expression>
      Produces the sequence of lexical tokens from the expression.

  reduce <lambda calc expression>
      Performs full beta reduction until a normal form is reached.

  step <lambda calc expression>
      Performs a single beta-reduction step only, showing intermediate form.

Notes:
  • Lambda expressions may use: λ or \\ for abstraction
  • Application is left-associative, and represented by a space
  • Parentheses may be used for grouping

Examples:
  parse \\x. x
  tokenize (λx. x y)
  reduce (\\x. x x) (\\y. y)
  step (λx. x) a
`;
