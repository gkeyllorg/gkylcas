Computer algebra system to generate kernel code for use in Gkeyll solvers.

## Updater selection tables and CUDA call targets

Two prototype generators emit the selection tables and complete, deduplicated
PTX target lists for gyrokinetic moments and PKPM acceleration. Run from the
gkylcas root, just as for the algebraic kernel generators:

```sh
mkdir -p ~/max-out
maxima --quiet -b gyrokinetic/gk_moments/ms-gk-moment-dispatch.mac
maxima --quiet -b pkpm/pkpm/ms-pkpm-accel-dispatch.mac
```

The output files are `gkyl_mom_gyrokinetic_registry_priv.h` and
`gkyl_dg_calc_pkpm_accel_registry_priv.h`. To override the output directory, set
`gk_mom_output_dir` or `pkpm_accel_output_dir` before loading the corresponding
driver, for example:

```sh
maxima --quiet --batch-string='gk_mom_output_dir:"/tmp"$ load("gyrokinetic/gk_moments/ms-gk-moment-dispatch.mac")$'
```

Copy the output headers into the corresponding Gkeyll `zero/` directories, then
run Gkeyll's formatter (from its root):

```sh
cp ~/max-out/gkyl_mom_gyrokinetic_registry_priv.h gyrokinetic/zero/
cp ~/max-out/gkyl_dg_calc_pkpm_accel_registry_priv.h pkpm/zero/
python3 ci/format.py gyrokinetic/zero/gkyl_mom_gyrokinetic_registry_priv.h pkpm/zero/gkyl_dg_calc_pkpm_accel_registry_priv.h
```

The headers remain checked into Gkeyll. Building Gkeyll does not run Maxima.
Do not hand-edit the generated headers; regenerate and format them together.

The `ms-` drivers describe supported selections and aliases in their user-input
sections. The module functions `gkMomentDispatchTables` and
`pkpmAccelDispatchTables` convert that metadata into tables of the form
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

Each target list belongs to one callback family. PKPM pressure-force calls,
radiation, and other callback families are outside this prototype. The typed
inline PTX adapters remain in Gkeyll; changing a callback signature requires
reviewing its adapter. Every function selected at a constrained call must be in
its target list, including targets of any newly added selection path.
