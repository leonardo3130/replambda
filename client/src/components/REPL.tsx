import { useState } from "react";
import Terminal, {
  ColorMode,
  TerminalOutput,
  TerminalInput,
} from "react-terminal-ui";
import { apiManagerInstance } from "../api/apiManagerInstance";

export const TerminalController = () => {
  const [terminalLineData, setTerminalLineData] = useState([
    <TerminalOutput key={-1}>Welcome !</TerminalOutput>,
  ]);
  const [terminalHistory, setTerminalHistory] = useState([
    <TerminalOutput key={-1}>Welcome !</TerminalOutput>,
  ]);

  const handleInput = async (input: string) => {
    input = input.replaceAll("λ", "\\").trim(); // Replace λ with \\ for backend compatibility  ;
    let ld = [...terminalLineData];
    if (input.toLocaleLowerCase().trim() === "clear") {
      setTerminalHistory((prev) => [...prev, ...ld]);
      ld = [];
    } else if (input.toLocaleLowerCase().trim() === "history") {
      ld.push(<TerminalInput key={ld.length}>{input}</TerminalInput>);
      setTerminalHistory((prev) => [...prev, ...ld]);
      for (let i = 0; i < terminalHistory.length; i++) {
        const line = terminalHistory[i];
        if (line.type === TerminalInput) {
          ld.push(
            <TerminalOutput key={terminalHistory.length + i}>
              {line.props.children}
            </TerminalOutput>,
          );
        }
      }
    } else {
      const reduced = await apiManagerInstance.fullReduce(input);
      console.log(reduced);
      ld.push(<TerminalInput key={ld.length}>{input}</TerminalInput>);
      ld.push(<TerminalOutput key={ld.length + 1}>{input}</TerminalOutput>);
    }
    setTerminalLineData(ld);
  };

  // Terminal has 100% width by default, so it should usually be wrapped in a container div
  return (
    <div className="terminal-container">
      <Terminal
        name="λ-Calculus REPL "
        colorMode={ColorMode.Dark}
        onInput={handleInput}
        startingInputValue="λx.x"
        height="100vh"
      >
        {terminalLineData}
      </Terminal>
    </div>
  );
};
