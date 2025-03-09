import numpy
import os
import json
from functools import lru_cache

# from word_emb_golf_graph.graph import load_graph

# @lru_cache(maxsize=1)
# def get_word_emb_golf_graph_gzip_base64():
#     return load_graph_as_gzip_base64(os.environ['GRAPH_DATA'])

# def useGraph(f):
#     def _partial(*args, **kwargs):
#         kwargs['g'] = get_word_emb_golf_graph()
#         return f(*args, **kwargs)
#     return _partial

# @useGraph
# def get_word_neighbors(word, g):
#     return list(g.neighbors(word))

# @useGraph
# @lru_cache(maxsize=1)
# def get_graph_as_gzip(g):
#     as_dict = dict((k, get_word_neighbors(k)) for k in g.nodes)
#     return json.dumps(as_dict)

# def get_word_emb_golf_graph_gzip_base64():
#     return load_graph_as_gzip_base64(os.environ['GRAPH_DATA'])

# @lru_cache(maxsize=1)
# def get_graph_as_gzip():
#     return load_graph_as_gzip_base64(os.environ['GRAPH_DATA'])

