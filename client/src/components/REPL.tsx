import { useState } from "react";
import Terminal, {
  ColorMode,
  TerminalOutput,
  TerminalInput,
} from "react-terminal-ui";
import { v4 as uuidv4 } from "uuid";
import { handleCommand } from "../lib/commands";
import { helpMessage } from "../constants";
import { AST } from "../types/AST";
import type { PrettyPrintable } from "../types/PrettyPrintable";

interface TerminalControllerProps {
  onAstChange?: (ast: AST | null) => void;
}

export const TerminalController: React.FC<TerminalControllerProps> = ({
  onAstChange,
}) => {
  const [terminalLineData, setTerminalLineData] = useState([
    <TerminalOutput key={uuidv4()}>Welcome !</TerminalOutput>,
  ]);

  const handleInput = async (input: string) => {
    if (input.trim().length == 0) return;

    input = input.replaceAll("λ", "\\").trim(); // Replace λ with \ for backend compatibility
    const ld = [...terminalLineData];

    if (input.trim() === "help") {
      ld.push(<TerminalInput key={uuidv4()}>{input}</TerminalInput>);
      ld.push(
        <TerminalOutput key={uuidv4()}>{"\n" + helpMessage}</TerminalOutput>,
      );
    } else if (
      ["parse", "tokenize", "reduce", "step", "stepbystep"].includes(
        input.trim().split(" ")[0].toLowerCase(),
      )
    ) {
      const splitted = input.trim().split(" ");
      const command = splitted[0].toLowerCase();
      splitted.shift();

      const expr = splitted.join(" ");

      const res = await handleCommand(command, expr);

      if (res !== undefined) {
        if (Array.isArray(res)) {
          console.log("Array result:", res);
          ld.push(<TerminalInput key={uuidv4()}>{input.trim()}</TerminalInput>);

          if (command === "stepbystep") {
            const last = res.at(-1);
            if (last instanceof AST) {
              onAstChange?.(last);
            }
          }

          // Pretty print each result in the array
          res.forEach((r: PrettyPrintable) => {
            console.log(r.prettyPrint);
            ld.push(
              <TerminalOutput key={uuidv4()}>{r.prettyPrint()}</TerminalOutput>,
            );
          });
        } else {
          console.log("Non-Array result:", res);
          console.log(res.prettyPrint);
          ld.push(<TerminalInput key={uuidv4()}>{input.trim()}</TerminalInput>);

          if (
            ["parse", "reduce", "step"].includes(command) &&
            res instanceof AST
          ) {
            onAstChange?.(res);
          }

          // Pretty print the single result
          ld.push(
            <TerminalOutput key={uuidv4()}>{res.prettyPrint()}</TerminalOutput>,
          );
        }
      } else {
        ld.push(<TerminalInput key={uuidv4()}>{input.trim()}</TerminalInput>);
        ld.push(
          <TerminalOutput
            key={uuidv4()}
          >{`${input.trim()}: command not found`}</TerminalOutput>,
        );
      }
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
        height="72vh"
        TopButtonsPanel={() => null}
      >
        {terminalLineData}
      </Terminal>
    </div>
  );
};
