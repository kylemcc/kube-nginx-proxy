workflow "Build and Publish Docker Image" {
  on = "push"
  resolves = [
    "Tag Image",
    "Push Image",
  ]
}

action "Master branch or tag" {
  uses = "actions/bin/filter@ec328c7554cbb19d9277fc671cf01ec7c661cd9a"
  args = "branch master || tag"
}

action "Docker login" {
  uses = "actions/docker/login@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
  needs = ["Master branch or tag"]
}

action "Build Image" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  args = "build -t kube-nginx-proxy ."
  needs = ["Docker login"]
}

action "Tag Image" {
  uses = "actions/docker/tag@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Build Image"]
  args = "--env kube-nginx-proxy kylemcc/kube-nginx-proxy"
}

action "Push Image" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Tag Image"]
  args = "push kylemcc/kube-nginx-proxy"
}
