import numpy as np
import os
from scipy import spatial
#https://www.kaggle.com/code/floser/examples-of-similar-word-embeddings-in-glove

#Want file like "glove.6B.50d.txt"
def _get_embedding_dict(data_path, common_words_fpath):
    with open(common_words_fpath, 'r', encoding = "utf-8") as f:
        usable_words = set([l.strip().lower() for l in f])
    with open(data_path, 'r', encoding="utf-8") as f:
        values = (line.split() for line in f)
        keys_values = ((v[0], np.asarray(v[1:], "float32")) for v in values if v[0] in usable_words)
        return dict(keys_values)

def import_embedding_dict():
    embedding_fpath = os.environ['GLOVE_DATA']
    common_words_fpath = os.environ['COMMON_WORD_DATA']
    return _get_embedding_dict(embedding_fpath, common_words_fpath)

def find_closest_embeddings(embeddings_dict, embedding):
    return sorted(embeddings_dict.keys(),
                  key=lambda word: \
                    spatial.distance.euclidean(embeddings_dict[word],
                                               embedding))

def find_closest_n_words(embeddings_dict, word, n):
    emb = embeddings_dict[word]
    return find_closest_embeddings(embeddings_dict, emb)[:n]

def _cosine_similarity(a, b):
    return np.dot(a, b)/(np.linalg.norm(a)*np.linalg.norm(b))

def find_closest_cosine_embeddings(embeddings_dict, embedding):
    return sorted(embeddings_dict.keys(),
                  key=lambda word: \
                    -_cosine_similarity(embeddings_dict[word],
                                               embedding))

def find_closest_cosine_n_words(embeddings_dict, word, n):
    emb = embeddings_dict[word]
    return find_closest_cosine_embeddings(embeddings_dict, emb)[:n]
