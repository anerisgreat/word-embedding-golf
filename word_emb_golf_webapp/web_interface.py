#!/usr/bin/env python

from flask import Flask
import os
from word_emb_golf_graph.graph import load_graph
app = Flask(__name__)

@app.route('/')
def hello_world():
    g = load_graph(os.environ['WORD_EMB_GOLF_GRAPH_DATA_FILE'])
    return list(g.nodes.keys())

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
