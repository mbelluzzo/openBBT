#!/usr/bin/env python
import os
import jinja2
import argparse
import sys

users = {
    "title": "My Users",
    "items": [
        {"name": "Jhon", "age": 27},
        {"name": "Jhon1", "age": 26},
        {"name": "Jhon2", "age": 25},
        {"name": "Jhon3", "age": 28},
        {"name": "Jhon4", "age": 29},
        {"name": "Jhon5", "age": 21},
    ],
}

def show_render(template_path):
    path, filename = os.path.split(template_path)
    template = jinja2.Environment(
        loader=jinja2.FileSystemLoader(path or './')
    ).get_template(filename)
    print(template.render(users))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--template',
        help='jinja template path')
    args = parser.parse_args()
    if not args.template:
        sys.stderr.write("parammeter --template is not defined\n")
        sys.exit(1)
    show_render(args.template)

if __name__== '__main__':
    main()
