# gitlab-runner with amazon-ecr-credential-helper

Docker image with [amazon-ecr-credential-helper](https://github.com/awslabs/amazon-ecr-credential-helper) added to [gitlab-runner](https://hub.docker.com/r/gitlab/gitlab-runner/).

## How to use

Setup gitlab-runner.

```sh
docker pull ngyuki/gitlab-runner:alpine

mkdir -p /opt/gitlab-runner/{ecr,runner}

cat <<'EOS'> /opt/gitlab-runner/.env
AWS_ACCESS_KEY_ID=AKI...
AWS_SECRET_ACCESS_KEY=abc123...
EOS

docker run --detach \
  --name gitlab-runner \
  --env-file /opt/gitlab-runner/.env \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /opt/gitlab-runner/runner/:/etc/gitlab-runner/ \
  --volume /opt/gitlab-runner/ecr/:/root/.ecr/ \
  ngyuki/gitlab-runner:alpine

docker exec gitlab-runner gitlab-runner register \
  --non-interactive \
  --url 'http://gitlab.example.com/' \
  --registration-token "${REGISTRATION_TOKEN:?}" \
  --name 'docker-runner-with-ecr' \
  --executor 'docker' \
  --docker-image 'alpine:latest' \
  --env 'DOCKER_AUTH_CONFIG={"credsStore":"ecr-login"}'

echo 999999999999.dkr.ecr.ap-northeast-1.amazonaws.com | docker exec -i gitlab-runner docker-credential-ecr-login get
```

Add `.gitlab-ci.yml` to your project

```sh
test:
  stage: test
  image: 999999999999.dkr.ecr.ap-northeast-1.amazonaws.com/awesome:latest
  script:
    - make test
```
