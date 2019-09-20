from flask import Flask, escape, request, abort, redirect, url_for, \
  render_template, send_from_directory, Response, make_response
from werkzeug import secure_filename
import json
import os

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
  with open('/Users/remain/Desktop/projectConfigProject/Sources/update.json', 'r') as fp:
    data = json.load(fp)
  return  make_response(data, 200)

@app.route('/updateConfig/<platform>', methods=['GET', 'POST'])
def updateConfig(platform):
  if platform == 'butler':
    print('update butler config')
    data = request.get_json()
    data["projectPath"] = projectPath(platform)
    with open('./update.json', 'w') as fp:
      json.dump(data, fp)
    cmd = "python3 feature/script.py"
    result = os.system(cmd)
    if result == 0:
      return make_response('success', 200)
    else:
      return make_response('failure', 503)
    
  elif platform == 'Community':
    return 'feature unavailable'

  elif platform == 'Buisness':
    return 'feature unavailable'

@app.route('/newApp/<platform>', methods=['POST'])
def newApplication(platform):
  if platform == 'butler':
    data = request.get_json()
    data['projectPath'] = projectPath(platform)
    icons = data['icons']
    launchs = data['launchs']

    redirect = []
    for icon in icons:
      path = icon.replace('http://localhost:5000', '/Users/remain/Desktop/flaskService')
      redirect.append(path)
    data['icons'] = redirect

    redirect = []
    for icon in launchs:
      path = icon.replace('http://localhost:5000', '/Users/remain/Desktop/flaskService')
      redirect.append(path)
    data['launchs'] = redirect

    # 写入文件
    with open('./config.json', 'w') as fp:
      json.dump(data, fp)
    # 执行指令
    cmd = "python3 feature/script.py"
    result = os.system(cmd)
    if result == 0:
      return 'success'
    else:
      return 'failure'
  
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