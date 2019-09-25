from flask import request, url_for, render_template, make_response,\
   Blueprint, current_app
from . import project_editor, utils
import json
import os
import shutil

bp = Blueprint('project', __name__, url_prefix='/project')

@bp.route('/updateConfig/<platform>', methods=['GET', 'POST'])
def updateConfig(platform):
  if platform == 'butler':
    data = request.get_json()
    data["projectPath"] = utils.projectPath(platform)
    project_editor.edit_app(data)
    return make_response('success', 200)
  else:
    return make_response('feature unavailable')

@bp.route('/newApp/<platform>', methods=['POST'])
def newApplication(platform):
  if platform == 'butler':
    data = request.get_json()
    print(data)
    return
    data['projectPath'] = utils.project_path(platform)
    data = utils.redirect_remote_path(data)
    project_editor.create_new_app(data)
    return make_response('success', 200)
  else:
    return make_response('feature unavailable')

@bp.route('/index', methods=['GET', 'POST'])
def index():
  return render_template('newApp.html')

@bp.route('/appInfo/<platform>', methods=['GET'])
def appInfo(platform):
  target_name = request.args.get('targetName')
  branch_name = request.args.get('branchName')
  private_group = request.args.get('privateGroup')
  info = project_editor.fetch_app_info(platform, branch_name, target_name, private_group)

  images = info['images']
  result = {}
  for (name, path) in images.items():
    # dest_name = "%s-%s.png" % (name, utils.short_uuid())
    dest_name = name
    dest = os.path.join(current_app.config['UPLOAD_FOLDER'], dest_name)
    shutil.copyfile(path, dest)
    result[name] = os.path.join('http://localhost:5000/image', dest_name)
  info['images'] = result
  return info

@bp.route('/projectInfo/<platform>', methods=['GET'])
def projectInfo(platform):
  file_path = os.path.join(current_app.root_path, 'static/app.json')
  with open(file_path) as fp:
    return { "data" : json.load(fp) }
