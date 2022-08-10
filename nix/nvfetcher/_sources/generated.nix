# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  crate2nix = {
    pname = "crate2nix";
    version = "7178e530f7d617ac0b61a6e53c7f3b28710fb6cf";
    src = fetchFromGitHub ({
      owner = "kolloch";
      repo = "crate2nix";
      rev = "7178e530f7d617ac0b61a6e53c7f3b28710fb6cf";
      fetchSubmodules = false;
      sha256 = "sha256-d+SsMV/ysXNu5mE1qIywpQdgleEKOdsK6L4h58AoFdc=";
    });
  };
  holochain_branch_develop = {
    pname = "holochain_branch_develop";
    version = "33f26d8f08e3c61f7981cd0a7441d479386da17a";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "33f26d8f08e3c61f7981cd0a7441d479386da17a";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-0bdfFjPvnFLpdtvjgIFmNFcjht2xKg8CmzomGy56oqU=";
    };
    cargoLock = {
      lockFile = ./holochain_branch_develop-33f26d8f08e3c61f7981cd0a7441d479386da17a/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_branch_main = {
    pname = "holochain_branch_main";
    version = "30f6accd88faa0c2946d63a77d0ba83f82df3a91";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "30f6accd88faa0c2946d63a77d0ba83f82df3a91";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-mvHyZpchHqB+MoDUGtf0PfCf+CD+GA7OxvE/0QAWEk4=";
    };
    cargoLock = {
      lockFile = ./holochain_branch_main-30f6accd88faa0c2946d63a77d0ba83f82df3a91/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_103 = {
    pname = "holochain_revision_holochain-0_0_103";
    version = "holochain-0.0.103";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.103";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-p9E1It1iZIsb8gntDljZcU3bL/BnkvwY2Y4JGegKHvw=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_103-holochain-0.0.103/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_104 = {
    pname = "holochain_revision_holochain-0_0_104";
    version = "holochain-0.0.104";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.104";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-wlm18JEFn+1tFM2z7jMOI1PT2ZHLzUT4AegoUb9uqmM=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_104-holochain-0.0.104/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_105 = {
    pname = "holochain_revision_holochain-0_0_105";
    version = "holochain-0.0.105";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.105";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-v75v5XsKpOFEQ+scTRTsWzqpgrdXBb2Id3Wg25QG6j8=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_105-holochain-0.0.105/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_106 = {
    pname = "holochain_revision_holochain-0_0_106";
    version = "holochain-0.0.106";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.106";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-+uMVxzbBUE7wrw295NYyqEHLWg5UUXcoF/fXBvJtkhw=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_106-holochain-0.0.106/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_107 = {
    pname = "holochain_revision_holochain-0_0_107";
    version = "holochain-0.0.107";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.107";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-ccZyr82y//UJUzospykYbdK1C8OyL7+aVCTfDiCkrNQ=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_107-holochain-0.0.107/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_108 = {
    pname = "holochain_revision_holochain-0_0_108";
    version = "holochain-0.0.108";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.108";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Wv4Xu1Er/QwJHgapX6/Gz6HgwhpJRRIE+55y0UTDOd0=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_108-holochain-0.0.108/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_109 = {
    pname = "holochain_revision_holochain-0_0_109";
    version = "holochain-0.0.109";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.109";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-C4vQxRM9GSVpYBIOn9lGoWzD13W3HAQaY6I0hnzQmuc=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_109-holochain-0.0.109/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_110 = {
    pname = "holochain_revision_holochain-0_0_110";
    version = "holochain-0.0.110";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.110";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-XBtsT24tvZiss3tPCitP/Pl6y2eHLh7CXZCeTDV207s=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_110-holochain-0.0.110/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_111 = {
    pname = "holochain_revision_holochain-0_0_111";
    version = "holochain-0.0.111";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.111";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-EkLYJJHdOKbJDrMQk4YwAyaXN1eivFW06eLnocYNBZw=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_111-holochain-0.0.111/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_112 = {
    pname = "holochain_revision_holochain-0_0_112";
    version = "holochain-0.0.112";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.112";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-NiDjI01JuCbEC4qzda+s9zyyQVuGhwa1yZAW60yylw0=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_112-holochain-0.0.112/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_113 = {
    pname = "holochain_revision_holochain-0_0_113";
    version = "holochain-0.0.113";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.113";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-OI/iKa+LptI8AJn58riVWfw+o/BZBaLJVR1dxIMEk2U=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_113-holochain-0.0.113/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_114 = {
    pname = "holochain_revision_holochain-0_0_114";
    version = "holochain-0.0.114";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.114";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-ocPRN1+HyPrp/TtqV0k5xsn2pP9+i4AXM6cYZlntbuQ=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_114-holochain-0.0.114/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_115 = {
    pname = "holochain_revision_holochain-0_0_115";
    version = "holochain-0.0.115";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.115";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-O35wWoqpN8VkaPaKxbx+TcoduwUVuOJOtBfzI2Lcbpg=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_115-holochain-0.0.115/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_116 = {
    pname = "holochain_revision_holochain-0_0_116";
    version = "holochain-0.0.116";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.116";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-VNhVCoRnJfARM64cD7EpdCBtbZFe1k50k+ZakHV5dR8=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_116-holochain-0.0.116/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_117 = {
    pname = "holochain_revision_holochain-0_0_117";
    version = "holochain-0.0.117";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.117";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-O9VHSbnCFoC5FcL9uHWAUUgr23AEbNnerm1N/9vBuPc=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_117-holochain-0.0.117/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_118 = {
    pname = "holochain_revision_holochain-0_0_118";
    version = "holochain-0.0.118";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.118";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-g3zO9XTWHaP9q7D6AsEohdvLVHtZF6GzuzQg0Ez2So8=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_118-holochain-0.0.118/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_119 = {
    pname = "holochain_revision_holochain-0_0_119";
    version = "holochain-0.0.119";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.119";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-3S4zUCh1MXVaf6qCI0NlgOpiq1msobgUUTmlSPv6KzU=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_119-holochain-0.0.119/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_120 = {
    pname = "holochain_revision_holochain-0_0_120";
    version = "holochain-0.0.120";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.120";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-X16Nsjxzj38JX13jysifVOrEzB9/fZZIbe5+fEHX16k=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_120-holochain-0.0.120/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_121 = {
    pname = "holochain_revision_holochain-0_0_121";
    version = "holochain-0.0.121";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.121";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-nZEySolvpXnTz9XlR+34rn6GJM/sj3y3snqhNGvmMkM=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_121-holochain-0.0.121/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_122 = {
    pname = "holochain_revision_holochain-0_0_122";
    version = "holochain-0.0.122";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.122";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-ptTOz1CVWBPMawoYdJJKlOQqweuSrCmjcgCw7sA9VyA=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_122-holochain-0.0.122/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_123 = {
    pname = "holochain_revision_holochain-0_0_123";
    version = "holochain-0.0.123";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.123";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-xhAzh+/bUgqxXuy8aVA0uvkb+28wJ7LiyoswguP4JIQ=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_123-holochain-0.0.123/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_124 = {
    pname = "holochain_revision_holochain-0_0_124";
    version = "holochain-0.0.124";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.124";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-TIBlBVSH/oWVWEFiBbM0rklyR7Ru5aKR0A9oaVGvalU=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_124-holochain-0.0.124/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_125 = {
    pname = "holochain_revision_holochain-0_0_125";
    version = "holochain-0.0.125";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.125";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Kj2ryH2Uwk8Ni5WNcsZMU3XRs0s21alrdWak5ZKMSYg=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_125-holochain-0.0.125/Cargo.lock;
      outputHashes = {
        "cargo-test-macro-0.1.0" = "sha256-hIGpT0n41CA24vss4itXS3O2XrznsBce/60PUVrwwfs=";
      };
    };
  };
  holochain_revision_holochain-0_0_126 = {
    pname = "holochain_revision_holochain-0_0_126";
    version = "holochain-0.0.126";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.126";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-YG9OxMqP77K8VtFpM6pEsDApX/S9fivx+j9bSnvHni0=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_126-holochain-0.0.126/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_127 = {
    pname = "holochain_revision_holochain-0_0_127";
    version = "holochain-0.0.127";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.127";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-NfrasLnSblIh4Rhfhh95qeEtG+9Tihfcn+CIgRpnwus=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_127-holochain-0.0.127/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_128 = {
    pname = "holochain_revision_holochain-0_0_128";
    version = "holochain-0.0.128";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.128";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Tzo5ExJJ/NpY+WOu63WT1J/7weprEU8Y4ECFnSgRilA=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_128-holochain-0.0.128/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_129 = {
    pname = "holochain_revision_holochain-0_0_129";
    version = "holochain-0.0.129";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.129";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-Mtp9fI71JqM/Qa3wsUvwkGlQdVQH3vOdD7jtYaqVdbg=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_129-holochain-0.0.129/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_130 = {
    pname = "holochain_revision_holochain-0_0_130";
    version = "holochain-0.0.130";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.130";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-VgiyhNwauv2a8arR3N45o7wXTsJ5Ip/Nv96r/bW3d1I=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_130-holochain-0.0.130/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_131 = {
    pname = "holochain_revision_holochain-0_0_131";
    version = "holochain-0.0.131";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.131";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-zEsVDzbhMBBp6hJ4d79PcVIjFTl+Lmpwkl5TAmqZOyM=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_131-holochain-0.0.131/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_132 = {
    pname = "holochain_revision_holochain-0_0_132";
    version = "holochain-0.0.132";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.132";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-nJ/SrPUhUEX9bHGbP4tGo9ZPocR8GZxUfpJgy2Lo74s=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_132-holochain-0.0.132/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_135 = {
    pname = "holochain_revision_holochain-0_0_135";
    version = "holochain-0.0.135";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.135";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-9jUxpwjKtQc9nnaFKwGC8SUlJ9hMRkdi1B40cwRc/rQ=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_135-holochain-0.0.135/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_136 = {
    pname = "holochain_revision_holochain-0_0_136";
    version = "holochain-0.0.136";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.136";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-SXYSj0sBJSjTOr8LGoYwgF4FW8qgmdXaZ6fVDK5GJCo=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_136-holochain-0.0.136/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_137 = {
    pname = "holochain_revision_holochain-0_0_137";
    version = "holochain-0.0.137";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.137";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-qDHa15r+Id4IH6rsiggJHhYa1qelt5fLrrrwUtsq3yI=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_137-holochain-0.0.137/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_138 = {
    pname = "holochain_revision_holochain-0_0_138";
    version = "holochain-0.0.138";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.138";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-6kmi2rs/Vmas2CkV4xmMsQk9kdz0N/nnglm94J1+Swo=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_138-holochain-0.0.138/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_139 = {
    pname = "holochain_revision_holochain-0_0_139";
    version = "holochain-0.0.139";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.139";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-zTEqWs4U7MNf/obqb4oTZr6LcbKYDgQu0pVHqnyHx3c=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_139-holochain-0.0.139/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_140 = {
    pname = "holochain_revision_holochain-0_0_140";
    version = "holochain-0.0.140";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.140";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-dfRs02sFp3U2yK+FmyVMRQQqbbtBuAqgQ7FdTmN1K9I=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_140-holochain-0.0.140/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_141 = {
    pname = "holochain_revision_holochain-0_0_141";
    version = "holochain-0.0.141";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.141";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-rYRYKSxJMaIBjT5+FjkZTrXIP+exkkUkMroVhz0tTwI=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_141-holochain-0.0.141/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_142 = {
    pname = "holochain_revision_holochain-0_0_142";
    version = "holochain-0.0.142";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.142";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-YFccih5b+JQ9u1TeMKKnYPjx9VLp4gDJFma56gImMkQ=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_142-holochain-0.0.142/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_143 = {
    pname = "holochain_revision_holochain-0_0_143";
    version = "holochain-0.0.143";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.143";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-XX+6hBq/6R/8rDCArHq12OYnOCjZ21C3ouFFFM2RmuE=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_143-holochain-0.0.143/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_144 = {
    pname = "holochain_revision_holochain-0_0_144";
    version = "holochain-0.0.144";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.144";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-OfWKY0wBWuS2FuAS04kG2Mea+g7EbmMJT4CRTQiRlBs=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_144-holochain-0.0.144/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_145 = {
    pname = "holochain_revision_holochain-0_0_145";
    version = "holochain-0.0.145";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.145";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-NyhR+Sa7B/pi7Wou9A0EoRndoChTJudjhmaBm5zN86I=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_145-holochain-0.0.145/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_146 = {
    pname = "holochain_revision_holochain-0_0_146";
    version = "holochain-0.0.146";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.146";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-RuEzu4U9dOei8L5MOoLvIM50czh8mzg+tCo8QCg815I=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_146-holochain-0.0.146/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_147 = {
    pname = "holochain_revision_holochain-0_0_147";
    version = "holochain-0.0.147";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.147";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-AjN0pDD9OAHlqgINFpMT2tZZEnF935CvKRtFEifPfv0=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_147-holochain-0.0.147/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_148 = {
    pname = "holochain_revision_holochain-0_0_148";
    version = "holochain-0.0.148";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.148";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-WpyNH1ok4OpfxFYZQ0p1QcpuJhWnJKueFa0KOZELlUU=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_148-holochain-0.0.148/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_149 = {
    pname = "holochain_revision_holochain-0_0_149";
    version = "holochain-0.0.149";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.149";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-kcX71XvSdxXIMm644DGFCZ06fnlQu73Tcp1MHF5GDqk=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_149-holochain-0.0.149/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_150 = {
    pname = "holochain_revision_holochain-0_0_150";
    version = "holochain-0.0.150";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.150";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-++AK1DGQbS1s/C9SRkV1iZ8kiAdwn8ow+Fn/FWYEfNQ=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_150-holochain-0.0.150/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_151 = {
    pname = "holochain_revision_holochain-0_0_151";
    version = "holochain-0.0.151";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.151";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-llnVcv9zVnFI1CgzhYEoGQKWLG2uGHJIAJtMwfHPN4Y=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_151-holochain-0.0.151/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  holochain_revision_holochain-0_0_152 = {
    pname = "holochain_revision_holochain-0_0_152";
    version = "holochain-0.0.152";
    src = fetchgit {
      url = "https://github.com/holochain/holochain";
      rev = "holochain-0.0.152";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-mvHyZpchHqB+MoDUGtf0PfCf+CD+GA7OxvE/0QAWEk4=";
    };
    cargoLock = {
      lockFile = ./holochain_revision_holochain-0_0_152-holochain-0.0.152/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  lair_revision_lair_keystore_api-v0_2_0 = {
    pname = "lair_revision_lair_keystore_api-v0_2_0";
    version = "lair_keystore_api-v0.2.0";
    src = fetchgit {
      url = "https://github.com/holochain/lair";
      rev = "lair_keystore_api-v0.2.0";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-n7nZyZR0Q68Uff7bTSVFtSDLi21CNcyKibOBx55Gasg=";
    };
    cargoLock = {
      lockFile = ./lair_revision_lair_keystore_api-v0_2_0-lair_keystore_api-v0.2.0/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  lair_revision_v0_0_10 = {
    pname = "lair_revision_v0_0_10";
    version = "v0.0.10";
    src = fetchgit {
      url = "https://github.com/holochain/lair";
      rev = "v0.0.10";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-yBCsdtC6vYnGQL1JkLkOzECk1TD4RoFzNARdsc+J0cg=";
    };
    cargoLock = {
      lockFile = ./lair_revision_v0_0_10-v0.0.10/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  lair_revision_v0_0_11 = {
    pname = "lair_revision_v0_0_11";
    version = "v0.0.11";
    src = fetchgit {
      url = "https://github.com/holochain/lair";
      rev = "v0.0.11";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-ZmRBVu2dlgLT/Kr/4PoVf4rD1jzexXyWU+dggrv7IrQ=";
    };
    cargoLock = {
      lockFile = ./lair_revision_v0_0_11-v0.0.11/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  lair_revision_v0_0_3 = {
    pname = "lair_revision_v0_0_3";
    version = "v0.0.3";
    src = fetchgit {
      url = "https://github.com/holochain/lair";
      rev = "v0.0.3";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-EKuxixeCPhvkwv8Fq5+S2GNt59FEeBrgGHB50oJPP8o=";
    };
    cargoLock = {
      lockFile = ./lair_revision_v0_0_3-v0.0.3/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  lair_revision_v0_0_4 = {
    pname = "lair_revision_v0_0_4";
    version = "v0.0.4";
    src = fetchgit {
      url = "https://github.com/holochain/lair";
      rev = "v0.0.4";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-2zPhOSHH8mX6F3kfymNf9p+YxdLf4y3E0+G25wovD04=";
    };
    cargoLock = {
      lockFile = ./lair_revision_v0_0_4-v0.0.4/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  lair_revision_v0_0_7 = {
    pname = "lair_revision_v0_0_7";
    version = "v0.0.7";
    src = fetchgit {
      url = "https://github.com/holochain/lair";
      rev = "v0.0.7";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-g9oaWJsUJT/HhxYXbpl2Ko+uZZGKk9cWBYHksEiCwYo=";
    };
    cargoLock = {
      lockFile = ./lair_revision_v0_0_7-v0.0.7/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  lair_revision_v0_0_8 = {
    pname = "lair_revision_v0_0_8";
    version = "v0.0.8";
    src = fetchgit {
      url = "https://github.com/holochain/lair";
      rev = "v0.0.8";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-AeyEQWLP2xw8WezDHqfq0oEFxYWY0E7kmuciz/qtCP8=";
    };
    cargoLock = {
      lockFile = ./lair_revision_v0_0_8-v0.0.8/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  lair_revision_v0_0_9 = {
    pname = "lair_revision_v0_0_9";
    version = "v0.0.9";
    src = fetchgit {
      url = "https://github.com/holochain/lair";
      rev = "v0.0.9";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-glSixh2GtWtJ1wswAA0Q2hnLIFPQY+Tsh36IcUgIbRs=";
    };
    cargoLock = {
      lockFile = ./lair_revision_v0_0_9-v0.0.9/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  lair_revision_v0_1_0 = {
    pname = "lair_revision_v0_1_0";
    version = "v0.1.0";
    src = fetchgit {
      url = "https://github.com/holochain/lair";
      rev = "v0.1.0";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-EWtc9+KcN/RHOg5N4wCLBXRppXheda5uubwrQVojc0s=";
    };
    cargoLock = {
      lockFile = ./lair_revision_v0_1_0-v0.1.0/Cargo.lock;
      outputHashes = {
        
      };
    };
  };
  nixpkgs = {
    pname = "nixpkgs";
    version = "eabc38219184cc3e04a974fe31857d8e0eac098d";
    src = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/eabc38219184cc3e04a974fe31857d8e0eac098d.tar.gz";
      sha256 = "04ffwp2gzq0hhz7siskw6qh9ys8ragp7285vi1zh8xjksxn1msc5";
    };
  };
  nvfetcher = {
    pname = "nvfetcher";
    version = "6bd24e64192add7778a523686ab1dac3fdac05c0";
    src = fetchFromGitHub ({
      owner = "berberman";
      repo = "nvfetcher";
      rev = "6bd24e64192add7778a523686ab1dac3fdac05c0";
      fetchSubmodules = false;
      sha256 = "sha256-d/0RIOJyArefrxRcGT4RFFRa6zWCo2WxebtLE5UToRg=";
    });
  };
  rust-overlay = {
    pname = "rust-overlay";
    version = "9fd7ff1d6d6a1337e7eccfff89bfbbc2793d2828";
    src = fetchgit {
      url = "https://github.com/oxalica/rust-overlay";
      rev = "9fd7ff1d6d6a1337e7eccfff89bfbbc2793d2828";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-ppfIZ8ualm3pSgCVCHk0uyBtkGdYszl9GIzZXx7FFu0=";
    };
  };
}
