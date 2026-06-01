docker := require("docker")
docker_volume := "template-template-nix-store"

_create_docker_volume:
    "{{ docker }}" volume inspect "{{ docker_volume }}" >/dev/null 2>&1 || \
        "{{ docker }}" volume create "{{ docker_volume }}"

[positional-arguments]
[no-cd]
_run-in-docker *ARGS: _create_docker_volume
    "{{ docker }}" container run --rm -it \
        --volume "$PWD:/work" \
        --volume "{{ docker_volume }}:/nix" \
        --workdir "/work" \
        docker.io/nixos/nix \
        nix --extra-experimental-features 'nix-command flakes' --accept-flake-config \
        shell "nixpkgs#copier" "nixpkgs#direnv" "nixpkgs#just" --command "$@"

[positional-arguments]
[no-cd]
_copier *ARGS:
    just _run-in-docker copier "$@"

[group("test")]
clean-test-projects:
    find test -path "*/files" -exec rm -rf \{\} \+

[group("test")]
[positional-arguments]
_create-test-project name *EXTRA_ARGS:
    mkdir -p "test/{{ name }}/files"

    # Run this in docker to avoid this repo intefering with the templating.
    # See also https://github.com/copier-org/copier/issues/2235
    shift && \
        just _copier copy . "test/{{ name }}/files" --trust \
            "$@"

[group("test")]
create-test-projects: clean-test-projects
    mkdir -p test

    # Create a basic template using copier directly
    just _create-test-project copier \
        --data title="Test project template (copier)" \
        --data github_repo="test-user/test-repo"

    # Create a basic template using nix run
    nix run "." -- copy test/nix-run/files --trust \
        --data title="Test project template (nix run)" \
        --data github_repo="test-user/test-repo"
    direnv allow test/nix-run/files

[group("test")]
_run-test name:
    #!/usr/bin/env bash
    set -euxo pipefail

    test_dir="$(realpath "test/{{ name }}")"
    test_script="$(realpath "$test_dir/run_test.sh")"

    cd "$test_dir"

    if [ -x "$test_script" ]; then
        echo "running $test_script ..."
        # Run this in docker to avoid this repo intefering with the templating.
        just _run-in-docker bash -c "cd files && '$(realpath --relative-to="$test_dir/files" "${test_script}")'"
        echo "$test_script done"
    else
        echo "$test_script does not exist, skipping tests for \"{{ name }}\""
    fi

[group("test")]
run-tests: \
        clean-test-projects \
        create-test-projects
    #!/usr/bin/env bash
    set -euxo pipefail

    for d in test/*; do
        just _run-test "$(basename "$d")"
    done

