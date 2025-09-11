import yaml
import os
from .files import get_base_dir

def pre_commit_diff(file_path: str) -> str:
    """
    Compares the default hooked .pre-commit-config.yaml with the one at the given file path
    and returns a unified list of ids that are found in both files as string list, seperated by commas.

    Args:
        file_path (str): The path to the .pre-commit-config.yaml file to compare.
    """

    hooked_base_dir = get_base_dir()
    hooked_pre_commit_config = os.path.join(hooked_base_dir, 'config', '.pre-commit-config.yaml')
    hooked_pre_commit = yaml.safe_load(hooked_pre_commit_config)

    repo_pre_commit_config = os.path.join(file_path, '.pre-commit-config.yaml')
    repo_pre_commit = yaml.safe_load(repo_pre_commit_config)

    hooked_ids = set()
    repo_ids = set()

    for repo in hooked_pre_commit.get('repos', []):
        hooked_ids.update({hook.get('id') for hook in repo.get('hooks', [])})

    for repo in repo_pre_commit.get('repos', []):
        repo_ids.update({hook.get('id') for hook in repo.get('hooks', [])})

    common_ids = hooked_ids.intersection(repo_ids)

    return ','.join(common_ids)
