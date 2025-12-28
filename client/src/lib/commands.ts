import { apiManagerInstance } from "../api/apiManagerInstance";
import type { AST } from "../types/AST";
import { Token } from "../types/Token";

// overloading to ensure correct type inference
export async function handleCommand(
  command: "parse" | "reduce" | "step",
  input: string,
): Promise<AST>;

export async function handleCommand(
  command: "stepbystep",
  input: string,
): Promise<AST[]>;

export async function handleCommand(
  command: "tokenize",
  input: string,
): Promise<Token[]>;

export async function handleCommand(
  command: string,
  input: string,
): Promise<AST | Token[] | AST[] | undefined>;

export async function handleCommand(
  command: string,
  input: string,
): Promise<AST | Token[] | AST[] | undefined> {
  switch (command) {
    case "parse":
      return await apiManagerInstance.parse(input);

    case "tokenize":
      return await apiManagerInstance.tokenization(input);

    case "reduce":
      return await apiManagerInstance.fullReduce(input);

    case "step":
      return await apiManagerInstance.stepReduce(input);

    case "stepbystep":
      return await apiManagerInstance.stepByStepReduce(input);

    default:
      return Promise.resolve(undefined);
  }
}
