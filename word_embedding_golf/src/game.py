import random

from .embeddings import *
from .graph import *

def _cosine_similarity(a, b):
    return np.dot(a, b)/(np.linalg.norm(a)*np.linalg.norm(b))

class WordToVecGame():
    def __init__(self, n_neighbors = 20):
        self._g = import_graph()
        self._game_done = False
    #     self._n_neighbors = n_neighbors
    def _get_similarity_to_word(self, k):
        return _cosine_similarity(self._g.nodes[k]['emb'], self._g.nodes[self._dest_word]['emb'])
    def _update_similarity(self):
        self._similarity = self._get_similarity_to_word(self._current_word)
    def _update_neighbors(self):
        self._neighbors = list(self._g.neighbors(self._current_word))
    def get_neighbors(self):
        return self._neighbors
    def get_current_similarity(self):
        return self._similarity
    def get_source(self):
        return self._source_word
    def get_dest(self):
        return self._dest_word
    def get_current(self):
        return self._current_word
    def init_game(self):
        self._game_done = False
        randkeys = random.sample(list(self._g.nodes), 2)
        self._source_word = randkeys[0]
        self._dest_word = randkeys[1]
        self._current_word = self._source_word

        self._update_similarity()
        self._update_neighbors()
        print(f'Going from {self._source_word} to {self._dest_word}')
    def get_game_done(self):
        return self._game_done
    def guess(self, k):
        if(not k in self._g):
            return False, 'Invalid word'
        elif(k in self._neighbors):
            self._current_word = k
            self._update_similarity()
            self._update_neighbors()
            if(k == self._dest_word):
                self._game_done = True
            return True, 'Valid neighbor'
        else:
            return False, 'Not amongst neighbors'
