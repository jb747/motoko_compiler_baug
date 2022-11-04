import List "mo:base/List";

actor {
  // == EXTERNALLY-FACING INTERFACE
  // ===================================================
  public shared ({ caller }) func shim() : async Text {
    return "hello";
  };

  // READMODELS
};
