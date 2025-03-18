import jinja2
import argparse
import os

from word_emb_golf_graph import load_graph_as_gzip_base64

def render_webapp(graph_fname, template_fname, out_fname):
    graph_as_gzip_base64 = load_graph_as_gzip_base64(graph_fname)
    environment = jinja2.Environment(loader = jinja2.FileSystemLoader(os.path.dirname(template_fname)))
    template = environment.get_template(os.path.basename(template_fname))
    with open(out_fname, mode='w', encoding='utf-8') as ofile:
        ofile.write(template.render(graph_gzip_base64 = graph_as_gzip_base64))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--graph")
    parser.add_argument("--template")
    parser.add_argument("--output")
    args = parser.parse_args()
    render_webapp(args.graph, args.template, args.output)


