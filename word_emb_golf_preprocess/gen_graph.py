import numpy as np
import os
from word_emb_golf_graph import *
import argparse
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.manifold import TSNE
from sklearn.preprocessing import QuantileTransformer, MinMaxScaler
import heapq
import random
import networkx as nx
#https://www.kaggle.com/code/floser/examples-of-similar-word-embeddings-in-glove

#Want file like "glove.6B.50d.txt"
def _get_embedding_dict(data_path, common_words_fpath):
    with open(common_words_fpath, 'r', encoding = "utf-8") as f:
        useable_words = set([l.strip().lower() for l in f])
    # Uncomment this to develop - short list means short time
    # useable_words = set(list(useable_words)[:100])
    with open(data_path, 'r', encoding="utf-8") as f:
        values = (line.split() for line in f)
        keys_values = ((v[0], np.asarray(v[1:], "float32")) for v in values if v[0] in useable_words)
        return dict(keys_values)

def import_embedding_dict():
    embedding_fpath = os.environ['GLOVE_DATA']
    common_words_fpath = os.environ['COMMON_WORD_DATA']
    return _get_embedding_dict(embedding_fpath, common_words_fpath)

def _local_cosine_similarity(a, b):
    return cosine_similarity(a.reshape(1,-1), b.reshape(1,-1))

def _get_closest_n_words(word_index, word_list, np_emb_arr, dists, n_neighbors = 20):
    indeces = heapq.nlargest(
        n = n_neighbors,
        iterable = filter(
            lambda i: not i == word_index, range(np_emb_arr.shape[0])),
        key = lambda i:  -dists[word_index,i])
    return [word_list[i] for i in indeces]

def _gen_nx_graph(word_list, np_emb_arr, dists, n_neighbors = 20):
    g = nx.DiGraph()
    for w in word_list:
        g.add_node(w)

    for i, w in enumerate(word_list):
        g.add_edges_from([(w, n) \
                          for n in _get_closest_n_words(
                                  i, word_list, np_emb_arr, dists, n_neighbors)])
    return g

_get_unusable = lambda g: [k for k in g.nodes \
                           if not nx.has_path(g, 'the', k)]

_subset_indeces = lambda a, b: [i for i, v in enumerate(a) if v in b]

_remove_indeces_from_list = lambda l, i: [v for j, v in enumerate(l) \
                                          if not j in i]

def _iterative_gen_usable_graph(word_list, np_emb_arr, dists, n_neighbors = 20):
    g = _gen_nx_graph(word_list, np_emb_arr, dists, n_neighbors)
    unusable = _get_unusable(g)
    while(len(unusable) > 0):
        unusable_indeces = _subset_indeces(word_list, unusable)
        word_list = _remove_indeces_from_list(word_list, unusable_indeces)
        np_emb_arr = np.delete(np_emb_arr, unusable_indeces, axis = 0)
        #Delete columns and rows in dists
        dists = np.delete(dists, unusable_indeces, axis = 0)
        dists = np.delete(dists, unusable_indeces, axis = 1)

        #Regenerate
        g = _gen_nx_graph(word_list, np_emb_arr, dists, n_neighbors)
        unusable = _get_unusable(g)

    return g, word_list, np_emb_arr, dists
def gen_graph(n_neighbors = 20):
    d = import_embedding_dict()

    word_arr = list(d.keys())
    np_emb_arr = np.stack([d[k] for k in word_arr])
    #Due to floating point errors, we do maximum with 0.
    dists = np.maximum(1 - cosine_similarity(np_emb_arr), 0)

    #Update only usable words
    gt, word_lists_t, np_emb_arr_t, dists_t = \
        _iterative_gen_usable_graph(word_arr, np_emb_arr, dists, n_neighbors)

    #Now TSNE for display
    tsne_model = TSNE(metric = 'precomputed', n_jobs = -1,
                      init = 'random')
    np_emb_arr_tsne = tsne_model.fit_transform(dists_t)
    np_emb_arr_tsne_scaled = MinMaxScaler().fit_transform(np_emb_arr_tsne)


    return dict((k, WordEmbEntry(
            neighbors = list(gt.successors(k)),
            emb = d[k].tolist(),
            tsne_emb = np_emb_arr_tsne_scaled[i].tolist()))
                 for i, k in enumerate(word_lists_t))

if __name__ == '__main__':
    #I want the same exact graph and TSNE each time
    #This way it will be consistent
    random.seed(42)
    g = gen_graph()
    parser = argparse.ArgumentParser()
    parser.add_argument("output")
    args = parser.parse_args()
    save_graph_gzip(g, args.output)

