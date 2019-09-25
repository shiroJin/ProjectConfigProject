import app
from flask import Flask

app = app.create_app()
app.run(debug=True)