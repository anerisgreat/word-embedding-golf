import networkx as nx
import pickle
import os

from .embeddings import *

def gen_graph(n_neighbors = 20):
    g = nx.DiGraph()

    d = import_embedding_dict()

    for k in d.keys():
        g.add_node(k, emb = d[k])

    for k in d.keys():
        neighbors = find_closest_cosine_n_words(d, k, n_neighbors)
        g.add_edges_from([(k, kn) for kn in neighbors])

    return g

def save_graph(g, fpath):
    with open(fpath, 'wb') as ofile:
        pickle.dump(g, ofile)

def export_graph(g):
    save_graph(g, os.environ['GRAPH_DATA'])

def load_graph(fpath):
    with open(fpath, 'rb') as ifile:
        return pickle.load(ifile)

def import_graph():
    return load_graph(os.environ['GRAPH_DATA'])
