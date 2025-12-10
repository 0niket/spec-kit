"""Tests for the Specify CLI."""

import pytest
from pathlib import Path
from unittest.mock import patch, MagicMock

# Import the module under test
from specify_cli import (
    AGENT_CONFIG,
    SCRIPT_TYPE_CHOICES,
    _github_token,
    _github_auth_headers,
    _parse_rate_limit_headers,
    is_git_repo,
    check_tool,
    merge_json_files,
)


class TestAgentConfig:
    """Tests for agent configuration constants."""

    def test_agent_config_has_required_keys(self):
        """Each agent config must have name, folder, install_url, and requires_cli."""
        required_keys = {"name", "folder", "install_url", "requires_cli"}
        for agent_key, config in AGENT_CONFIG.items():
            assert required_keys.issubset(config.keys()), f"Agent '{agent_key}' missing keys: {required_keys - config.keys()}"

    def test_agent_folders_are_hidden(self):
        """Agent folders should start with a dot (hidden directories)."""
        for agent_key, config in AGENT_CONFIG.items():
            folder = config["folder"]
            assert folder.startswith("."), f"Agent '{agent_key}' folder '{folder}' should be a hidden directory"

    def test_cli_agents_have_install_url(self):
        """Agents requiring CLI must have an install URL."""
        for agent_key, config in AGENT_CONFIG.items():
            if config["requires_cli"]:
                assert config["install_url"] is not None, f"CLI agent '{agent_key}' must have install_url"

    def test_known_agents_exist(self):
        """Verify expected agents are configured."""
        expected_agents = ["claude", "copilot", "gemini", "cursor-agent", "codex"]
        for agent in expected_agents:
            assert agent in AGENT_CONFIG, f"Expected agent '{agent}' not found in AGENT_CONFIG"


class TestScriptTypeChoices:
    """Tests for script type configuration."""

    def test_has_sh_and_ps(self):
        """Must support both shell and PowerShell."""
        assert "sh" in SCRIPT_TYPE_CHOICES
        assert "ps" in SCRIPT_TYPE_CHOICES

    def test_only_two_options(self):
        """Only sh and ps should be supported."""
        assert len(SCRIPT_TYPE_CHOICES) == 2


class TestGitHubToken:
    """Tests for GitHub token handling."""

    def test_cli_token_takes_precedence(self):
        """CLI token should override environment variables."""
        with patch.dict("os.environ", {"GH_TOKEN": "env_token"}):
            result = _github_token("cli_token")
            assert result == "cli_token"

    def test_gh_token_env_var(self):
        """GH_TOKEN environment variable should be used."""
        with patch.dict("os.environ", {"GH_TOKEN": "gh_token"}, clear=True):
            # Clear GITHUB_TOKEN to ensure GH_TOKEN is used
            import os
            os.environ.pop("GITHUB_TOKEN", None)
            result = _github_token(None)
            assert result == "gh_token"

    def test_github_token_env_var(self):
        """GITHUB_TOKEN environment variable should be used as fallback."""
        with patch.dict("os.environ", {"GITHUB_TOKEN": "github_token"}, clear=True):
            import os
            os.environ.pop("GH_TOKEN", None)
            result = _github_token(None)
            assert result == "github_token"

    def test_empty_string_returns_none(self):
        """Empty string should return None."""
        result = _github_token("")
        assert result is None

    def test_whitespace_only_returns_none(self):
        """Whitespace-only string should return None."""
        result = _github_token("   ")
        assert result is None


class TestGitHubAuthHeaders:
    """Tests for GitHub auth header generation."""

    def test_returns_bearer_token(self):
        """Should return Bearer token header when token provided."""
        headers = _github_auth_headers("my_token")
        assert headers == {"Authorization": "Bearer my_token"}

    def test_returns_empty_dict_when_no_token(self):
        """Should return empty dict when no token."""
        with patch.dict("os.environ", {}, clear=True):
            import os
            os.environ.pop("GH_TOKEN", None)
            os.environ.pop("GITHUB_TOKEN", None)
            headers = _github_auth_headers(None)
            assert headers == {}


class TestParseRateLimitHeaders:
    """Tests for rate limit header parsing."""

    def test_parses_limit_header(self):
        """Should parse X-RateLimit-Limit header."""
        import httpx
        headers = httpx.Headers({"X-RateLimit-Limit": "5000"})
        result = _parse_rate_limit_headers(headers)
        assert result["limit"] == "5000"

    def test_parses_remaining_header(self):
        """Should parse X-RateLimit-Remaining header."""
        import httpx
        headers = httpx.Headers({"X-RateLimit-Remaining": "4999"})
        result = _parse_rate_limit_headers(headers)
        assert result["remaining"] == "4999"

    def test_returns_empty_dict_for_no_headers(self):
        """Should return empty dict when no rate limit headers."""
        import httpx
        headers = httpx.Headers({})
        result = _parse_rate_limit_headers(headers)
        assert result == {}


