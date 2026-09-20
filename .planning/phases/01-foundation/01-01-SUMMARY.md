# Phase 1 Plan 1: Foundation & Elixir Wrapper Summary

**Clean IB Client Portal API wrapper with curl-based FFI**

## Accomplishments
- Removed all dead TWS socket protocol code (connection, encoder, decoder, protocol, types, client)
- Created Erlang FFI (`ibkr_ffi.erl`) using `os:cmd` + `curl` for reliable HTTPS calls to Client Portal Gateway
- Created Gleam public API (`ibkr.gleam`) with typed `Result(Dynamic, IbkrError)` returns
- Verified end-to-end: setup → auth status → accounts list all working

## Files Created/Modified
- `src/glibe/ib/ibkr_ffi.erl` — Erlang FFI using curl for HTTP
- `src/glibe/ib/ibkr.gleam` — Gleam public API with `IbkrError` type
- `src/ib_test.gleam` — Integration test

## Files Removed
- `src/glibe/ib/connection.gleam`
- `src/glibe/ib/connection_ffi.erl`
- `src/glibe/ib/encoder.gleam`
- `src/glibe/ib/encoder_ffi.erl`
- `src/glibe/ib/decoder.gleam`
- `src/glibe/ib/decoder_ffi.erl`
- `src/glibe/ib/protocol.gleam`
- `src/glibe/ib/types.gleam`
- `src/glibe/ib/client.gleam`
- `src/ib_example.gleam`

## Decisions Made
- **curl over httpc/Finch**: Erlang's httpc had SSL issues with IB gateway (403 errors); ibkr_api has Finch config bug; curl works reliably
- **Dynamic return types**: IB responses are heterogeneous JSON; typed decoders deferred to Phase 2+
- **No ibkr_api library**: Direct HTTP calls avoid library config bugs

## Issues Encountered
- httpc SSL config incompatible with IB gateway self-signed cert (403)
- ibkr_api Finch pool config validation fails with library defaults
- Erlang binary/string concatenation (`++` vs `<>` vs bit syntax)
- Gleam String → Erlang binary FFI type passing

## Next Step
Phase 2: Account & Portfolio API (extend `ibkr.ex`, `ibkr_ffi.erl`, `ibkr.gleam` with portfolio positions, account summary)