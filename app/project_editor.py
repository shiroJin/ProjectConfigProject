import git
import os
import json
import shutil
from flask import current_app
from . import githelper, utils, rubyrun

def create_new_app(app_info):
  tag_name = app_info["tag"]
  branch_name = "proj-%s-snapshot" % app_info["kCompanyCode"]
  repo = git.Repo.init(path=app_info["projectPath"])
  # repo.remote().pull()
  githelper.create_new_branch(repo, branch_name, tag_name)
  rubyrun.new_app(app_info)
  repo.git.add('.')
  status_result = repo.git.status()
  app = {
    "displayName" : app_info["CFBundleDisplayName"],
    "code" : app_info["kCompanyCode"],
    "targetName" : 'ButlerFor%s' % app_info["kCompanyCode"].capitalize(),
    "branchName" : branch_name,
    "privateGroup" : "ButlerFor%s" % app_info["kCompanyCode"].capitalize()
  }
  return {
    'status': status_result,
    'app': app
  }

def edit_app(platform, update_info):
  app = utils.app_instance(update_info["companyCode"])
  update_info["projectPath"] = utils.project_path(platform)
  update_info["targetName"] = app["targetName"]
  update_info["privateGroup"] = app["privateGroup"]

  repo = git.Repo.init(path=utils.project_path(platform))
  # repo.remote().pull()
  githelper.checkout_branch_if_needed(repo, app["branchName"])

  rubyrun.edit_app(update_info)
  return repo.git.diff("--stat")

def fetch_app_info(platform, company_code):
  app = utils.app_instance(company_code)
  app["projectPath"] = utils.project_path(platform)

  repo = git.Repo.init(path=utils.project_path(platform))
  # repo.remote().pull()
  githelper.checkout_branch_if_needed(repo, app["branchName"])

  app_info = rubyrun.fetch_app_info(app)
  images, result = app_info['images'], {}
  for (name, path) in images.items():
    # dest_name = "%s-%s.png" % (name, utils.short_uuid())
    dest_name = name
    dest = os.path.join(current_app.config['UPLOAD_FOLDER'], dest_name)
    shutil.copyfile(path, dest)
    result[name] = os.path.join(utils.image_host, dest_name)
  app_info['images'] = result
  return app_info
    