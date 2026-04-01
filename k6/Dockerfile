FROM grafana/k6:latest

WORKDIR /scripts

# Copy only test files
COPY smoke.js .
COPY load.js .
COPY stress.js .

ENTRYPOINT ["k6"]