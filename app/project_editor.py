import git
import os
import json
from . import utils
from flask import current_app
from . import git_helper

def create_new_app(appInfo):
  with open('./config.json', 'w') as fp:
    json.dump(appInfo, fp)

  # tagName = appInfo["tag"]
  # branchName = "proj-%s-snapshot" % appInfo["kCompanyCode"]
  # repo = git.Repo.init(path=appInfo["projectPath"])
  # git_helper.checkout_branch(repo, branchName, create=True, tag_name=tagName)

  cmd = 'ruby %s/feature/projectRun.rb new ./config.json' % current_app.root_path
  return os.system(cmd)

def edit_app(platform, update_info):
  app = utils.app_instance(update_info["companyCode"])
  update_info["projectPath"] = utils.project_path(platform)
  update_info["targetName"] = app["targetName"]
  update_info["privateGroup"] = app["privateGroup"]
  utils.dump_json('./update.json', update_info)
  # repo = git.Repo.init(path=utils.projectPath(platform))
  # repo.remote.pull()
  # git_helper.checkout_branch(repo, appInfo["branchName"])
  ruby_path = os.path.join(current_app.root_path, "feature/projectRun.rb")
  cmd = 'ruby %s edit ./update.json' % ruby_path
  return os.system(cmd)

def fetch_app_info(platform, company_code):
  repo = git.Repo.init(path=utils.project_path(platform))
  # repo.remote().pull()
  # git_helper.checkout_branch(repo, branch_name)
  
  app = utils.app_instance(company_code)
  info = {
    "privateGroup" : app["privateGroup"],
    "projectPath" : utils.project_path(platform),
    "targetName" : app["targetName"]
  }
  
  utils.dump_json('app/temporary/info.json', info)
  ruby_path = os.path.join(current_app.root_path, "feature/projectRun.rb")
  cmd = "ruby %s info app/temporary/info.json" % ruby_path
  if os.system(cmd) == 0:
    return utils.load_json('appInfo.json')
  else:
    raise("read failure")
    