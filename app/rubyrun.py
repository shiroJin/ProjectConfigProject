from flask import current_app
from . import utils
import os

def msg_path():
  return current_app.root_path + '/temp/prmsg.json'

def new_app(app_info):
  utils.dump_json(msg_path(), app_info)
  ruby_path = current_app.root_path + "/feature/projectRun.rb"
  cmd = 'ruby %s new %s' % (ruby_path, msg_path())
  return os.system(cmd)

def edit_app(update_info):
  utils.dump_json(msg_path(), update_info)
  ruby_path = current_app.root_path + "/feature/projectRun.rb"
  cmd = 'ruby %s edit %s' % (ruby_path, msg_path())
  return os.system(cmd)

def fetch_app_info(app):
  utils.dump_json(msg_path(), app)
  ruby_path = os.path.join(current_app.root_path, "feature/projectRun.rb")
  cmd = "ruby %s info %s" % (ruby_path, msg_path())
  if os.system(cmd) == 0:
    return utils.load_json(msg_path())
  else:
    raise 'fetch app info failure'

  