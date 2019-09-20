from flask import Flask, escape, request, abort, redirect, url_for, \
  render_template, send_from_directory, Response, make_response
from werkzeug import secure_filename
import json
import os
import projectEdit
import utils

ALLOW_EXTENSIONS = set(['png', 'jpg'])

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = os.path.join(app.root_path, 'static/uploads')
app.config['MAX_CONTENT_PATH'] = 10 * 1024 * 1024

def allowed_file(filename):
  return '.' in filename and filename.rsplit('.', 1)[1] in ALLOW_EXTENSIONS

def projectPath(platform):
  if platform == 'butler':
    return '/Users/remain/Desktop/script-work/ButlerForFusion'
  else:
    return ''

@app.route('/configInfo/<platform>', methods=['GET', 'POST'])
def show(platform):
  return  make_response('data', 200)

@app.route('/updateConfig/<platform>', methods=['GET', 'POST'])
def updateConfig(platform):
  if platform == 'butler':
    data = request.get_json()
    data["projectPath"] = projectPath(platform)
    projectEdit.createNewApp(data)
    return make_response('success', 200)
  else:
    return 'feature unavailable'

@app.route('/newApp/<platform>', methods=['POST'])
def newApplication(platform):
  if platform == 'butler':
    data = request.get_json()
    data['projectPath'] = projectPath(platform)
    data = utils.redirectRemotePath(data)
    print(data)
    projectEdit.createNewApp(data)
    return 'success'
  else:
    return 'feature unavailable'
  
@app.route('/upload', methods=['POST', 'GET'])
def upload_file():
  images = request.files.getlist('image')
  for image in images:
    filename = secure_filename(image.filename)
    if not allowed_file(filename):
      return make_response('图片格式错误', 502)
  
  result = []
  for image in images:
    filename = secure_filename(image.filename)
    image.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    url = os.path.join('http://localhost:5000/static/uploads', filename)
    result.append(url)

  return Response(json.dumps(result), 200)

@app.route('/uploaded/<filename>', methods=['GET', 'POST'])
def uploaded_file(filename):
  return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/index', methods=['GET', 'POST'])
def index():
  return render_template('newApp.html')

# if __name__ == "__main__":
#     app.run(debug=True)