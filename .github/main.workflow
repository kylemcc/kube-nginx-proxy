workflow "Build and Publish Docker Image" {
  on = "push"
  resolves = [
    "Tag Image",
    "Push Image",
  ]
}

action "Master Branch Filter" {
  uses = "actions/bin/filter@ec328c7554cbb19d9277fc671cf01ec7c661cd9a"
  args = "branch master"
}

action "Docker Registry" {
  uses = "actions/docker/login@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Master Branch Filter"]
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "Build Image" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Docker Registry"]
  args = "build -t kylemcc/kube-nginx-proxy ."
}

action "Tag Image" {
  uses = "actions/docker/tag@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Build Image"]
  args = "--env kylemcc/kube-nginx-proxy kylemcc/kube-nginx-proxy"
}

action "Push Image" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Tag Image"]
  args = "push kylemcc/kube-nginx-proxy"
}
