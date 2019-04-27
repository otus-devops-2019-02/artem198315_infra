#!/usr/bin/env python

import os
import sys
import json
import argparse

filepath = "inventory.json"


class StaticInventory(object):

  def cli_args(self):
    parser = argparse.ArgumentParser()
    parser.add_argument('--host')
    parser.add_argument('--list', action='store_true')
    self.cli_args = parser.parse_args()

  def default_res(self):
    return {
             "_meta": {
               "hostvars": {}
             }
           }

  def __init__(self):
    self.cli_args()
    self.inventory = self.default_res()

    f = open(filepath,"r")

    if self.cli_args.list:
      self.inventory=json.load(f)


    if self.cli_args.host:
      self.inventory = self.default_res()


    print(json.dumps(self.inventory, indent=2))

StaticInventory()
