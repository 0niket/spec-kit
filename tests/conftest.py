"""Pytest configuration and shared fixtures."""

import pytest
import sys
from pathlib import Path

# Add src to path for imports
src_path = Path(__file__).parent.parent / "src"
sys.path.insert(0, str(src_path))


@pytest.fixture
def temp_git_repo(tmp_path):
    """Create a temporary git repository for testing."""
    import subprocess

    repo_path = tmp_path / "test_repo"
    repo_path.mkdir()

    # Initialize git repo
    subprocess.run(["git", "init"], cwd=repo_path, capture_output=True)
    subprocess.run(
        ["git", "config", "user.email", "test@example.com"],
        cwd=repo_path,
        capture_output=True,
    )
    subprocess.run(
        ["git", "config", "user.name", "Test User"],
        cwd=repo_path,
        capture_output=True,
    )

    # Create initial commit
    (repo_path / "README.md").write_text("# Test Repo")
    subprocess.run(["git", "add", "."], cwd=repo_path, capture_output=True)
    subprocess.run(
        ["git", "commit", "-m", "Initial commit"],
        cwd=repo_path,
        capture_output=True,
    )

    return repo_path


@pytest.fixture
def mock_spec_structure(tmp_path):
    """Create a mock Spec Kit directory structure."""
    # Create .specify structure
    specify_dir = tmp_path / ".specify"
    (specify_dir / "scripts" / "bash").mkdir(parents=True)
    (specify_dir / "scripts" / "powershell").mkdir(parents=True)
    (specify_dir / "templates").mkdir(parents=True)
    (specify_dir / "memory").mkdir(parents=True)

    # Create specs directory
    specs_dir = tmp_path / "specs"
    specs_dir.mkdir()

    return tmp_path
