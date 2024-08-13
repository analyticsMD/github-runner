# GitHub Actions Runner Image

Using GitHub's actions-runner base image and adding the following:
- git (Funny but true)
- jq
- nodejs
- openssh-client
- unzip

## Pushing to GitHub Container Registry

```
docker build -t actions-runner-with-git --platform=linux/amd64 .

```