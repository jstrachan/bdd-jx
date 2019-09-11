FROM scratch
EXPOSE 8080
ENTRYPOINT ["/bdd-jx"]
COPY ./bin/ /