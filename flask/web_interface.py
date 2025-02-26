#!/usr/bin/env python

from flask import Flask
import os
from .preprocess import *
app = Flask(__name__)

@app.route('/')
def hello_world():
    g = load_graph('graph.pickle')
    return list(g.nodes.keys())

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