class TestIsGitRepo:
    """Tests for git repository detection."""

    def test_returns_false_for_nonexistent_path(self, tmp_path):
        """Should return False for non-existent path."""
        fake_path = tmp_path / "nonexistent"
        result = is_git_repo(fake_path)
        assert result is False

    def test_returns_false_for_non_git_directory(self, tmp_path):
        """Should return False for directory without .git."""
        result = is_git_repo(tmp_path)
        assert result is False

    def test_returns_true_for_git_repo(self, tmp_path):
        """Should return True for initialized git repository."""
        import subprocess
        subprocess.run(["git", "init"], cwd=tmp_path, capture_output=True)
        result = is_git_repo(tmp_path)
        assert result is True


class TestCheckTool:
    """Tests for tool availability checking."""

    def test_returns_true_for_existing_tool(self):
        """Should return True for tools that exist (like python)."""
        # 'python' or 'python3' should exist in any environment running these tests
        result = check_tool("python") or check_tool("python3")
        assert result is True

    def test_returns_false_for_nonexistent_tool(self):
        """Should return False for tools that don't exist."""
        result = check_tool("nonexistent_tool_xyz_12345")
        assert result is False


class TestMergeJsonFiles:
    """Tests for JSON file merging."""

    def test_merge_adds_new_keys(self, tmp_path):
        """Should add new keys from update dict."""
        existing_file = tmp_path / "existing.json"
        existing_file.write_text('{"key1": "value1"}')

        new_content = {"key2": "value2"}
        result = merge_json_files(existing_file, new_content)

        assert result == {"key1": "value1", "key2": "value2"}

    def test_merge_overwrites_existing_keys(self, tmp_path):
        """Should overwrite existing keys with new values."""
        existing_file = tmp_path / "existing.json"
        existing_file.write_text('{"key1": "old_value"}')

        new_content = {"key1": "new_value"}
        result = merge_json_files(existing_file, new_content)

        assert result == {"key1": "new_value"}

    def test_merge_deep_merges_nested_dicts(self, tmp_path):
        """Should deep merge nested dictionaries."""
        existing_file = tmp_path / "existing.json"
        existing_file.write_text('{"outer": {"inner1": "value1"}}')

        new_content = {"outer": {"inner2": "value2"}}
        result = merge_json_files(existing_file, new_content)

        assert result == {"outer": {"inner1": "value1", "inner2": "value2"}}

    def test_returns_new_content_for_missing_file(self, tmp_path):
        """Should return new content if file doesn't exist."""
        missing_file = tmp_path / "missing.json"
        new_content = {"key": "value"}
        result = merge_json_files(missing_file, new_content)
        assert result == new_content

    def test_returns_new_content_for_invalid_json(self, tmp_path):
        """Should return new content if existing file has invalid JSON."""
        invalid_file = tmp_path / "invalid.json"
        invalid_file.write_text("not valid json {{{")

        new_content = {"key": "value"}
        result = merge_json_files(invalid_file, new_content)
        assert result == new_content


class TestStepTracker:
    """Tests for the StepTracker progress display class."""

    def test_add_step(self):
        """Should add steps to the tracker."""
        from specify_cli import StepTracker
        tracker = StepTracker("Test")
        tracker.add("step1", "First Step")

        assert len(tracker.steps) == 1
        assert tracker.steps[0]["key"] == "step1"
        assert tracker.steps[0]["label"] == "First Step"
        assert tracker.steps[0]["status"] == "pending"

    def test_complete_step(self):
        """Should mark step as complete."""
        from specify_cli import StepTracker
        tracker = StepTracker("Test")
        tracker.add("step1", "First Step")
        tracker.complete("step1", "done!")

        assert tracker.steps[0]["status"] == "done"
        assert tracker.steps[0]["detail"] == "done!"

    def test_error_step(self):
        """Should mark step as error."""
        from specify_cli import StepTracker
        tracker = StepTracker("Test")
        tracker.add("step1", "First Step")
        tracker.error("step1", "failed!")

        assert tracker.steps[0]["status"] == "error"
        assert tracker.steps[0]["detail"] == "failed!"

    def test_skip_step(self):
        """Should mark step as skipped."""
        from specify_cli import StepTracker
        tracker = StepTracker("Test")
        tracker.add("step1", "First Step")
        tracker.skip("step1", "not needed")

        assert tracker.steps[0]["status"] == "skipped"

    def test_render_returns_tree(self):
        """Should return a Rich Tree object."""
        from specify_cli import StepTracker
        from rich.tree import Tree
        tracker = StepTracker("Test")
        tracker.add("step1", "First Step")

        result = tracker.render()
        assert isinstance(result, Tree)
