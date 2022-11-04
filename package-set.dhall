let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }
let upstream = https://github.com/aviate-labs/package-set/releases/download/v0.1.3/package-set.dhall sha256:ca68dad1e4a68319d44c587f505176963615d533b8ac98bdb534f37d1d6a5b47
let additions = [
  { name = "ecdsa"
  , repo = "https://github.com/herumi/ecdsa-motoko"
  , version = "2318ab7fedf956bf501ab74764a2e6073c6c900c"
  , dependencies = [ "base", "sha2", "iterext" ]
  },
{ name = "io"
  , repo = "https://github.com/aviate-labs/io.mo"
  , version = "v0.3.0"
  , dependencies = [ "base" ]
  },  { name = "rand"
  , repo = "https://github.com/aviate-labs/rand.mo"
  , version = "v0.2.1"
  , dependencies = [ "base", "encoding", "io" ]
  },
{ name = "sha2"
  , repo = "https://github.com/timohanke/motoko-sha2"
  , version = "v2.0.0"
  , dependencies = [ "base", "iterext" ]
  },
{ name = "iterext"
  , repo = "https://github.com/timohanke/motoko-iterext"
  , version = "v2.0.0"
  , dependencies = [ "base" ]
  }
  ]
in  upstream # additions