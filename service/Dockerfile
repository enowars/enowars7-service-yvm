FROM nixos/nix as build
WORKDIR /build
RUN nix-env -iA nixpkgs.patchelf
COPY flake.nix  flake.nix
COPY flake.lock flake.lock
RUN nix --extra-experimental-features flakes --extra-experimental-features nix-command build || true
COPY dune-project dune-project
COPY src src
RUN nix --extra-experimental-features flakes --extra-experimental-features nix-command build
RUN patchelf --set-interpreter "/lib64/ld-linux-x86-64.so.2" ./result/bin/yvm

FROM php:fpm
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
COPY web/runner.php .
COPY --from=build /build/result/bin/yvm .
