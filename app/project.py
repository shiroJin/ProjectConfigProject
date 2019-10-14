from flask import request, url_for, render_template, make_response,\
   Blueprint, current_app
from . import project_editor, utils, githelper
import json
import os
import shutil
import git

bp = Blueprint('project', __name__, url_prefix='/project')

@bp.route('/updateApp/<platform>', methods=['POST'])
def update_config(platform):
  update_info = request.get_json()
  update_info = utils.redirect_local_path(update_info)
  result = project_editor.edit_app(platform, update_info)
  return result

@bp.route('/app-form/<platform>', methods=['GET'])
def fetch_app_form(platform):
  if platform == 'butler':
    file_path = os.path.join(current_app.root_path, 'static/butler_form.json')
    with open(file_path) as fp:
      return json.load(fp)
    return 'error'

@bp.route('/newApp/<platform>', methods=['POST'])
def new_app(platform):
  if platform == 'butler':
    data = request.get_json()
    data['projectPath'] = utils.project_path(platform)
    data = utils.redirect_remote_path(data)
    return project_editor.create_new_app(data)
  else:
    return make_response('feature unavailable')

@bp.route('/index', methods=['GET', 'POST'])
def index():
  return render_template('newApp.html')

@bp.route('/appInfo/<platform>', methods=['GET'])
def appInfo(platform):
  company_code = request.args.get('companyCode')
  info = project_editor.fetch_app_info(platform, company_code)
  return info

@bp.route('/projectInfo/<platform>', methods=['GET'])
def projectInfo(platform):
  file_path = os.path.join(current_app.root_path, 'static/app.json')
  with open(file_path) as fp:
    return { "data" : json.load(fp) }

@bp.route('/commitChanges/<platform>', methods=['POST'])
def commit_changes(platform):
  app = request.get_json()
  githelper.commit_changes(app, platform)
  app_list_path = current_app.root_path + '/static/app.json'
  app_list = utils.load_json(app_list_path)
  app_list.append(app)
  utils.dump_json(app_list_path, app_list)
  return "ok"
