import glibe/ib/ibkr
import gleam/io
import gleam/dynamic
import gleam/int

pub fn main() {
  io.println("Setting up IB connection...")
  case ibkr.setup("5001") {
    Ok(_) -> io.println("Setup OK")
    Error(e) -> io.println("Setup error: " <> debug(e))
  }

  io.println("\nSearching for ZCSH...")
  let search_result = ibkr.search_contracts("ZCSH")
  handle_result(search_result, "Search")

  io.println("\nGetting market snapshot for ZCSH (trying conid 373156154)...")
  let snapshot_result = ibkr.get_market_snapshot("373156154", "31,55,84,86,87")
  handle_result(snapshot_result, "Snapshot")
}

fn handle_result(result, label) {
  case result {
    Ok(resp) -> 
      io.println(label <> " type: " <> dynamic.classify(resp))
    Error(e) -> io.println(label <> " error: " <> debug(e))
  }
}

fn debug(e) -> String {
  case e {
    ibkr.ConnectionError(msg) -> "ConnectionError: " <> msg
    ibkr.HttpError(code, msg) -> "HttpError(" <> int_to_string(code) <> "): " <> msg
  }
}

fn int_to_string(n: Int) -> String {
  int.to_string(n)
}