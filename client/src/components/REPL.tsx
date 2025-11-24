import { useEffect, useState } from "react";
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
  const [terminalHistory, setTerminalHistory] = useState<string[]>([]);
  const [inputValue, setInputValue] = useState<string>("");
  const [historyIndex, setHistoryIndex] = useState<number>(-1);

  const increaseHistoryIndex = () => {
    setHistoryIndex((prevIndex) =>
      Math.min(prevIndex + 1, terminalHistory.length - 1),
    );

    setInputValue(
      terminalHistory[Math.min(historyIndex + 1, terminalHistory.length - 1)] ||
      "",
    );
  };

  useEffect(() => {
    setTerminalLineData((prevData) => [
      ...prevData.filter(
        (line) => !(line.type === TerminalInput && line.key === "current"),
      ),
      <TerminalInput key="current">{inputValue}</TerminalInput>,
    ]);
  }, [inputValue]);

  const decreaseHistoryIndex = () => {
    setHistoryIndex((prevIndex) => Math.max(prevIndex - 1, -1));

    setInputValue(terminalHistory[Math.max(historyIndex - 1, -1)] || "");
  };

  const handleInput = async (input: string) => {
    input = input.replaceAll("λ", "\\").trim(); // Replace λ with \\ for backend compatibility  ;
    let ld = [...terminalLineData];
    if (input.toLocaleLowerCase().trim() === "clear") {
      setTerminalHistory((history) => [...history, "clear"]);
      ld = [];
    } else if (input.toLocaleLowerCase().trim() === "history") {
      setTerminalHistory((history) => [...history, "history"]);
      ld.push(<TerminalInput key={ld.length}>{input}</TerminalInput>);
      for (let i = 0; i < terminalHistory.length; i++) {
        const line = terminalHistory[i];
        ld.push(
          <TerminalOutput key={terminalHistory.length + i}>
            {line}
          </TerminalOutput>,
        );
      }
    } else {
      const reduced = await apiManagerInstance.fullReduce(input);
      console.log(reduced);
      ld.push(<TerminalInput key={ld.length}>{input}</TerminalInput>);
      ld.push(<TerminalOutput key={ld.length + 1}>{input}</TerminalOutput>);
      setTerminalHistory((history) => [...history, input]);
    }
    setTerminalLineData(ld);
  };

  return (
    <div
      className="terminal-container"
      onKeyDown={(e) => {
        if (e.key === "ArrowUp") {
          decreaseHistoryIndex();
        } else if (e.key === "ArrowDown") {
          increaseHistoryIndex();
        }
      }}
    >
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
