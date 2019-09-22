from flask import request, url_for, render_template, make_response, Blueprint
from . import projectEdit, utils
import json
import os

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
  info = projectEdit.fetchAppInfo(platform, 'remain')
  return render_template("app-info.html", appInfo=info)
