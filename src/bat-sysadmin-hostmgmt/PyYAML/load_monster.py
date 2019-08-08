#!/usr/bin/env python
import yaml
import monster
import argparse
import sys

def create_monster(monster_url):
    fd = open(monster_url)
    monster = yaml.load(fd)
    fd.close()
    return monster


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-m', '--monster',
        help='yalm file with monster description')
    args = parser.parse_args()
    if not args.monster:
        sys.stderr.write("parameter --monster is not defined\n")
        sys.exit(1)

    monster = create_monster(args.monster)
    print(monster)

if __name__ == "__main__":
    main()
