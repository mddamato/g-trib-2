#!/bin/env python3

import sys
import yaml
import logging
import os

## Creates enviroment variable friendly name to lookup relevant vars with
TOOLNAME = sys.argv[0].upper().replace('.PY', '').replace('-', '_').replace('./','')
try:
  _LOGGINGLEVEL = os.environ[f"{TOOLNAME}_LOG_LEVEL"].upper()
  print(f"Setting logging to {_LOGGINGLEVEL}")
except NameError:
  _LOGGINGLEVEL = logging.INFO
  logging.info(f"enviroment variable {TOOLNAME}_LOG_LEVEL not found, setting logging to INFO")

logging.basicConfig(stream=sys.stdout, level=_LOGGINGLEVEL)
filetoconvert = sys.argv[1]
outputfile = filetoconvert.replace('.txt', '.yml')
registry_yaml = {}

with open(filetoconvert, 'r') as fh:
  for line in fh:
    if "quay.io" in line:
      image_name = line.split('quay.io/')[1].split(':')[0]
      tag = line.split('quay.io/')[1].split(':')[1].strip()
      logging.info(f"adding quay.io/{image_name}:{tag} to yaml")
      try:
        registry_yaml['quay.io']['images'][image_name].append(tag)
        logging.debug(f"image:{image_name} tags appended with tag: {tag}")
      except KeyError:
        try:
          try:
            registry_yaml['quay.io']['images'][image_name] = [tag]
            logging.debug(f"image:{image_name} tags list made with first tag: {tag}")
          except KeyError:
            registry_yaml['quay.io']['images'] = {image_name:[tag]}
            logging.debug(f"Creating images for quay.io with first image as:{image_name} and tags list made with first tag: {tag}")
        except KeyError:
          registry_yaml['quay.io'] = {'images':{image_name:[tag]}}
          logging.debug(f"images dict made with first image:{image_name} and tags list made with first tag for image of: {tag} to quay.io dict")
    else:
      image_name = line.split(':')[0]
      tag = line.split(':')[1].strip()
      logging.info(f"adding docker.io/{image_name}:{tag} to yaml")
      try:
        registry_yaml['docker.io']['images'][image_name].append(tag)
        logging.debug(f"image:{image_name} tags appended with tag: {tag}")
      except KeyError:
        try:
          try:
            registry_yaml['docker.io']['images'][image_name] = [tag]
            logging.debug(f"image:{image_name} tags list made with first tag: {tag}")
          except KeyError:
            registry_yaml['docker.io']['images'] = {image_name:[tag]}
            logging.debug(f"docker.io images dict made with first image:{image_name} and tags list made with first tag: {tag}")
        except KeyError:
          registry_yaml['docker.io'] = {'images':{image_name:[tag]}}
          logging.debug(f"images dict made with first image:{image_name} and tags list made with first tag for image of: {tag} to docker.io dict")
       
logging.info(f"writing output to {outputfile}")
with open(outputfile, 'w') as fh:
  yaml.dump(registry_yaml, fh, allow_unicode=True)
logging.info(f"output written to {outputfile}")
