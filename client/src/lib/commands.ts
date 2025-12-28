import { apiManagerInstance } from "../api/apiManagerInstance";
import type { PrettyPrintable } from "../types/PrettyPrintable";

// overloading to ensure correct type inference
export async function handleCommand(
  command: "parse" | "reduce" | "step",
  input: string,
): Promise<PrettyPrintable>;

export async function handleCommand(
  command: "stepbystep",
  input: string,
): Promise<PrettyPrintable[]>;

export async function handleCommand(
  command: "tokenize",
  input: string,
): Promise<PrettyPrintable[]>;

export async function handleCommand(
  command: string,
  input: string,
): Promise<PrettyPrintable | PrettyPrintable[] | undefined>;

export async function handleCommand(
  command: string,
  input: string,
): Promise<PrettyPrintable | PrettyPrintable[] | undefined> {
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
