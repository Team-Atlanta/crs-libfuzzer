group "default" {
  targets = ["crs-libfuzzer-base"]
}

target "crs-libfuzzer-base" {
  context    = "."
  dockerfile = "oss-crs/dockerfiles/base.Dockerfile"
}