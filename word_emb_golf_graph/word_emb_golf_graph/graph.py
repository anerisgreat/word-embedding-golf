import os
from dataclasses import dataclass, field, asdict
import io
import gzip
import base64
import json

#Helper for JSON formatting
#Taken from https://stackoverflow.com/questions/54370322/how-to-limit-the-number-of-float-digits-jsonencoder-produces
class _RoundingFloatFormatter(float):
    __repr__ = staticmethod(lambda x: format(x, '.2f'))

@dataclass
class WordEmbEntry:
    neighbors : list[str] = field(default_factory = list)
    emb : list[float] = field(default_factory = list)
    tsne_emb : list[float] = field(default_factory = list)

def save_graph_gzip(graph_dict, fpath):
    #Fixing percision of floats, for all our uses we only need two decimals
    #Taken from https://stackoverflow.com/questions/54370322/how-to-limit-the-number-of-float-digits-jsonencoder-produces
    json.encoder.c_make_encoder = None
    json.encoder.float = _RoundingFloatFormatter

    graph_to_pure_dict = {k : asdict(v) \
                          for k, v in graph_dict.items()}
    #To JSON STR
    graph_as_json_str = json.dumps(graph_to_pure_dict)

    graph_as_gzip_bytes = gzip.compress(graph_as_json_str.encode())
    #Encode to base64 so it can be encoded into HTML file easily
    base64_str = base64.b64encode(graph_as_gzip_bytes).decode('ASCII')

    #Write base64 of gzip of dict of graph
    with open(fpath, 'w') as ofile:
        ofile.write(base64_str)

def export_graph(g):
    save_graph_gzip(g, os.environ['GRAPH_DATA'])

def load_graph_as_gzip_base64(fpath):
    with open(fpath, 'r') as ifile:
        return ifile.read()
