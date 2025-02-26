#!/usr/bin/env python

from setuptools import setup, find_packages
from glob import glob
from os.path import splitext, basename

setup(name='word_emb_golf_graph',
      version='1.0',
      packages=find_packages(),
      scripts=["word_emb_golf_graph/gen_graph.py"],
      entry_points = {'console_scripts' : ['gen_graph = word_emb_golf_graph.gen_graph:main']}
     )
