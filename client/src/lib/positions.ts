import { AST, Abstraction, Application } from "../types/AST";

export function CalculateASTNodesPositions(
  ast: AST,
  startX: number,
  endX: number,
  startY: number = 0,
  depth: number = 0,
  ySpacing: number = 100,
): void {
  // Calculate the x position as the midpoint between startX and endX
  const centerX = (startX + endX) / 2;
  const currentY = startY + depth * ySpacing;
  const leftWidth = (endX - startX) / 2;

  // Set the position of the current AST node
  ast.setPosition(centerX, currentY);

  // Recursively calculate positions for child nodes
  if (ast instanceof Application) {
    CalculateASTNodesPositions(
      ast.body,
      startX,
      startX + leftWidth,
      startY,
      depth + 1,
      ySpacing,
    );
    CalculateASTNodesPositions(
      ast.argument,
      startX + leftWidth,
      endX,
      startY,
      depth + 1,
      ySpacing,
    );
  } else if (ast instanceof Abstraction) {
    CalculateASTNodesPositions(
      ast.lam_var,
      startX,
      startX + leftWidth,
      startY,
      depth + 1,
      ySpacing,
    );
    CalculateASTNodesPositions(
      ast.body,
      startX + leftWidth,
      endX,
      startY,
      depth + 1,
      ySpacing,
    );
  }
}
