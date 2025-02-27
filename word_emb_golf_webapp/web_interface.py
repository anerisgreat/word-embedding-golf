#!/usr/bin/env python

from flask import Flask
import os
import json

from word_emb_golf_webapp import game

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
        return str(game.get_word_neighbors('hello'))

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(host="0.00.0", port=8080)
