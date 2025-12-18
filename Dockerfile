# check=skip=RedundantTargetPlatform
# setup build image
FROM --platform=linux/amd64 golang:1.25.5@sha256:20b91eda7a9627c127c0225b0d4e8ec927b476fa4130c6760928b849d769c149 AS build

WORKDIR /app

COPY main.go go.mod go.sum ./
RUN go mod download -x

ARG GO_LINKER_ARGS
ARG TARGETARCH
ARG TARGETOS

COPY pkg ./pkg
COPY cmd ./cmd

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -tags -trimpath  \
    -o ./build/_output/bin/dynatrace-bootstrapper

# platform is required, otherwise the copy command will copy the wrong architecture files, don't trust GitHub Actions linting warnings
FROM --platform=linux/amd64 public.ecr.aws/dynatrace/dynatrace-codemodules:1.311.70.20250416-094918 AS codemodules

# copy bootstrapper binary
COPY --from=build /app/build/_output/bin /opt/dynatrace/oneagent/agent/lib64/

LABEL name="Dynatrace Bootstrapper" \
      vendor="Dynatrace LLC" \
      maintainer="Dynatrace LLC"

ENV USER_UID=1001 \
    USER_NAME=dynatrace-bootstrapper

USER ${USER_UID}:${USER_UID}
EXPOSE 8081

ENTRYPOINT ["/opt/dynatrace/oneagent/agent/lib64/dynatrace-bootstrapper"]
