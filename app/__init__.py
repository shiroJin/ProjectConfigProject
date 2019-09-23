import os
from flask import Flask, Blueprint
from flask_cors import *

app = Flask(__name__, instance_relative_config = True)
app.config.from_mapping(
  UPLOAD_FOLDER = os.path.join(app.root_path, 'uploads'),
  MAX_CONTENT_LENGTH = 10 * 1024 * 1024
)
CORS(app, supports_credentials=True)

from . import image, project
app.register_blueprint(image.bp)
app.register_blueprint(project.bp)
