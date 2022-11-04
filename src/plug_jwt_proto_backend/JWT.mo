import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Random "mo:base/Random";
import Array "mo:base/Array";
import Prim "mo:⛔";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import EcdsaLib "mo:ecdsa/lib";
import Iter "mo:base/Iter";
import Char "mo:base/Char";

// [JWT ref] (https://techdocs.akamai.com/iot-token-access-control/docs/generate-jwt-ecdsa-keys)

module {

  public func natArr2Text(arr : [Nat8]) : async Text {
    var res : Text = "";
    var toIter : Iter.Iter<Nat8> = Array.vals(arr);
    for (val in toIter) {
      res := res # Nat8.toText(val);
    };
    res;
  };

  public func text2NatArr(txt : Text) : [Nat] {
    var res : [var Nat] = Array.init<Nat>(Text.size(txt), 0);
    /// a Motoko Char maps to a single UTF8 code point.. a single character
    /// in UTF8, a single character may occupy one to four bytes.
    var toIter : Iter.Iter<Char> = Text.toIter(txt);
    let i : Nat = 0;
    for (val in toIter) {
      let tmp : Nat32 = Char.toNat32(val);
      res[i] := Nat32.toNat(tmp);
    };
    Array.freeze<Nat>(res);
  };

  public func encode_header(header : Text) : async Blob {
    return Text.encodeUtf8(header);
  };

  public func encode_payload(payload : Text) : async Blob {
    return Text.encodeUtf8(payload);
  };

  public func encode_signature(ecdsa_private_key : EcdsaLib.SecretKey, payload : Blob) : async Blob {
    // openssl dgst -sha256 -binary -sign ec-secp256k1-priv-key.pem
    // the ecdsa key consists of:
    // a private key integer, randomly selected in [1, n-1]a, where n is prime
    // a public key curve point
    // 1. calculate the SHA-2 hash of the payload
    // 2. select the n leftmost bits
    // 3. generate a random number in [1, n-1]
    // 4. calculate the curve point (x, y) = k x G
    //
    var payloadIter : Iter.Iter<Nat8> = payload.vals();
    var rand : [var Nat8] = Array.init<Nat8>(32, 0);
    var i : Nat = 0;
    while (i < 32) {
      rand[i] := Random.byteFrom(await Random.blob());
      i := i + 1;
    };

    let sha2 : ?EcdsaLib.Signature = EcdsaLib.sign(ecdsa_private_key, payloadIter, rand.vals());
    switch (sha2) {
      case (null) {
        throw Prim.error("unable to generate sha2 hash");
      };
      case (?sha2) {
        /// get [Nat8] from Signature
        let hashed : [Nat8] = [];
        let signedHash : ?EcdsaLib.Signature = EcdsaLib.signHashed(ecdsa_private_key, hashed.vals(), rand.vals());
        switch (signedHash) {
          case (null) {
            throw Prim.error("unable to generate sha2 hash");
          };
          case (?signedHash) {
            /// convert ?Signature to text
            let sigHash : Text = "";
            return Text.encodeUtf8(sigHash);
          };
        };
      };
    };
  };

  /// Base64Url encoding is specified in RFC 4648, The Base16, Base32, and Base64 Data
  /// Encodings. The only difference between Base64 and Base64Url is two values (62 and 63).
  /// Just replace "+" with "-" and "/" with "_"
  public func base64URLEncode(t : Text) : async Blob {
    return Text.encodeUtf8(t);
  };

  public func gen_jwt(
    encoded_header : Blob,
    encoded_payload : Blob,
    encoded_signature : Blob,
  ) : async Blob {
    let enc_header_array : [Nat8] = Blob.toArray(encoded_header);
    let enc_payload_array : [Nat8] = Blob.toArray(encoded_payload);
    let enc_signature_array : [Nat8] = Blob.toArray(encoded_signature);
    let dot : Nat8 = 46;
    let Y : [Nat8] = Array.append<Nat8>(
      Array.append<Nat8>(
        Array.append<Nat8>(
          Array.append<Nat8>(
            enc_header_array,
            [46],
          ),
          enc_payload_array,
        ),
        [46],
      ),
      enc_signature_array,
    );
    let enc = await natArr2Text(Y);
    return Text.encodeUtf8(enc);
  };
};
