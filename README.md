# README

```bash
cd plug_jwt_proto/
dfx help
dfx canister --help
```

# Running the project in codespaces

The .devcontainer directory contains docker instructions to build the container which will host the project.

In a terminal: `dfx start --clean`

In another terminal: 

```
cd src/plug_jwt_proto_frontend
npm i
cd ../..
dfx deploy
```

In another terminal: `make`

## Running the project locally

```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

Application will be available at `http://localhost:8000?canisterId={asset_canister_id}`.

For frontend changes, you can start a development server with:

```bash
npm start
```

Starts a server at `http://localhost:8080`, proxying API requests to the replica at port 8000.

### Note on frontend environment variables

If you are hosting frontend code somewhere without using DFX, you may need to make one of the following adjustments to ensure your project does not fetch the root key in production:

- set`NODE_ENV` to `production` if you are using Webpack
- use your own preferred method to replace `process.env.NODE_ENV` in the autogenerated declarations
- Write your own `createActor` constructor
