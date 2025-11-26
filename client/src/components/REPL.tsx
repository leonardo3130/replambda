import { useState } from "react";
import Terminal, {
  ColorMode,
  TerminalOutput,
  TerminalInput,
} from "react-terminal-ui";
import { v4 as uuidv4 } from "uuid";
// import { handleCommand } from "../lib/commands";
import { helpMessage } from "../constants";

export const TerminalController = () => {
  const [terminalLineData, setTerminalLineData] = useState([
    <TerminalOutput key={uuidv4()}>Welcome !</TerminalOutput>,
  ]);

  const [{ history }, setTerminalHistory] = useState<{
    history: string[];
    index: number;
  }>({ history: [], index: -1 });

  const moveHistoryIndex = (direction: 1 | -1) => {
    setTerminalHistory((prev) => {
      const max = prev.history.length - 1;
      const newIndex = Math.min(Math.max(prev.index + direction, 0), max);
      const notValid = newIndex === prev.index;

      setTerminalLineData((prevData) => {
        if (notValid) return prevData;

        const copy = [...prevData];
        copy[copy.length - 1] = (
          <TerminalInput key={uuidv4()}>{prev.history[newIndex]}</TerminalInput>
        );
        return copy;
      });

      return {
        history: prev.history,
        index: newIndex,
      };
    });
  };

  const handleInput = async (input: string) => {
    if (input.trim().length == 0) return;

    input = input.replaceAll("λ", "\\").trim(); // Replace λ with \ for backend compatibility
    let ld = [...terminalLineData];

    if (input.trim() === "clear") {
      setTerminalHistory((prev) => ({
        history: [...prev.history, "clear"],
        index: prev.index + 1,
      }));

      ld = [];
    } else if (input.trim() === "history") {
      setTerminalHistory((prev) => ({
        history: [...prev.history, "history"],
        index: prev.index + 1,
      }));

      ld.push(<TerminalInput key={uuidv4()}>{input}</TerminalInput>);

      for (let i = 0; i < history.length; i++) {
        const line = history[i];
        ld.push(<TerminalOutput key={uuidv4()}>{line}</TerminalOutput>);
      }
    } else if (input.trim() === "help") {
      ld.push(<TerminalInput key={uuidv4()}>{input}</TerminalInput>);
      ld.push(
        <TerminalOutput key={uuidv4()}>{"\n" + helpMessage}</TerminalOutput>,
      );

      setTerminalHistory((prev) => ({
        history: [...prev.history, "help"],
        index: prev.index + 1,
      }));
    }
    // else if (
    //   ["parse", "tokenize", "reduce", "step", "stepbystep"].includes(
    //     input.trim().split(" ")[0],
    //   )
    // ) {
    //   const splitted = input.trim().split(" ");
    //   const command = splitted[0];
    //   splitted.shift();
    //   const expr = splitted.join(" ");
    //   handleCommand(command, expr);
    // }
    else {
      ld.push(<TerminalInput key={uuidv4()}>{input.trim()}</TerminalInput>);
      ld.push(
        <TerminalOutput
          key={uuidv4()}
        >{`${input.trim()}: command not found`}</TerminalOutput>,
      );

      setTerminalHistory((prev) => ({
        history: [...prev.history, input.trim()],
        index: prev.index + 1,
      }));
    }
    setTerminalLineData(ld);
  };

  return (
    <div
      className="terminal-container"
      onKeyDown={(e) => {
        if (e.key === "ArrowUp") {
          moveHistoryIndex(-1);
        } else if (e.key === "ArrowDown") {
          moveHistoryIndex(1);
        }
      }}
    >
      <Terminal
        name="λ-Calculus REPL "
        colorMode={ColorMode.Dark}
        onInput={handleInput}
        startingInputValue="λx.x"
        height="80vh"
        TopButtonsPanel={() => null}
      >
        {terminalLineData}
      </Terminal>
    </div>
  );
};
