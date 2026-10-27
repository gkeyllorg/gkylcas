# FEM mass projection kernels

Run from the gkylcas repository root with Maxima. Both generators default to
`~/max-out/`:

```sh
mkdir -p ~/max-out/
maxima --very-quiet -b gyrokinetic/fem_proj/ms-fem-proj.mac
maxima --very-quiet -b gyrokinetic/fem_proj/ms-fem-proj-header.mac
```

To choose another existing output directory:

```sh
maxima --very-quiet --batch-string='fem_proj_out:"/tmp/fem_proj-generated-repeat"$ load("gyrokinetic/fem_proj/ms-fem-proj.mac")$ load("gyrokinetic/fem_proj/ms-fem-proj-header.mac")$'
```

The kernel driver writes only C files; the header driver writes only the header
and does not perform symbolic matrix integration. Keep the user-input basis,
dimension and polynomial-order ranges consistent between the two drivers.

Copy the emitted C files and header into `gkeyll/gyrokinetic/ker/fem_proj/`.
Never edit or format the generated files. Their numerical coefficients come
from exact reference-cell polynomial integrals, rounded only when emitting C.

`fem-proj.mac` generates node counts, periodic lattice keys, the
consistent nodal mass matrix, the DG load vector, boundary-node evaluation,
and nodal-to-modal reconstruction. Kernels have an independent `fem_proj_`
namespace and do not call Poisson kernels. General nodal/basis utilities are
shared with other generators; no differential-operator generators are loaded.

The driver emits serendipity 1D/2D p1/p2. Algorithms use a dimension parameter
and also describe 3D p1/p2 (vertices and edges for p2), but 3D generation and
runtime dispatch remain disabled until separately validated. The updater
compacts lattice keys, assembles shared nodes, and imposes boundary rows.
It uses `gkyl_basis.node_list` to identify boundary nodes during construction.

The equations are integral(N_i*wL*u) = integral(N_i*wR*f), with independent
optional DG weights. Unity kernels omit weight access. Weighted load kernels
integrate the product directly without projecting it into a lower-order space.
There is no Laplacian, epsilon, kSq, or Poisson nullspace correction.

The gkeyll `ctest_fem_proj` test independently assembles a dense FEM system with
four-point Gauss quadrature, including all weighted p2 products, and checks
periodic, constant/varying Dirichlet, and unconstrained boundaries.
