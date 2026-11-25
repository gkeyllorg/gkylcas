#!/bin/sh
set -eu

# Run from maxima/g0 so the standard gkylcas load paths resolve.
maxima -r 'load("conf_diffusion/ms-conf_diffusion-header.mac"); quit();'
maxima -r 'load("conf_diffusion/ms-conf_diffusion-vol.mac"); quit();'
maxima -r 'load("conf_diffusion/ms-conf_diffusion-surf.mac"); quit();'
