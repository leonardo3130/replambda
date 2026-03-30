import { useEffect, useMemo, useRef, useState } from "react";
import Tree, { type RawNodeDatum } from "react-d3-tree";
import { AST, Application, Abstraction } from "../types/AST";

interface ASTVisualizerProps {
  ast: AST | null;
}

export const ASTVisualizer: React.FC<ASTVisualizerProps> = ({ ast }) => {
  const visualizerRef = useRef<HTMLDivElement>(null);
  const [dimensions, setDimensions] = useState({ width: 900, height: 520 });

  const treeData = useMemo<RawNodeDatum | null>(() => {
    if (!ast) return null;
    return astToTreeData(ast);
  }, [ast]);

  const treeDepth = useMemo(() => {
    if (!ast) return 1;
    return getDepth(ast);
  }, [ast]);

  useEffect(() => {
    if (!visualizerRef.current) return;

    const recalcDimensions = () => {
      if (!visualizerRef.current) return;

      const rect = visualizerRef.current.getBoundingClientRect();
      const width = Math.max(640, Math.floor(rect.width));
      const height = Math.max(420, Math.floor(rect.height));

      setDimensions({ width, height });
    };

    recalcDimensions();

    const observer = new ResizeObserver(() => recalcDimensions());
    observer.observe(visualizerRef.current);

    return () => observer.disconnect();
  }, []);

  return (
    <div ref={visualizerRef} style={{ width: "100%", height: "100%" }}>
      {!treeData ? (
        <p>No AST yet. Run `parse`, `reduce`, `step`, or `stepbystep`.</p>
      ) : (
        <Tree
          data={treeData}
          dimensions={dimensions}
          svgClassName="ast-tree"
          orientation="vertical"
          translate={{
            x: dimensions.width / 2,
            y: 70,
          }}
          pathFunc="elbow"
          zoomable
          collapsible={false}
          separation={{ siblings: 1.3, nonSiblings: 1.8 }}
          nodeSize={{ x: 170, y: Math.max(140, 120 + (treeDepth - 1) * 3) }}
          initialDepth={treeDepth + 1}
          pathClassFunc={() => "ast-tree-link"}
          renderCustomNodeElement={({ nodeDatum }) => {
            const label = nodeLabel(nodeDatum.name);

            return (
              <g>
                <rect
                  x={-34}
                  y={-18}
                  width={68}
                  height={36}
                  rx={10}
                  ry={10}
                  className="ast-tree-node-box"
                />
                <text
                  textAnchor="middle"
                  dominantBaseline="middle"
                  className="ast-tree-node-text"
                >
                  {label}
                </text>
              </g>
            );
          }}
        />
      )}
    </div>
  );
};

function getDepth(ast: AST): number {
  if (ast instanceof Application) {
    return 1 + Math.max(getDepth(ast.body), getDepth(ast.argument));
  }

  if (ast instanceof Abstraction) {
    return 1 + Math.max(getDepth(ast.lam_var), getDepth(ast.body));
  }

  return 1;
}

function getNodeLabel(ast: AST): string {
  if (ast instanceof Application) {
    return "app";
  }

  if (ast instanceof Abstraction) {
    return "lam";
  }

  return ast.visualize();
}

function astToTreeData(ast: AST): RawNodeDatum {
  const label = getNodeLabel(ast);

  if (ast instanceof Application) {
    return {
      name: label,
      children: [astToTreeData(ast.body), astToTreeData(ast.argument)],
    };
  }

  if (ast instanceof Abstraction) {
    return {
      name: label,
      children: [astToTreeData(ast.lam_var), astToTreeData(ast.body)],
    };
  }

  return {
    name: label,
  };
}

function nodeLabel(name: RawNodeDatum["name"]): string {
  if (Array.isArray(name)) {
    return name.join(" ");
  }

  return String(name);
}
