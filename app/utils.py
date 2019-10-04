from uuid import uuid4
from flask import current_app
import json
import os

image_host = "http://localhost:5000/image"
ALLOW_EXTENSIONS = set(['png', 'jpg'])
uuidChars = ("a", "b", "c", "d", "e", "f",
       "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s",
       "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5",
       "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I",
       "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
       "W", "X", "Y", "Z")

def short_uuid():
  uuid = str(uuid4()).replace('-', '')
  result = ''
  for i in range(0,8):
    sub = uuid[i * 4: i * 4 + 4]
    x = int(sub,16)
    result += uuidChars[x % 0x3E]
  return result

def allowed_file(filename):
  return '.' in filename and filename.rsplit('.', 1)[1] in ALLOW_EXTENSIONS

def project_path(platform):
  if platform == 'butler':
    # return '/Users/remain/Desktop/script-work/ButlerForFusion'
    return '/Users/mashiro_jin/Desktop/LMWork/ButlerForFusion'
  else:
    return ''

def redirect_remote_path(obj):
  if isinstance(obj, (list)):
    result = []
    for value in obj:
      result.append(redirect_remote_path(value))
    return result
  elif isinstance(obj, (dict)):
    result = {}
    for key in obj:
      result[key] = redirect_remote_path(obj[key])
    return result
  elif isinstance(obj, (str)):
    return obj.replace(image_host, current_app.config["UPLOAD_FOLDER"])
  else:
    return obj

def load_json(file_path):
  with open(file_path, 'r') as fp:
    return json.load(fp)
  raise 'json load err' + file_path

def dump_json(file_path, content):
  with open(file_path, 'w') as fp:
    json.dump(content, fp)

def app_instance(company_code):
  app = None
  app_list = load_json(os.path.join(current_app.root_path, 'static/app.json'))
  for obj in app_list:
    if obj["code"] == company_code:
      app = obj
      break
  if not app:
    raise 'no match app'
  return app