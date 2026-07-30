ARG target_base_image
FROM $target_base_image

COPY --from=oss-crs-deps /nix/store /nix/store
COPY --from=oss-crs-deps /usr/local/bin/libCRS /usr/local/bin/libCRS
COPY --from=oss-crs-deps /usr/local/bin/rsync /usr/local/bin/rsync

COPY bin/compile_target /usr/local/bin/compile_target

CMD ["compile_target"]
