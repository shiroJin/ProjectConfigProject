import git
import os
import json
from . import utils
from flask import current_app
from . import git_helper

def create_new_app(appInfo):
  with open('./config.json', 'w') as fp:
    json.dump(appInfo, fp)

  tagName = appInfo["tag"]
  branchName = "proj-%s-snapshot" % appInfo["code"]
  repo = git.Repo.init(path=appInfo["projectPath"])
  git_helper.checkout_branch(repo, branchName, create=True, tag_name=tagName)

  cmd = 'ruby feature/projectRun.rb new ./config.json'
  return os.system(cmd)

def edit_app(appInfo):
  with open('./update.json') as fp:
    json.dump(appInfo, fp)
  platform = ""
  repo = git.Repo.init(path=utils.projectPath(platform))
  repo.remote.pull()
  git_helper.checkout_branch(repo, appInfo["branchName"])
  
  cmd = 'ruby feature/projectRun.rb edit ./update.json'
  return os.system(cmd)

def fetch_app_info(platform, branch_name, target_name, code):
  repo = git.Repo.init(path=utils.projectPath(platform))
  repo.remote().pull()
  git_helper.checkout_branch(repo, branch_name)
  
  info["code"] = code
  info["projectPath"] = utils.projectPath(platform)
  info["targetName"] = target_name
  with open('app/temporary/info.json', 'w') as fp:
    json.dump(info, fp)

  ruby_path = os.path.join(current_app.root_path, "feature/projectRun.rb")
  cmd = "ruby %s info app/temporary/info.json" % ruby_path
  if os.system(cmd) == 0:
    with open('appInfo.json', 'r') as fp:
      return json.load(fp)
  else:
    raise("read failure")

def fetch_project_info(platform):
  repo = git.Repo.init(path=utils.projectPath(platform))
  repo.remote().pull()
  result = []
  for branch in repo.remote().refs:
    if branch.name.find('proj-') != -1:
      result.append(branch.name)
  return result