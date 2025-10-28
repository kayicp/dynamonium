import CKBTC "mo:ckbtc-types";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Nat8 "mo:base/Nat8";

module {

  public func p2subacc(p : Principal) : [Nat8] {
    let b = Principal.toBlob(p);
    let buf = Buffer.Buffer<Nat8>(32);
    buf.add(Nat8.fromNat(b.size())); // Add length byte
    for (x in b.vals()) buf.add(x); // Add principal bytes
    while (buf.size() < 32) buf.add(0); // Pad with zeros
    Buffer.toArray(buf);
  };

  public func getActors(is_testnet : Bool) : {
    minter : CKBTC.Minter.Service;
    ledger : CKBTC.Ledger.Service;
    index : CKBTC.Index.Service;
    archive : CKBTC.Archive.Service;
  } = if (is_testnet) ({
    minter = actor ("ml52i-qqaaa-aaaar-qaaba-cai");
    ledger = actor ("mc6ru-gyaaa-aaaar-qaaaq-cai");
    index = actor ("mm444-5iaaa-aaaar-qaabq-cai");
    archive = actor ("m62lf-ryaaa-aaaar-qaacq-cai");

  }) else ({
    minter = actor ("mqygn-kiaaa-aaaar-qaadq-cai");
    ledger = actor ("mxzaz-hqaaa-aaaar-qaada-cai");
    index = actor ("n5wcd-faaaa-aaaar-qaaea-cai");
    archive = actor ("nbsys-saaaa-aaaar-qaaga-cai");
  });
};
