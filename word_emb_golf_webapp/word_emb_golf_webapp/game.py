import numpy
import os

from functools import lru_cache
from word_emb_golf_graph.graph import load_graph

@lru_cache(maxsize=1)
def get_word_emb_golf_graph():
    return load_graph(os.environ['GRAPH_DATA'])

def useGraph(f):
    def _partial(*args, **kwargs):
        kwargs['g'] = get_word_emb_golf_graph()
        return f(*args, **kwargs)
    return _partial

@useGraph
def get_word_neighbors(word, g):
    return list(g.neighbors(word))


