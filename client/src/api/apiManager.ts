import { AST } from "../types/AST";
import { Token } from "../types/Token";

export class ApiManager {
  private baseUrl: string;

  constructor(baseUrl: string = import.meta.env.VITE_API_URL) {
    this.baseUrl = baseUrl.replace(/\/$/, ""); // remove eventual trailing slash
  }

  private async post<T>(
    endpoint: string,
    payload: string,
    transform?: (json: unknown) => T,
  ): Promise<T> {
    const url = `${this.baseUrl}/${endpoint}`;

    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new Error(`POST ${endpoint} failed: ${response.status}`);
    }

    const json = await response.json();
    return transform ? transform(json) : (json as T);
  }

  async parse(payload: string): Promise<AST> {
    return await this.post<AST>("parse", payload);
  }

  async fullReduce(payload: string): Promise<AST> {
    return await this.post<AST>("full-reduce", payload);
  }

  async stepReduce(payload: string): Promise<AST> {
    return await this.post<AST>("reduce-once", payload);
  }

  async stepByStepReduce(payload: string): Promise<AST[]> {
    return await this.post<AST[]>("reduce-steps", payload);
  }

  async tokenization(payload: string): Promise<Token[]> {
    return await this.post<Token[]>("tokens", payload);
  }
}
