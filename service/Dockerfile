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

FROM ubuntu:rolling
RUN apt update && apt install -y nginx php-fpm

COPY nginx.conf /etc/nginx/nginx.conf

COPY entrypoint.sh /root
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT /root/entrypoint.sh

WORKDIR /var/www/html
COPY --from=build /build/result/bin/yvm .
RUN chown www-data:www-data yvm
RUN mkdir -m 777 classes
RUN rm index.nginx-debian.html
COPY index.html .
COPY runner.php .
