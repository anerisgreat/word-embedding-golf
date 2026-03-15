import gzip
import base64
import json
import os
import sys
import tempfile
import pytest
import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'word_emb_golf_graph'))
from graph import (
    WordEmbEntry,
    save_graph_gzip,
    load_graph_as_gzip_base64,
)


class TestWordEmbEntry:
    def test_default_values(self):
        entry = WordEmbEntry()
        assert entry.neighbors == []
        assert entry.emb == []
        assert entry.tsne_emb == []

    def test_with_values(self):
        entry = WordEmbEntry(
            neighbors=["word1", "word2"],
            emb=[0.1, 0.2, 0.3],
            tsne_emb=[0.5, 0.6],
        )
        assert entry.neighbors == ["word1", "word2"]
        assert entry.emb == [0.1, 0.2, 0.3]
        assert entry.tsne_emb == [0.5, 0.6]


class TestSaveLoadGraph:
    def test_roundtrip_single_entry(self):
        graph = {
            "test_word": WordEmbEntry(
                neighbors=["neighbor1", "neighbor2"],
                emb=[0.1, 0.2, 0.3],
                tsne_emb=[0.5, 0.6],
            )
        }
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
            fpath = f.name
        
        try:
            save_graph_gzip(graph, fpath)
            loaded = load_graph_as_gzip_base64(fpath)
            
            decoded = base64.b64decode(loaded)
            decompressed = gzip.decompress(decoded)
            parsed = json.loads(decompressed)
            
            assert "test_word" in parsed
            assert parsed["test_word"]["neighbors"] == ["neighbor1", "neighbor2"]
            assert parsed["test_word"]["emb"] == [0.1, 0.2, 0.3]
            assert parsed["test_word"]["tsne_emb"] == [0.5, 0.6]
        finally:
            os.unlink(fpath)

    def test_roundtrip_multiple_entries(self):
        graph = {
            f"word_{i}": WordEmbEntry(
                neighbors=[f"neighbor_{i}_1", f"neighbor_{i}_2"],
                emb=[float(i), float(i + 1), float(i + 2)],
                tsne_emb=[float(i) * 0.1, float(i) * 0.2],
            )
            for i in range(10)
        }
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
            fpath = f.name
        
        try:
            save_graph_gzip(graph, fpath)
            loaded = load_graph_as_gzip_base64(fpath)
            
            decoded = base64.b64decode(loaded)
            decompressed = gzip.decompress(decoded)
            parsed = json.loads(decompressed)
            
            assert len(parsed) == 10
            assert "word_5" in parsed
            assert parsed["word_5"]["emb"] == [5.0, 6.0, 7.0]
        finally:
            os.unlink(fpath)

    def test_float_precision(self):
        graph = {
            "precise": WordEmbEntry(
                emb=[0.123456789, 0.987654321],
                tsne_emb=[0.111111111, 0.222222222],
            )
        }
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
            fpath = f.name
        
        try:
            save_graph_gzip(graph, fpath)
            loaded = load_graph_as_gzip_base64(fpath)
            
            decoded = base64.b64decode(loaded)
            decompressed = gzip.decompress(decoded)
            parsed = json.loads(decompressed)
            
            assert parsed["precise"]["emb"] == [0.12, 0.99]
            assert parsed["precise"]["tsne_emb"] == [0.11, 0.22]
        finally:
            os.unlink(fpath)


class TestGraphGeneration:
    def test_cosine_similarity_distance(self):
        from sklearn.metrics.pairwise import cosine_similarity
        from word_emb_golf_preprocess.gen_graph import _local_cosine_similarity
        
        a = np.array([1.0, 0.0])
        b = np.array([1.0, 0.0])
        c = np.array([0.0, 1.0])
        
        assert abs(_local_cosine_similarity(a, b)[0, 0] - 1.0) < 1e-6
        assert abs(_local_cosine_similarity(a, c)[0, 0] - 0.0) < 1e-6

    def test_get_closest_n_words(self):
        from word_emb_golf_preprocess.gen_graph import _get_closest_n_words
        
        word_list = ["a", "b", "c", "d", "e"]
        emb_arr = np.array([
            [0.0, 0.0],
            [1.0, 0.0],
            [2.0, 0.0],
            [3.0, 0.0],
            [4.0, 0.0],
        ])
        
        dists = 1 - np.array([
            [0.0, 1.0, 1.0, 1.0, 1.0],
            [1.0, 0.0, 0.5, 0.8, 0.9],
            [1.0, 0.5, 0.0, 0.2, 0.5],
            [1.0, 0.8, 0.2, 0.0, 0.1],
            [1.0, 0.9, 0.5, 0.1, 0.0],
        ])
        
        closest = _get_closest_n_words(1, word_list, emb_arr, dists, n_neighbors=2)
        
        assert "b" not in closest
        assert len(closest) == 2
