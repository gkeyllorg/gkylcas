#!/bin/bash
# Run from the gkylcas repository root.
maxima -r 'load("core/recovery-calc/recovery-unit.mac")$testRecov("check")$values;quit();'
