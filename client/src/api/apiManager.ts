import { AST, type RawAST } from "../types/AST";
import { Token, type RawToken } from "../types/Token";

export class ApiManager {
  private baseUrl: string;

  constructor(baseUrl: string = import.meta.env.VITE_API_URL) {
    this.baseUrl = baseUrl.replace(/\/$/, ""); // remove eventual trailing slash
  }

  private async post<T>(endpoint: string, payload: string): Promise<T> {
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
    return json;
  }

  async parse(payload: string): Promise<AST> {
    const res = await this.post<RawAST>("parse", payload);
    return AST.fromJSON(res);
  }

  async fullReduce(payload: string): Promise<AST> {
    const res = await this.post<RawAST>("full-reduce", payload);
    return AST.fromJSON(res);
  }

  async stepReduce(payload: string): Promise<AST> {
    const res = await this.post<RawAST>("reduce-once", payload);
    return AST.fromJSON(res);
  }

  async stepByStepReduce(payload: string): Promise<AST[]> {
    const res = await this.post<RawAST[]>("reduce-steps", payload);
    return res.map((e) => AST.fromJSON(e));
  }

  async tokenization(payload: string): Promise<Token[]> {
    const res = await this.post<RawToken[]>("tokens", payload);
    return res.map((e) => Token.fromJSON(e));
  }
}
