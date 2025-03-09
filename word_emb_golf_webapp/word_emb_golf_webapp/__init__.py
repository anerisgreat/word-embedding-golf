from flask import Flask, render_template
import os
import json

from word_emb_golf_graph import load_graph_as_gzip_base64

def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        # SECRET_KEY='dev',
        # DATABASE=os.path.join(app.instance_path, 'flaskr.sqlite'),
    )

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    # a simple page that says hello
    @app.route('/hello')
    def hello():
        return str(get_word_neighbors('hello'))

    @app.route('/')
    def index():
        return render_template(
            'index.html',
            graph_gzip_base64 = load_graph_as_gzip_base64(os.environ['GRAPH_DATA']))

    return app

