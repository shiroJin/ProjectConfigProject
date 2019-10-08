import git
import os
import json
import shutil
from . import utils
from flask import current_app
from . import git_helper

def create_new_app(appInfo):
  utils.dump_json('./config.json', appInfo)

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
  utils.dump_json('app/temp/info.json', info)

  ruby_path = os.path.join(current_app.root_path, "feature/projectRun.rb")
  cmd = "ruby %s info app/temp/info.json" % ruby_path

  if os.system(cmd) == 0:
    info = utils.load_json('appInfo.json')
    images, result = info['images'], {}
    for (name, path) in images.items():
      # dest_name = "%s-%s.png" % (name, utils.short_uuid())
      dest_name = name
      dest = os.path.join(current_app.config['UPLOAD_FOLDER'], dest_name)
      shutil.copyfile(path, dest)
      result[name] = os.path.join(utils.image_host, dest_name)
    info['images'] = result
    return info
  else:
    raise("read failure")
    