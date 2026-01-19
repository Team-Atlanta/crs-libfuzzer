group "dind-images" {
  targets = ["internal-runner"]
}

group "default" {
  targets = ["dind-images"]
}

target "internal-runner" {
  dockerfile = "runner-internal.Dockerfile"
  context    = "."
  tags       = ["internal-runner:latest"]
}
