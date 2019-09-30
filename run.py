import app
from flask import Flask

if __name__ == "__main__":
  app = app.create_app()
  app.run(debug=True, host='0.0.0.0')