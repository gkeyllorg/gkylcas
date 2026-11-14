#!/bin/bash
# Generate all the kernels of the Rosenbluth/Fokker-Planck operator (FPO).
# Run from the gkylcas repository root; the kernels are written to ~/max-out.
#
# The 2x3v tensor p=1 (hybrid) kernels exhaust the default 1 GB Lisp heap of an
# SBCL-based Maxima ("Heap exhausted, game over"), so Maxima is run with a larger
# one; 24 GB was enough for every kernel. The 2x3v diffusion kernels take hours.
run_maxima() {
  maxima -X "--dynamic-space-size 24GB" -b "$1"
}

# Drag coefficient and its sign
run_maxima vlasov/fpo/ms-fpo-drag-coeff.mac

# Diffusion tensor
run_maxima vlasov/fpo/ms-fpo-diff-coeff.mac

# Surface expansions of the diffusion tensor
run_maxima vlasov/fpo/ms-fpo-diff-coeff-surf.mac

# Conservation moments
run_maxima vlasov/fpo/ms-moments-vlasov-fpo.mac

# Conservation corrections
run_maxima vlasov/fpo/ms-fpo-vlasov-coeff-correct.mac

# Drag terms
run_maxima vlasov/fpo/ms-fpo-vlasov-drag-vol.mac
run_maxima vlasov/fpo/ms-fpo-vlasov-drag-surf.mac
run_maxima vlasov/fpo/ms-fpo-vlasov-drag-boundary-surf.mac

# Diffusion terms
run_maxima vlasov/fpo/ms-fpo-vlasov-diff-vol.mac
run_maxima vlasov/fpo/ms-fpo-vlasov-diff-surf.mac
run_maxima vlasov/fpo/ms-fpo-vlasov-diff-boundary-surf.mac

# Headers
run_maxima vlasov/fpo/ms-fpo-vlasov-header.mac
run_maxima vlasov/fpo/ms-moments-vlasov-fpo-header.mac
