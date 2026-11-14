#!/bin/bash
# Generate all the kernels of the Rosenbluth/Fokker-Planck operator (FPO).
# Run from the gkylcas repository root; the kernels are written to ~/max-out.

# Drag coefficient and its sign
maxima -b vlasov/fpo/ms-fpo-drag-coeff.mac

# Diffusion tensor
maxima -b vlasov/fpo/ms-fpo-diff-coeff.mac

# Surface expansions of the diffusion tensor
maxima -b vlasov/fpo/ms-fpo-diff-coeff-surf.mac

# Conservation moments
maxima -b vlasov/fpo/ms-moments-vlasov-fpo.mac

# Conservation corrections
maxima -b vlasov/fpo/ms-fpo-vlasov-coeff-correct.mac

# Drag terms
maxima -b vlasov/fpo/ms-fpo-vlasov-drag-vol.mac
maxima -b vlasov/fpo/ms-fpo-vlasov-drag-surf.mac
maxima -b vlasov/fpo/ms-fpo-vlasov-drag-boundary-surf.mac

# Diffusion terms
maxima -b vlasov/fpo/ms-fpo-vlasov-diff-vol.mac
maxima -b vlasov/fpo/ms-fpo-vlasov-diff-surf.mac
maxima -b vlasov/fpo/ms-fpo-vlasov-diff-boundary-surf.mac

# Headers
maxima -b vlasov/fpo/ms-fpo-vlasov-header.mac
maxima -b vlasov/fpo/ms-moments-vlasov-fpo-header.mac
