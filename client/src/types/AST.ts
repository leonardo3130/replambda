import type { PrettyPrintable } from "./PrettyPrintable";

export interface RawApplication {
  operation: "app";
  body: RawAST;
  argument: RawAST;
}

export interface RawAbstraction {
  operation: "lam";
  lam_var: RawAST;
  body: RawAST;
}

export interface RawVariable {
  operation: "var";
  var: string;
}

// Union type for all raw AST nodes
export type RawAST = RawApplication | RawAbstraction | RawVariable;

// Base AST class: abstract --> never instantiated directly
export abstract class AST implements PrettyPrintable {
  abstract operation: "app" | "lam" | "var";

  abstract prettyPrint(): string;

  static fromJSON(json: RawAST): AST {
    // Determine the type of AST node based on the operation field
    switch (json.operation) {
      case "app":
        return new Application(
          AST.fromJSON(json.body),
          AST.fromJSON(json.argument),
        );
      case "lam":
        return new Abstraction(
          AST.fromJSON(json.lam_var),
          AST.fromJSON(json.body),
        );
      case "var":
        return new Variable(json.var);
      default:
        throw new Error(`Unknown AST operation`);
    }
  }
}

// Application node representing a function application
export class Application extends AST {
  operation: "app" = "app" as const;
  body: AST;
  argument: AST;

  constructor(body: AST, argument: AST) {
    super();
    this.body = body;
    this.argument = argument;
  }

  prettyPrint(): string {
    return `(${this.body.prettyPrint()}) (${this.argument.prettyPrint()})`;
  }
}

// Abstraction node representing a lambda abstraction
export class Abstraction extends AST {
  operation: "lam" = "lam" as const;
  lam_var: AST;
  body: AST;

  constructor(lam_var: AST, body: AST) {
    super();
    this.lam_var = lam_var;
    this.body = body;
  }

  prettyPrint(): string {
    return `λ${this.lam_var.prettyPrint()}. ${this.body.prettyPrint()}`;
  }
}

// Variable node representing a variable
export class Variable extends AST {
  operation: "var" = "var" as const;
  name: string;

  constructor(name: string) {
    super();
    this.name = name;
  }

  prettyPrint(): string {
    return this.name;
  }
}
