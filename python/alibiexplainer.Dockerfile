ARG VERSION
FROM --platform=linux/amd64 sivanantha/build-base-image:${VERSION} as builder

COPY alibiexplainer/pyproject.toml alibiexplainer/poetry.lock alibiexplainer/
RUN cd alibiexplainer && poetry install --no-root --no-interaction --no-cache
COPY alibiexplainer alibiexplainer
RUN cd alibiexplainer && poetry install --no-interaction --no-cache


FROM --platform=linux/amd64 sivanantha/prod-base-image:${VERSION} as prod

COPY --from=builder --chown=kserve:kserve $VIRTUAL_ENV $VIRTUAL_ENV
COPY --from=builder kserve kserve
COPY --from=builder alibiexplainer alibiexplainer

ENTRYPOINT ["python", "-m", "alibiexplainer"]
