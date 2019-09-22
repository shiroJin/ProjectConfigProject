import git
import os
import json
from . import utils
from flask import current_app

def createNewApp(appInfo):
  with open('./config.json', 'w') as fp:
    json.dump(appInfo, fp)

  targetBranch, tag = None, None
  code = appInfo["code"]
  tagName = appInfo["tag"]

  repo = git.Repo.init(path=appInfo["projectPath"])
  for branch in repo.branches:
    if branch.name.find(code) != -1:
      targetBranch = branch
      break
  if targetBranch:
    raise('branch already existed')

  for t in repo.tags:
    if t.name == tagName:
      tag = t
      break
  if not tag:
    raise('can not find tag')

  targetBranch = repo.create_head("proj-%s-snapshot" % (code.lower()), tag.commit)
  if repo.head.name != targetBranch.name:
    targetBranch.checkout()

  # 清理工程
  os.chdir('/Users/remain/Desktop/script-work/ButlerForFusion')
  os.system('pwd')
  os.system('git stash')
  os.system('rm -rf ./Butler/ButlerForScript')
  os.chdir('/Users/remain/Desktop/flaskService')

  cmd = 'ruby feature/projectRun.rb new ./config.json'
  result = os.system(cmd)
  if result == 0:
    exit(0)
  else:
    exit(1)

def editApp(appInfo):
  with open('./update.json') as fp:
    json.dump(appInfo, fp)
  
  repo = git.Repo.init(path=appInfo["projectPath"])
  repo.remote.pull()

  branch = None
  for head in repo.branches:
    if head.find("proj-%s-snap" % appInfo["code"].lower()) != -1:
      branch = head
      break
  
  if repo.head != branch:
    branch.checkout()
  
  cmd = 'ruby feature/projectRun.rb edit ./update.json'
  return os.system(cmd)

def fetchAppInfo(platform, code):
  # repo = git.Repo.init(path=utils.projectPath(platform))
  # repo.remote.pull()
  # # 分支处理
  # branch = None
  # for head in repo.branches:
  #   if head.find("proj-%s-snap" % appInfo["code"].lower()) != -1:
  #     branch = head
  #     break
  # if repo.head != branch:
  #   branch.checkout()
  
  cmd = "ruby %s/feature/projectRun.rb info info.json" % current_app.root_path
  if os.system(cmd) == 0:
    with open('appInfo.json', 'r') as fp:
      return json.load(fp)
