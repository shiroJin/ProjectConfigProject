import os

from flask import Flask, Blueprint

app = Flask(__name__, instance_relative_config = True)
app.config.from_mapping(
  UPLOAD_FOLDER = os.path.join(app.root_path, 'uploads'),
  MAX_CONTENT_LENGTH = 10 * 1024 * 1024
)

from . import image
app.register_blueprint(image.bp)

from . import project
app.register_blueprint(project.bp)
