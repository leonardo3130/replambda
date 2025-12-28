import { useState } from "react";
import Terminal, {
  ColorMode,
  TerminalOutput,
  TerminalInput,
} from "react-terminal-ui";
import { v4 as uuidv4 } from "uuid";
import { handleCommand } from "../lib/commands";
import { helpMessage } from "../constants";

export const TerminalController = () => {
  const [terminalLineData, setTerminalLineData] = useState([
    <TerminalOutput key={uuidv4()}>Welcome !</TerminalOutput>,
  ]);

  const handleInput = async (input: string) => {
    if (input.trim().length == 0) return;

    input = input.replaceAll("λ", "\\").trim(); // Replace λ with \ for backend compatibility
    let ld = [...terminalLineData];

    if (input.trim() === "clear") {
      ld = [];
    } else if (input.trim() === "history") {
      ld.push(<TerminalInput key={uuidv4()}>{input}</TerminalInput>);
    } else if (input.trim() === "help") {
      ld.push(<TerminalInput key={uuidv4()}>{input}</TerminalInput>);
      ld.push(
        <TerminalOutput key={uuidv4()}>{"\n" + helpMessage}</TerminalOutput>,
      );
    } else if (
      ["parse", "tokenize", "reduce", "step", "stepbystep"].includes(
        input.trim().split(" ")[0],
      )
    ) {
      const splitted = input.trim().split(" ");
      const command = splitted[0].toLowerCase();
      splitted.shift();
      const expr = splitted.join(" ");
      handleCommand(command, expr);
    } else {
      ld.push(<TerminalInput key={uuidv4()}>{input.trim()}</TerminalInput>);
      ld.push(
        <TerminalOutput
          key={uuidv4()}
        >{`${input.trim()}: command not found`}</TerminalOutput>,
      );
    }
    setTerminalLineData(ld);
  };

  return (
    <div className="terminal-container">
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
