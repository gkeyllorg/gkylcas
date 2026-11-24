Computer algebra system to generate kernel code for use in Gkeyll solvers.

## Updater selection tables and CUDA call targets

The dispatch generators emit selection tables and complete, deduplicated PTX
target lists for gyrokinetic moments, weighted moments, radiation drag, and
PKPM acceleration. Run from the
gkylcas root, just as for the algebraic kernel generators:

```sh
mkdir -p ~/max-out
maxima --quiet -b gyrokinetic/gk_moments/ms-gk-moment-dispatch.mac
maxima --quiet -b pkpm/pkpm/ms-pkpm-accel-dispatch.mac
maxima --quiet -b gyrokinetic/gk_weighted_moments/ms-gk-weighted-moment-dispatch.mac
maxima --quiet -b gyrokinetic/radiation/ms-rad-drag-dispatch.mac
```

Each generator produces a private header. The output directory defaults to
`~/max-out` and can be overridden before loading the driver:

| Updater | Output header | Output directory variable |
| --- | --- | --- |
| Moments | `gkyl_mom_gyrokinetic_registry_priv.h` | `gk_mom_output_dir` |
| Weighted moments | `gkyl_mom_weighted_gyrokinetic_registry_priv.h` | `gk_weighted_mom_output_dir` |
| Radiation drag | `gkyl_dg_calc_gk_rad_vars_registry_priv.h` | `gk_rad_output_dir` |
| PKPM acceleration | `gkyl_dg_calc_pkpm_accel_registry_priv.h` | `pkpm_accel_output_dir` |

For example:

```sh
maxima --quiet --batch-string='gk_mom_output_dir:"/tmp"$ load("gyrokinetic/gk_moments/ms-gk-moment-dispatch.mac")$'
```

Copy the output headers into the corresponding Gkeyll `zero/` directories, then
run Gkeyll's formatter (from its root):

```sh
cp ~/max-out/gkyl_mom_gyrokinetic_registry_priv.h gyrokinetic/zero/
cp ~/max-out/gkyl_dg_calc_pkpm_accel_registry_priv.h pkpm/zero/
cp ~/max-out/gkyl_mom_weighted_gyrokinetic_registry_priv.h gyrokinetic/zero/
cp ~/max-out/gkyl_dg_calc_gk_rad_vars_registry_priv.h gyrokinetic/zero/
python3 ci/format.py gyrokinetic/zero/*registry_priv.h pkpm/zero/*registry_priv.h
```

The headers remain checked into Gkeyll. Building Gkeyll does not run Maxima.
Do not hand-edit the generated headers; regenerate and format them together.

The `ms-` drivers describe supported selections and aliases in their user-input
sections. The module functions convert that metadata into tables of the form
`[C name, C element type, nested initializer]`. Leaves are function-name strings
or `"NULL"`; nested lists preserve aggregate layout and index ordering. The
shared `util_maxima/kernel-dispatch.mac` emitter writes ordinary C tables and
collects the distinct non-null leaves into a sorted target list. Thus the
emitter does not depend on the number of basis, dimension, order, location, or
boundary-condition indices. A future FEM table can use additional nesting.

These descriptions specify which existing kernels the updater can select.
They do not replace the algebraic kernel generators or automatically add
support to Gkeyll's chooser functions. When adding a supported kernel, update
the algebraic generator and chooser as needed, update the dispatch description,
regenerate the header, and extend the dispatch tests. The ordinary/integrated
moment tables retain Gkeyll's `cv_index` row order and order slots 0, 1, 2.
The PKPM tables retain configuration-dimension rows 1, 2, 3, including tensor
selections that reuse serendipity kernels.

Each target list belongs to one callback family. The radiation header uses
`writeKernelDispatchFamiliesHeader` to emit separate v-parallel drag, mu drag,
and density-weighted drag target lists. Weighted moments share one list across
CONF/VEL weights and ordinary/integrated moments. PKPM pressure-force calls
and other unconverted callback families remain outside this implementation. The typed
inline PTX adapters remain in Gkeyll; changing a callback signature requires
reviewing its adapter. Every function selected at a constrained call must be in
its target list, including targets of any newly added selection path.

Target lists constrain which functions an indirect call can reach; register
budgets remain a Gkeyll Makefile setting. In particular, `RAD_MAX_REGS` can tune
density-weighted radiation drag independently of `MOM_MAX_REGS`, without
regenerating these headers. Rebuild affected objects when changing a cap.
