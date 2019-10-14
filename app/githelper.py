import git
from . import utils

def checkout_branch_if_needed(repo, branch_name):
  cur_name = repo.head.ref.name
  if cur_name == branch_name:
    return

  for ref in repo.branches:
    if ref.name == branch_name:
      ref.checkout()
      return

  for ref in repo.remote().refs:
    if ref.remote_head == branch_name:
      repo.git().checkout(ref, b=ref.remote_head)
      return
  
  raise('no matched branch')

def create_new_branch(repo, branch_name, tag_name):
  for ref in repo.branches:
    if ref.name == branch_name:
      raise 'branch already exist'

  for ref in repo.remote().refs:
    if ref.remote_head == branch_name:
      raise 'branch already exist'
  
  tag = None
  for obj in repo.tags:
    if obj.name == tag_name:
      tag = obj
  if not tag:
    raise 'no matched tag'

  head = repo.create_head(branch_name, tag.commit)
  # head = repo.create_head(branch_name, 'd494e9c1f0fd7621f33e2fda97f23c64e2377a40')
  head.checkout()

def commit_changes(app, platform):
  repo = git.Repo.init(path=utils.project_path(platform))
  _git = repo.git()
  _git.commit('-m script commit')
  _git.push('--set-upstream', 'origin', app["branchName"])
  return 'ok'
