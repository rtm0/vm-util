FROM debian
COPY ./bin/loadgen /loadgen
RUN chmod +x /loadgen
ENTRYPOINT ["/loadgen"]
