#!/bin/bash

maxima -r 'load("fpo-vlasov-h.mac");quit();'
maxima -r 'load("fpo-vlasov-diffusion-vol-1x3v-c.mac");quit();'
maxima -r 'load("fpo-vlasov-diffusion-surf-1x3v-c.mac");quit();'
