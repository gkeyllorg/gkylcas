---
name: directory-structure
description: Locate gkylcas code and understand solver dependencies when exploring the repository or deciding where new code belongs.
---

# Instructions

* Use when exploring the repository, trying to find something, or deciding where new code belongs.
* Operate relative to the repository root (`git rev-parse --show-toplevel`).

# gkylcas file structure

gkylcas holds the computer algebra system (CAS) code to generate kernels used by Gkeyll. Gkeyll has
four PDE solvers: moments (fluid), Vlasov, gyrokinetic and PKPM. Correspondingly, these solvers are
organized into four separate folders, and they share some common functionality in a fifth (core)
folder. Hence, gkylcas is mostly organized in:
* core/: functionality common to all solvers.
* moments/: files for the moments solver.
* vlasov/: files for the Vlasov solver.
* gyrokinetic/: files for the gyrokinetic solver.
* pkpm/: files for the PKPM solver.

Note that the four solvers are not independent. They have the following
dependencies:
* moments depends on core.
* vlasov depends on moments.
* gyrokinetic depends on vlasov.
* pkpm depends on gyrokinetic.

There are other Maxima-specific utilities, independent of model or discretization, in util_maxima/.
