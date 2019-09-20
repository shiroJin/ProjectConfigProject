#!/usr/bin/python3
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
      
