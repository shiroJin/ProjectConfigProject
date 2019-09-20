#!/usr/local/bin/python3
import os
import json
import git

with open('./config.json') as fp:
    appConfig = json.load(fp)

projectPath = appConfig["projectPath"]
code = appConfig["code"]

shouldCreateTarget, targetBranch, tag = False, None, None

repo = git.Repo.init(path=projectPath)
for branch in repo.branches:
  if branch.name.find(code) != -1:
    targetBranch = branch

if not targetBranch:
  shouldCreateTarget = True

  tagName = appConfig["tag"]
  for t in repo.tags:
    if t.name == tagName:
      tag = t
  if not tag:
    print('can not find tag')
    exit(1)

  targetBranch = repo.create_head("proj-%s-snapshot" % (code.lower()), tag.commit)

if repo.head.name != targetBranch.name:
  targetBranch.checkout()

os.chdir('/Users/remain/Desktop/script-work/ButlerForFusion')
os.system('pwd')
os.system('git stash')
os.system('rm -rf ./Butler/ButlerForScript')
os.chdir('/Users/remain/Desktop/flaskService')

result = None
if not shouldCreateTarget:
  cmd = 'ruby feature/projectRun.rb new ./config.json'
  result = os.system(cmd)
else:
  cmd = 'ruby feature/projectRun.rb new ./config.json'
  result = os.system(cmd)
  
if result == 0:
  exit(0)
else:
  exit(1)