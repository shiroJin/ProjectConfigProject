from flask import request, url_for, render_template, make_response,\
   Blueprint, current_app
from . import projectEdit, utils
import json
import os
import shutil

bp = Blueprint('project', __name__, url_prefix='/project')

@bp.route('/updateConfig/<platform>', methods=['GET', 'POST'])
def updateConfig(platform):
  if platform == 'butler':
    data = request.get_json()
    data["projectPath"] = utils.projectPath(platform)
    projectEdit.createNewApp(data)
    return make_response('success', 200)
  else:
    return make_response('feature unavailable')

@bp.route('/newApp/<platform>', methods=['POST'])
def newApplication(platform):
  if platform == 'butler':
    data = request.get_json()
    data['projectPath'] = projectPath(platform)
    data = utils.redirectRemotePath(data)
    projectEdit.createNewApp(data)
    return make_response('success', 200)
  else:
    return make_response('feature unavailable')

@bp.route('/index', methods=['GET', 'POST'])
def index():
  return render_template('newApp.html')

@bp.route('/appInfo/<platform>', methods=['GET'])
def appInfo(platform):
  company_code = request.args.get('companyCode')
  info = projectEdit.fetchAppInfo(platform, company_code)

  images = info['images']
  result = {}
  for (name, path) in images.items():
    dest_name = "%s-%s.png" % (name, utils.short_uuid())
    dest = os.path.join(current_app.config['UPLOAD_FOLDER'], dest_name)
    shutil.copyfile(path, dest)
    result[name] = os.path.join('http://localhost:5000/image', dest_name)
  info['images'] = result

  return render_template("app-info.html", appInfo=info)

@bp.route('/projectInfo/<platform>', methods=['GET'])
def projectInfo(platform):
  project_list = projectEdit.fetchProjectInfo(platform)
  return render_template('project-info.html', branches=project_list)
