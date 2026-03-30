import "./App.css";
import { useState } from "react";
import { ASTVisualizer } from "./components/ASTVisualizer";
import { TerminalController } from "./components/REPL";
import type { AST } from "./types/AST";

function App() {
  const [currentAST, setCurrentAST] = useState<AST | null>(null);

  return (
    <div className="App">
      <TerminalController onAstChange={setCurrentAST} />
      <div className="visualizer-container">
        <ASTVisualizer ast={currentAST} />
      </div>
    </div>
  );
}

export default App;
