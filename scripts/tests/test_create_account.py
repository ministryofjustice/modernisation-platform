import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


SCRIPT_PATH = Path(__file__).parents[1] / "create-account.py"
REQUEST_FIXTURE_PATH = Path(__file__).parent / "fixtures" / "environment-request.json"
SPEC = importlib.util.spec_from_file_location("create_account", SCRIPT_PATH)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError(f"Unable to load {SCRIPT_PATH}")
create_account = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(create_account)


def valid_request():
    return json.loads(REQUEST_FIXTURE_PATH.read_text())


class LoadRequestTests(unittest.TestCase):
    def write_request(self, directory, request):
        request_path = Path(directory) / "request.json"
        request_path.write_text(json.dumps(request))
        return request_path

    def test_loads_and_normalises_structured_request(self):
        with tempfile.TemporaryDirectory() as directory:
            account = create_account.load_request(self.write_request(directory, valid_request()))

        self.assertEqual(account["app_name"], "example-service")
        self.assertEqual(account["github_owners"], ["example-codeowners"])
        self.assertEqual(account["github_reviewers"], ["example-reviewers"])
        self.assertEqual(
            account["env_selections"],
            [
                {
                    "name": "development",
                    "access": [
                        {"level": "developer", "sso_group_name": "example-service-developers"},
                        {"level": "sandbox", "sso_group_name": "example-service-sandbox"},
                    ],
                },
                {
                    "name": "production",
                    "access": [
                        {"level": "view-only", "sso_group_name": "example-service-viewers"},
                    ],
                },
            ],
        )

    def test_rejects_sandbox_access_outside_development(self):
        request = valid_request()
        request["environments"][1]["access"] = [
            {"level": "sandbox", "ssoGroupName": "example-sandbox"}
        ]

        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "sandbox access is only supported in development"):
                create_account.load_request(self.write_request(directory, request))

    def test_requires_an_sso_group_for_every_access_role(self):
        request = valid_request()
        request["environments"][0]["access"][1]["ssoGroupName"] = ""

        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, r"environments\[0\].access\[1\].ssoGroupName"):
                create_account.load_request(self.write_request(directory, request))

    def test_rejects_invalid_request_id(self):
        request = valid_request()
        request["requestId"] = "not-a-uuid\nUNSAFE=value"

        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "requestId must be a UUID"):
                create_account.load_request(self.write_request(directory, request))


class CreateAccountTests(unittest.TestCase):
    def test_generates_environment_json_and_updates_policy(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            env_dir = root / "environments"
            env_dir.mkdir()
            rego_path = root / "expected.rego"
            rego_path.write_text('package policies.environments\n\nexpected := {"accounts": ["zeta"]}\n')
            request_path = LoadRequestTests().write_request(directory, valid_request())

            account = create_account.load_request(request_path)
            create_account.create_account(account, env_dir=str(env_dir), rego_path=str(rego_path))

            generated = json.loads((env_dir / "example-service.json").read_text())
            generated_rego = rego_path.read_text()

        self.assertEqual(generated["account-type"], "member")
        self.assertEqual(generated["codeowners"], ["example-codeowners"])
        self.assertEqual(generated["github_action_reviewer"], ["example-reviewers"])
        self.assertEqual(generated["environments"][0]["name"], "development")
        self.assertEqual(generated["environments"][0]["nuke"], "")
        self.assertEqual(
            generated["environments"][0]["access"],
            [
                {"sso_group_name": "example-service-developers", "level": "developer"},
                {"sso_group_name": "example-service-sandbox", "level": "sandbox"},
            ],
        )
        self.assertIn('"example-service"', generated_rego)

    def test_omits_optional_team_fields_to_use_access_group_defaults(self):
        request = valid_request()
        request["application"]["codeowners"] = []
        request["application"]["githubActionReviewers"] = []

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            env_dir = root / "environments"
            env_dir.mkdir()
            rego_path = root / "expected.rego"
            rego_path.write_text('package policies.environments\n\nexpected := {"accounts": []}\n')
            request_path = LoadRequestTests().write_request(directory, request)

            create_account.create_account(
                create_account.load_request(request_path),
                env_dir=str(env_dir),
                rego_path=str(rego_path),
            )
            generated = json.loads((env_dir / "example-service.json").read_text())

        self.assertNotIn("codeowners", generated)
        self.assertNotIn("github_action_reviewer", generated)


class LegacyAccountTests(unittest.TestCase):
    def arguments(self):
        return [
            "example-service",
            "Example service",
            "example-codeowners",
            "example-reviewers",
            "LAA",
            "Example service area",
            "example@justice.gov.uk",
            "Example owner",
            "example-support",
            "false",
            "example-team",
            "",
            '[{"name":"development","access_level":"developer,sandbox"}]',
        ]

    def test_normalises_legacy_team_slugs(self):
        account = create_account.legacy_account(self.arguments())

        self.assertEqual(account["github_owners"], ["example-codeowners"])
        self.assertEqual(account["github_reviewers"], ["example-reviewers"])

    def test_rejects_unsafe_legacy_application_name(self):
        arguments = self.arguments()
        arguments[0] = "../../unsafe"

        with self.assertRaisesRegex(ValueError, "app_name must be"):
            create_account.legacy_account(arguments)


if __name__ == "__main__":
    unittest.main()