#!/usr/bin/python3
import git
import os
import json

def createNewApp(appInfo):
  with open('./config.json', 'w') as fp:
    json.dump(appInfo, fp)

  targetBranch, tag = None, None
  projectPath = appInfo["projectPath"]
  code = appInfo["code"]
  tagName = appInfo["tag"]

  repo = git.Repo.init(path=projectPath)
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
  pass