import CKBTC "mo:ckbtc-types";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import RBTree "../util/motoko/StableCollections/RedBlackTree/RBTree";
import Lib "Lib";
import Result "../util/motoko/Result";
import Error "../util/motoko/Error";

shared (install) persistent actor class Canister(is_testnet : Bool) = Self {

  var users = RBTree.empty<Principal, Text>();

  public shared query func dynamonium_ckbtc_get_address(ps : [Principal]) : async [?Text] {
    let maxt = 0;
    let take = Nat.min(ps.size(), maxt);
    let buf = Buffer.Buffer<?Text>(take);
    label collecting for (p in ps.vals()) {
      buf.add(RBTree.get(users, Principal.compare, p));
      if (buf.size() >= take) break collecting;
    };
    Buffer.toArray(buf);
  };

  public shared ({ caller }) func dynamonium_ckbtc_generate_address() : async Result.Type<Text, { #GenericError : Error.Type }> {
    switch (RBTree.get(users, Principal.compare, caller)) {
      case (?found) return #Ok(found);
      case _ ();
    };
    let self = Principal.fromActor(Self);
    let account = { owner = ?self; subaccount = ?Lib.p2subacc(caller) };
    try {
      let addr = await Lib.getActors(is_testnet).minter.get_btc_address(account);
      users := RBTree.insert(users, Principal.compare, caller, addr);
      #Ok addr;
    } catch e #Err(Error.convert(e));
  };

  public shared ({ caller }) func dynamonium_ckbtc_check() : async Result.Type<Nat64, { #GenericError : Error.Type; #UpdateBalanceError : CKBTC.Minter.UpdateBalanceError }> {
    let self = Principal.fromActor(Self);
    let subacc = Lib.p2subacc(caller);
    let account = { owner = ?self; subaccount = ?subacc };
    let ckbtc = Lib.getActors(is_testnet);
    try {
      let statuses = switch (await (with cycles = 20_000_000_000) ckbtc.minter.update_balance(account)) {
        case (#Ok utxo_statuses) utxo_statuses;
        case (#Err err) return #Err(#UpdateBalanceError err);
      };
      var minted_amt : Nat64 = 0;
      for (st in statuses.vals()) switch st {
        case (#Minted m) minted_amt += m.minted_amount;
        case _ ();
      };
      // let acc = { owner = self; subaccount = ?subacc };
      // let bal = await ckbtc.ledger.icrc1_balance_of(acc);
      #Ok minted_amt;
    } catch e #Err(Error.convert(e));
  };
};
