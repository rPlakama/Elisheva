{
  lib,
  stdenv,
  cmake,
  ninja,
  boost,
  cpp-jwt,
  cubeb,
  eden,
  enet,
  fetchFromGitHub,
  ffmpeg-headless,
  fmt,
  frozen-containers,
  gamemode,
  glslang,
  httplib,
  kdePackages,
  libopus,
  libusb1,
  lz4,
  nlohmann_json,
  oaknut,
  openssl,
  pipewire,
  pkg-config,
  python3,
  qt6,
  sdl3,
  simpleini,
  sirit,
  spirv-headers,
  vulkan-headers,
  vulkan-loader,
  vulkan-memory-allocator,
  vulkan-utility-libraries,
  xbyak,
  zlib,
  wrapGAppsHook3,
}:

let
  nx_tzdb = eden.nx_tzdb;

  httplib' = httplib.overrideAttrs (finalAttrs: {
    version = "0.46.0";

    src = fetchFromGitHub {
      owner = "yhirose";
      repo = "cpp-httplib";
      rev = "v0.46.0";
      hash = "sha256-Vzr51oo344jFNwmqdtLWxClJpuCTzmnMqXyLCz8UZj4=";
    };
  });

  zbic = fetchFromGitHub {
    owner = "kinnay";
    repo = "zbic";
    rev = "11b08f2712264bbed731545085cbd9702096ceb7";
    hash = "sha256-pHvxa1gkUvQo6mUgmLWtj1kcu01BLdGmttZyb8ZAj/o=";
  };

  xxhash = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "xxHash";
    rev = "v0.8.3";
    hash = "sha256-h6kohM+NxvQ89R9NEXZcYBG2wPOuB4mcyPfofKrx9wQ=";
  };

  zstd-src = fetchFromGitHub {
    owner = "facebook";
    repo = "zstd";
    rev = "33618c8";
    hash = "sha256-UP99PUq8N+fmU972Jxim4f9u//T+4hRW+wuTZzWg3uI=";
  };

  reshade = fetchFromGitHub {
    owner = "crosire";
    repo = "reshade";
    rev = "v6.8.0";
    hash = "sha256-K6QC7CLqy8M318n9WbuqGvcRF9g9abvDD/xbr7T+nXo=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lichii";
  version = "0.1.0-rc1";

  src = fetchFromGitHub {
    owner = "zortos293";
    repo = "Lichii";
    rev = "build-386";
    hash = "sha256-3RCdoAIFYC1du3KpK3tLm0LOZQg1OJLI0SCizKOCrLY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    glslang
    pkg-config
    python3
    qt6.qttools
    qt6.wrapQtAppsHook
    wrapGAppsHook3
  ];

  buildInputs = [
    boost
    cpp-jwt
    cubeb
    enet
    ffmpeg-headless
    fmt
    frozen-containers
    gamemode
    httplib'
    kdePackages.quazip
    libopus
    libusb1
    lz4
    nlohmann_json
    openssl
    qt6.qtbase
    qt6.qt5compat
    qt6.qtmultimedia
    qt6.qtwayland
    qt6.qtwebengine
    qt6.qtcharts
    sdl3
    simpleini
    sirit
    spirv-headers
    vulkan-headers
    vulkan-loader
    vulkan-memory-allocator
    vulkan-utility-libraries
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isx86_64 [
    xbyak
  ]
  ++ lib.optionals stdenv.hostPlatform.isAarch64 [
    oaknut
  ];

  postUnpack = ''
    (
    cd "$sourceRoot"

    mkdir -p .cache/cpm/zbic .cache/cpm/xxhash .cache/cpm/zstd .cache/cpm/reshade

    cp -r ${zbic} .cache/cpm/zbic/11b08f2712264bbed731545085cbd9702096ceb7
    cp -r ${xxhash} .cache/cpm/xxhash/v0.8.3
    cp -r ${zstd-src} .cache/cpm/zstd/33618c8
    cp -r ${reshade} .cache/cpm/reshade/v6.8.0

    chmod -R u+w .cache/cpm

    printf none > .cache/cpm/zbic/11b08f2712264bbed731545085cbd9702096ceb7/.cpm_patch_key
    printf none > .cache/cpm/xxhash/v0.8.3/.cpm_patch_key
    printf none > .cache/cpm/zstd/33618c8/.cpm_patch_key

    patch -p1 -d .cache/cpm/reshade/v6.8.0 < .patch/reshade/0001-from-chars-fallback.patch
    printf %s "$(sha512sum .patch/reshade/0001-from-chars-fallback.patch | cut -d' ' -f1)" \
      > .cache/cpm/reshade/v6.8.0/.cpm_patch_key
    )
  '';

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" false)
    (lib.cmakeBool "LICHII_TESTS" false)

    (lib.cmakeBool "CPMUTIL_FORCE_SYSTEM" true)
    (lib.cmakeFeature "LICHII_TZDB_PATH" "${nx_tzdb}")

    (lib.cmakeBool "LICHII_USE_QT_WEB_ENGINE" true)
    (lib.cmakeBool "LICHII_USE_QT_MULTIMEDIA" true)
    (lib.cmakeBool "ENABLE_QT_TRANSLATION" true)
    (lib.cmakeBool "LICHII_INSTALL_UDEV_RULES" true)
    (lib.cmakeFeature "LICHII_BUILD_TAG" "build-386")

    (lib.cmakeBool "ENABLE_LTO" false)
    (lib.cmakeBool "ENABLE_WERROR" false)

    (lib.cmakeBool "zbic_FORCE_BUNDLED" true)
    (lib.cmakeBool "xxhash_FORCE_BUNDLED" true)
    (lib.cmakeBool "reshade_FORCE_BUNDLED" true)
  ];

  preFixup = ''
    qtWrapperArgs+=(--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        vulkan-loader
        pipewire
      ]
    })
  '';

  meta = {
    description = "Experimental Nintendo Switch and Switch 2 emulator";
    homepage = "https://github.com/zortos293/Lichii";
    mainProgram = "lichii";
    license = lib.licenses.gpl3Plus;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
