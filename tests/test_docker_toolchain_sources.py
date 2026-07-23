"""Docker builds select an authenticated, digest-verified Chelis toolchain."""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DOCKERFILE = REPO / "docker" / "Dockerfile"
COMPOSE = REPO / "docker" / "docker-compose.yml"
DIGEST_LOCK = REPO / ".github" / "chelis-toolchains.json"
MANIFEST = REPO / "reef.toml"


def compiler_version() -> str:
    match = re.search(
        r'^compiler\s*=\s*"=(\d+\.\d+\.\d+)"\s*$',
        MANIFEST.read_text(encoding="utf-8"),
        re.MULTILINE,
    )
    assert match is not None, "reef.toml must carry an exact compiler pin"
    return match.group(1)


def linux_digest(version: str) -> str:
    lock = json.loads(DIGEST_LOCK.read_text(encoding="utf-8"))
    return lock["versions"][version]["linux-x86_64"]


class DockerToolchainSourceTests(unittest.TestCase):
    def test_compose_selects_the_locked_local_toolchain_source(self) -> None:
        version = compiler_version()
        digest = linux_digest(version)
        compose = COMPOSE.read_text(encoding="utf-8")

        self.assertIn("CHELIS_TOOLCHAIN_SOURCE: local-toolchain", compose)
        self.assertIn(f"CHELIS_VERSION: {version}", compose)
        self.assertIn(f"CHELIS_LINUX_SHA256: {digest}", compose)

    def test_dockerfile_separates_ci_staging_and_local_digest_verification(
        self,
    ) -> None:
        dockerfile = DOCKERFILE.read_text(encoding="utf-8")

        self.assertIn("ARG CHELIS_TOOLCHAIN_SOURCE=ci-toolchain", dockerfile)
        self.assertIn("FROM scratch AS ci-toolchain", dockerfile)
        self.assertIn("COPY .ci-authenticated-chelis/ /toolchain/", dockerfile)
        self.assertIn("FROM release-download-base AS local-toolchain", dockerfile)
        self.assertIn(
            "FROM ${CHELIS_TOOLCHAIN_SOURCE} AS selected-toolchain", dockerfile
        )
        self.assertIn(
            "COPY --from=selected-toolchain /toolchain/ /usr/local/", dockerfile
        )

        local_stage = dockerfile.split(
            "FROM release-download-base AS local-toolchain", 1
        )[1].split("FROM ${CHELIS_TOOLCHAIN_SOURCE} AS selected-toolchain", 1)[0]
        run_blocks = local_stage.split("\nRUN ")
        self.assertEqual(len(run_blocks), 3)
        credentialed = "RUN " + run_blocks[1]
        uncredentialed = "RUN " + run_blocks[2]

        self.assertIn(
            "RUN --mount=type=secret,id=github_token,required=true", credentialed
        )
        self.assertIn("download-github-release-asset Chelis-Lang/chelis", credentialed)
        self.assertIn(
            '"${CHELIS_VERSION}" =~ ^[0-9]+\\.[0-9]+\\.[0-9]+$',
            credentialed,
        )
        self.assertIn("sha256sum --check", credentialed)
        self.assertNotIn("tar -", credentialed)

        self.assertIn("tar -xzf", uncredentialed)
        self.assertNotIn("--mount=type=secret", uncredentialed)
        self.assertNotIn("chelis --version", uncredentialed)

        final_image = dockerfile.split("FROM runtime-base AS final", 1)[1]
        version_check = final_image.index('test "$(chelis --version)"')
        first_secret_mount = final_image.index(
            "RUN --mount=type=secret,id=github_token"
        )
        self.assertLess(version_check, first_secret_mount)


if __name__ == "__main__":
    unittest.main()
