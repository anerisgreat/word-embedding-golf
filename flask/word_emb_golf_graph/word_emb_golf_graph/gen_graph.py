#!/usr/bin/env python

import argparse
import numpy

from word_emb_golf_graph.graph import gen_graph, save_graph

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--n-neighbors", help="Number of neighbors.", type = int,
                        default = 20)
    parser.add_argument("output", help="Output fpath", type = str)

    args = parser.parse_args()
    n_neighbors = args.n_neighbors
    output_fpath = args.output
    save_graph(gen_graph(n_neighbors), output_fpath)

if __name__ == '__main__':
    main()
