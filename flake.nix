{
  description = "hello-chelis fixed Nix OCI image";

  inputs.ci.url = "path:.ci-central-helper";
  inputs.nixpkgs.follows = "ci/nixpkgs";

  outputs =
    {
      self,
      ci,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
      helperRevision = "b9d928466d917991ed0c818e82f6737d907dce2b";
      artifacts = ./.ci-container-artifacts;
      sourceRoot = toString ./.;
      excludedPrefixes = map (name: "/${name}") [
        ".ci-central-helper"
        ".ci-container-artifacts"
        ".devenv"
        ".direnv"
        ".git"
        ".pytest_cache"
        ".venv"
        "result"
        "target"
      ];
      consumerSource = builtins.path {
        path = ./.;
        name = "hello-chelis-source";
        filter =
          path: _type:
          let
            relative = lib.removePrefix sourceRoot (toString path);
          in
          !(lib.any (prefix: relative == prefix || lib.hasPrefix "${prefix}/" relative) excludedPrefixes);
      };
      chelisToolchain =
        pkgs.runCommand "chelis-toolchain-0.17.1"
          {
            nativeBuildInputs = [
              pkgs.autoPatchelfHook
              pkgs.gnutar
              pkgs.gzip
              pkgs.patchelf
            ];
            buildInputs = [
              pkgs.glibc
              pkgs.stdenv.cc.cc.lib
            ];
          }
          ''
            mkdir -p "$out"
            tar -xzf ${artifacts}/chelis-toolchain-linux-x86_64/chelis-v0.17.1-linux-x86_64.tar.gz \
              -C "$out" --strip-components=1
            autoPatchelf "$out"
            case "$(patchelf --print-interpreter "$out/bin/chelis")" in
              /nix/store/*/lib/ld-linux-x86-64.so.2) ;;
              *) exit 1 ;;
            esac
            "$out/bin/chelis" --version >/dev/null
            test -f "$out/lib/libchelis_runtime.a"
          '';
      octantCli =
        pkgs.runCommand "octant-cli-0.10.1"
          {
            nativeBuildInputs = [
              pkgs.autoPatchelfHook
              pkgs.gnutar
              pkgs.gzip
              pkgs.patchelf
            ];
            buildInputs = [
              pkgs.glibc
              pkgs.stdenv.cc.cc.lib
            ];
          }
          ''
            mkdir -p "$out"
            tar -xzf ${artifacts}/octant-cli-linux-x86_64/octant-v0.10.1-linux-x86_64.tar.gz \
              -C "$out" --strip-components=1
            autoPatchelf "$out"
            case "$(patchelf --print-interpreter "$out/bin/octant")" in
              /nix/store/*/lib/ld-linux-x86-64.so.2) ;;
              *) exit 1 ;;
            esac
            "$out/bin/octant" --version >/dev/null
          '';
      python = pkgs.python311.withPackages (packages: [
        packages.pytest
        packages.pytest-xdist
      ]);
      consumerRoot = pkgs.runCommand "hello-chelis-container-root" { } ''
        mkdir -p \
          "$out/workspace" \
          "$out/share/chelis/reef/cache" \
          "$out/share/chelis/reef/packages"
        cp -R ${consumerSource}/. "$out/workspace/"

        install_package() {
          name="$1"
          version="$2"
          archive="$3"
          shell="$4"
          destination="$out/share/chelis/reef/packages/$name/$version"
          mkdir -p "$destination"
          cp "$archive" "$destination/$name-$version.tar.zst"
          cp "$shell" "$destination/$name-$version.chb"
        }

        install_package coral 0.7.32 \
          ${artifacts}/coral-archive/coral-0.7.32.tar.zst \
          ${artifacts}/coral-shell/coral-0.7.32.chb
        install_package nautilus 0.7.35 \
          ${artifacts}/nautilus-archive/nautilus-0.7.35.tar.zst \
          ${artifacts}/nautilus-shell/nautilus-0.7.35.chb
        install_package octant 0.10.1 \
          ${artifacts}/octant-archive/octant-0.10.1.tar.zst \
          ${artifacts}/octant-shell/octant-0.10.1.chb
        install_package c-earchin 0.3.3 \
          ${artifacts}/c-earchin-archive/c-earchin-0.3.3.tar.zst \
          ${artifacts}/c-earchin-shell/c-earchin-0.3.3.chb
        install_package school 0.1.12 \
          ${artifacts}/school-archive/school-0.1.12.tar.zst \
          ${artifacts}/school-shell/school-0.1.12.chb

        cat > "$out/share/chelis/reef/index.json" <<'JSON'
        {
          "packages": {
            "c-earchin": [
              {
                "version": "0.3.3",
                "compiler": "=0.14.0",
                "archive_sha256": "af1bebc4c977099451b39a92fc16352ea333e7a6d1ac1c4144573ddac019aa3a",
                "shell_sha256": "6af60342693f76d53a3a6fad1415d257c3485b6b1722929abf327941f5795f92",
                "remote_origin": "github://Chelis-Lang/c-earchin@v0.3.3"
              }
            ],
            "coral": [
              {
                "version": "0.7.32",
                "compiler": "=0.17.1",
                "archive_sha256": "d819b4182d7157a061a1996b3102fcb01ed7e0296fdb4a9f1850e20a554486f3",
                "shell_sha256": "4097970a3f784373dc4bbf8937aa0107893201bcce35102a518e39ee90869ef0",
                "remote_origin": "github://Chelis-Lang/coral@v0.7.32"
              }
            ],
            "nautilus": [
              {
                "version": "0.7.35",
                "compiler": "=0.17.1",
                "archive_sha256": "11809a4676aa4b3b4fdd2a182ebae5cdfcf17c0930d87bccf3028d332637e630",
                "shell_sha256": "ad451b4cda907baf68f451c90b0e27fc1720ab92998f1ddbb7991e83be2f0c15",
                "remote_origin": "github://Chelis-Lang/nautilus@v0.7.35"
              }
            ],
            "octant": [
              {
                "version": "0.10.1",
                "compiler": "=0.14.0",
                "archive_sha256": "45b60e858f529bbaf1d55c1823449f25e9325f591430cb2865a1146ac302847c",
                "shell_sha256": "8b86c720fca3535b0e57c69ed4cd6c4c4d1fe9193391c31571369ff2760ce85a",
                "remote_origin": "github://Chelis-Lang/octant@v0.10.1"
              }
            ],
            "school": [
              {
                "version": "0.1.12",
                "compiler": "=0.17.1",
                "archive_sha256": "d7a23fa52592cc0d43ff12caeaf6fcda5f25682451f7c84f81539ca3402b4656",
                "shell_sha256": "c97bd3fb87742c3a01450ade88ff1e258a207150a745ec67ee3c49bdeedf4e52",
                "remote_origin": "github://Chelis-Lang/school@v0.1.12"
              }
            ]
          }
        }
        JSON
      '';
      containerImage = ci.lib.mkContainerCiImage {
        inherit pkgs helperRevision consumerRoot;
        systemPackages = [
          pkgs.bashInteractive
          pkgs.cacert
          pkgs.coreutils
          pkgs.diffutils
          pkgs.findutils
          pkgs.gawk
          pkgs.gcc
          pkgs.git
          pkgs.gnugrep
          pkgs.gnumake
          pkgs.gnused
          pkgs.openblas
          pkgs.valgrind
        ];
        toolchainPackages = [
          chelisToolchain
          octantCli
          python
        ];
      };
    in
    {
      packages.${system}.container-ci-image = containerImage;
    };
}
