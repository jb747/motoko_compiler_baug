import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import JWT "../src/plug_jwt_proto_backend/JWT";
import ActorSpec "./utils/ActorSpec";
import Time "mo:base/Time";
import SHA2 "mo:sha2";
import EcdsaLib "mo:ecdsa/lib";
import Prelude "mo:base/Prelude";
import Prim "mo:⛔";

type Group = ActorSpec.Group;

/// derived from https://github.com/krpeacock/motoko-unit-t
let assertTrue = ActorSpec.assertTrue;
let describe = ActorSpec.describe;
let it = ActorSpec.it;
let skip = ActorSpec.skip;
let pending = ActorSpec.pending;
let run = ActorSpec.run;

let secBytes : [Nat8] = [0x83, 0xec, 0xb3, 0x98, 0x4a, 0x4f, 0x9f, 0xf0, 0x3e, 0x84, 0xd5, 0xf9, 0xc0, 0xd7, 0xf8, 0x88, 0xa8, 0x18, 0x33, 0x64, 0x30, 0x47, 0xac, 0xc5, 0x8e, 0xb6, 0x43, 0x1e, 0x01, 0xd9, 0xba, 0xc8];
var ecdsaSecp256k1PrivKey : EcdsaLib.SecretKey = #non_zero(#fr(0));
switch (EcdsaLib.getSecretKey(secBytes.vals())) {
  case (null) {
    throw Prim.error("unable to generate sha2 hash");
  };
  case (?v) { ecdsaSecp256k1PrivKey := v };
};
let ecdsaSecp256k1PubKey:EcdsaLib.PublicKey = EcdsaLib.getPublicKey(ecdsaSecp256k1PrivKey);

let success = run([
  describe(
    "Aggregate Root Test Suite",
    [
      describe(
        "HtmlEvidence",
        [
          it(
            "should create HtmlEvidence, apply event to it, then delete it",
            do {
              var ok : Bool = false;

              let url = "the rain in spain lies mainly on the plain";
              let encoded_url = await JWT.base64URLEncode(url);
              if (
                encoded_url != "dGhlIHJhaW4gaW4gc3BhaW4gbGllcyBtYWlubHkgb24gdGhlIHBsYWlu",
              ) {
                Debug.trap("base64URLEncode failed");
                ok := false;
              };

              let header = "{\"alg\": \"ES256\", \"typ\": \"JWT\"}";
              let encoded_header : Blob = await JWT.encode_header(header);
              if (encoded_header != "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9") {
                Debug.trap("encode_header failed");
                ok := false;
              };
              let payload = "{ \"sub\": \"ES256InOTA\", \"name\": \"John Doe\" }";
              let encoded_payload : Blob = await JWT.encode_payload(payload);
              if (
                encoded_payload != "eyJzdWIiOiJFUzI1NmluT1RBIiwibmFtZSI6IkpvaG4gRG9lIn0",
              ) {
                Debug.trap("encode_payload failed");
                ok := false;
              };
              /// unlike RSA PKCS#1 v1.5 signatures, ECDSA signatures incorporate a
              /// random number so they are not deterministic. They can only be
              /// validated by verifying with the public key.
              let encoded_signature : Blob = await JWT.encode_signature(ecdsaSecp256k1PrivKey, encoded_payload);
              if (
                encoded_signature != "MEQCICRphRrc0GWowZgJAy0gL6At628Kw8YPE22iD-aKIi4PAiA0JWU-qFNL8I0tP0ws3Bbmg0FfVMn4_yk2lGGquAGOXA",
              ) {
                Debug.trap("encode_signature failed");
                ok := false;
              };
              let jwt = await JWT.gen_jwt(
                encoded_header,
                encoded_payload,
                encoded_signature,
              );
              if (
                jwt != "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJtdGsxIiwibmFtZSI6ImVzMjU2azEifQo.MEUCIC4QDKMEUPL294Cy6RBN2pgDBlAq5WwD8us_47TC_nkCAiEArbtg-eiPp_USg3yl9j7iiMH23OK3sgBRgQ9Vc1aosVY",
              ) {
                Debug.trap(
                  "gen_jwt failed",
                );
                ok := false;
              };
              ok;
            },
          ),
        ],
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
