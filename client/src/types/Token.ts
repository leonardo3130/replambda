const TokenType = {
  VAR: "variable",
  LPAR: "left_par",
  RPAR: "right_par",
  LAM: "lambda",
  DOT: "dot",
  EOF: "end",
  SPACE: "space",
} as const;

// alternative to enum
export type TokenType = (typeof TokenType)[keyof typeof TokenType];

export interface RawToken {
  type: TokenType;
  value: string;
}

export class Token {
  type: TokenType;
  value: string;

  constructor(type: TokenType, value: string) {
    this.type = type;
    this.value = value;
  }

  static fromJSON(json: RawToken): Token {
    return new Token(json.type, json.value);
  }

  prettyPrint(): string {
    return `${this.type}: ${this.value}`;
  }
}
