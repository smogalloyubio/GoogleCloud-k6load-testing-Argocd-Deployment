FROM grafana/k6:0.51.0


WORKDIR /home/k6/scripts


COPY --chown=k6:k6 smoke.js .
COPY --chown=k6:k6 load.js .
COPY --chown=k6:k6 stress.js .


HEALTHCHECK --interval=30s --timeout=3s \
  CMD k6 version || exit 1


USER k6

ENTRYPOINT ["k6"]