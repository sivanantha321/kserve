target "build-base" {
    dockerfile = "build_base_image.Dockerfile"
    context = "python"
    platforms = ["linux/amd64"]
}

target "prod-base" {
    dockerfile = "prod_base_image.Dockerfile"
    context = "python"
    platforms = ["linux/amd64"]
}

target "default" {
    contexts = {
        build-base-image = "target:build-base"
        prod-base-image = "target:prod-base"
    }
    dockerfile = "alibiexplainer.Dockerfile"
    context = "python"
    platforms = ["linux/amd64"]
    tags = ["kserve/alibiexplainer:latest"]
}

