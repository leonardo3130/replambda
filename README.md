# replambda

An interactive Lambda Calculus REPL built with a Haskell backend and a React web UI.

> [!WARNING]
> This project is still incomplete and may contain several bugs.
> The Haskell parser is especially experimental: it was written mainly to learn Haskell basics and can be improved a lot.

## Quick Start

### 1) Start the backend (Haskell)

Requirements:

- GHC 9.x
- Cabal

Commands:

```bash
cd server
cabal update
cabal run replambda-server
```

The API starts at `http://localhost:3000`.

### 2) Start the frontend (React + Vite)

Requirements:

- Node.js 20+
- npm

Commands:

```bash
cd client
npm install
npm run dev
```

The UI starts at `http://localhost:5173`.

Default API URL is defined in `client/.env`:

```env
VITE_API_URL=http://localhost:3000
```

## Very Short Docs

The frontend sends lambda expressions to the backend and can:

- tokenize expressions
- parse expressions into an AST
- perform one beta-reduction step
- perform full reduction
- return step-by-step reductions

Backend endpoints (POST):

- `/tokens`
- `/parse`
- `/reduce-once`
- `/full-reduce`
- `/reduce-steps`

Example lambda input forms:

- `\\x. x`
- `λx. x`
- `(\\x. x x) (\\y. y)`

## Project Status

Current focus areas:

- improve parser quality and error handling
- add tests
- add Docker setup
