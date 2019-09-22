def allowed_file(filename):
  ALLOW_EXTENSIONS = set(['png', 'jpg'])
  return '.' in filename and filename.rsplit('.', 1)[1] in ALLOW_EXTENSIONS

def projectPath(platform):
  if platform == 'butler':
    # return '/Users/remain/Desktop/script-work/ButlerForFusion'
    return '/Users/mashiro_jin/Desktop/LMWork/ButlerForFusion'
  else:
    return ''

def redirectRemotePath(obj):
  if isinstance(obj, (list)):
    result = []
    for value in obj:
      result.append(redirectRemotePath(value))
    return result
  elif isinstance(obj, (dict)):
    result = {}
    for key in obj:
      result[key] = redirectRemotePath(obj[key])
    return result
  elif isinstance(obj, (str)):
    return obj.replace('http://localhost:5000', '/Users/remain/Desktop/flaskService')
  else:
    return obj
      
