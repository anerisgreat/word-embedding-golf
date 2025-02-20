import random

from .embeddings import *

def _cosine_similarity(a, b):
    return np.dot(a, b)/(np.linalg.norm(a)*np.linalg.norm(b))

class WordToVecGame():
    def __init__(self, n_neighbors = 20):
        self._d = import_embedding_dict()
        self._n_neighbors = n_neighbors
    def _get_dist_to_word(self, k):
        return np.linalg.norm(self._d[k] - self._d[self._dest_word])
    def _get_similarity_to_word(self, k):
        return _cosine_similarity(self._d[k], self._d[self._dest_word])
    def _update_dist(self):
        self._dist = self._get_dist_to_word(self._current_word)
        self._similarity = self._get_similarity_to_word(self._current_word)
    def _update_neighbors(self):
        self._neighbors = set(find_closest_cosine_n_words(
            self._d,
            self._current_word,
            self._n_neighbors))
    def get_neighbors(self):
        return self._neighbors
    def get_current_dist(self):
        return self._dist
    def get_current_similarity(self):
        return self._similarity
    def get_source(self):
        return self._source_word
    def get_dest(self):
        return self._dest_word
    def get_current(self):
        return self._current_word
    def get_current_dist(self):
        return self._dist
    def init_game(self):
        randkeys = random.sample(list(self._d.keys()), 2)
        self._source_word = randkeys[0]
        self._dest_word = randkeys[1]
        self._current_word = self._source_word

        self._update_dist()
        self._update_neighbors()
        print(f'Going from {self._source_word} to {self._dest_word}')
    def guess(self, k):
        if(not k in self._d):
            return False, 'Invalid word'
        elif(k in self._neighbors):
            self._current_word = k
            self._update_dist()
            self._update_neighbors()
            return True, 'Valid neighbor'
        else:
            return False, 'Not amongst neighbors'
