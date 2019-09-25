from flask import Blueprint, send_from_directory, make_response, request, current_app
from werkzeug import secure_filename
from . import utils
import os
import json

bp = Blueprint('image', __name__, url_prefix='/image')

@bp.route('/upload', methods=['POST', 'GET'])
def upload():
  images = request.files.getlist('image')
  for image in images:
    filename = secure_filename(image.filename)
    if not utils.allowed_file(filename):
      return make_response('图片格式错误', 502)
  
  result = []
  for image in images:
    filename = secure_filename(image.filename)
    image.save(os.path.join(current_app.config['UPLOAD_FOLDER'], filename))
    url = os.path.join('http://localhost:5000/image', filename)
    result.append(url)

  return make_response(json.dumps(result), 200)

@bp.route('/<filename>', methods=('GET', 'POST'))
def uploaded_image(filename):
  return send_from_directory(current_app.config['UPLOAD_FOLDER'], filename)
