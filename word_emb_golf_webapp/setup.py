#!/usr/bin/env python

from setuptools import setup, find_packages

setup(name='word_emb_golf_webapp',
      version='1.0',
      # Modules to import from other scripts:
      packages=['word_emb_golf_webapp'],
      include_package_data = True,
      data_files = [('word_emb_golf_webapp', ['word_emb_golf_webapp/templates/index.html'])],
      # Executables
      scripts=["web_interface.py"],
     )
