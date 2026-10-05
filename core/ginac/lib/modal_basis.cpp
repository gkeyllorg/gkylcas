#include <iostream>
#include <cassert>

#include "serendip_mono.h"
#include "tensor_mono.h"
#include "hyb_mono.h"
#include "gkhyb_mono.h"
#include "gkhyb_vel_mono.h"
#include <modal_basis.h>

// Serendipity basis function monomial list for each dimension: mo_list[ndim].ev[polyOrder]
static struct { GiNaC::lst (*ev[4])(const std::vector<GiNaC::symbol>&);
} ser_mo_list[] = {
  {NULL, NULL, NULL, NULL}, // No 0D basis functions
  {serendip_1x_p0, serendip_1x_p1, serendip_1x_p2, serendip_1x_p3},
  {serendip_2x_p0, serendip_2x_p1, serendip_2x_p2, serendip_2x_p3},
  {serendip_3x_p0, serendip_3x_p1, serendip_3x_p2, serendip_3x_p3},
  {serendip_4x_p0, serendip_4x_p1, serendip_4x_p2, serendip_4x_p3},
  {serendip_5x_p0, serendip_5x_p1, serendip_5x_p2, serendip_5x_p3},
  {serendip_6x_p0, serendip_6x_p1, serendip_6x_p2, NULL},
};

// Tensor basis function monomial list for each dimension:
// mo_list[ndim].ev[polyOrder]. Note that p=0,1 tensor basis are
// identical to their serendipity counter-parts
static struct { GiNaC::lst (*ev[4])(const std::vector<GiNaC::symbol>&);
} ten_mo_list[] = {
  {NULL, NULL, NULL, NULL}, // No 0D basis functions
  {serendip_1x_p0, serendip_1x_p1, serendip_1x_p2, serendip_1x_p3},
  {serendip_2x_p0, serendip_2x_p1, tensor_2x_p2, tensor_2x_p3},
  {serendip_3x_p0, serendip_3x_p1, tensor_3x_p2, NULL},
  {serendip_4x_p0, serendip_4x_p1, tensor_4x_p2, NULL},
  {serendip_5x_p0, serendip_5x_p1, tensor_5x_p2, NULL},
  {serendip_6x_p0, serendip_6x_p1, NULL, NULL},
};

// Serendipity hybrid basis function monomial list for each dimension: mo_list[ndim].ev[polyOrder]
static struct { GiNaC::lst (*ev[4])(const std::vector<GiNaC::symbol>&);
} hyb_mo_list[] = {
  {NULL, NULL, NULL, NULL}, // No 0x basis functions
  {NULL, hyb_1x1v_p1, hyb_1x2v_p1, hyb_1x3v_p1},
  {NULL, hyb_2x1v_p1, hyb_2x2v_p1, hyb_2x3v_p1},
  {NULL, hyb_3x1v_p1, hyb_3x2v_p1, hyb_3x3v_p1},
};

// Serendipity GK hybrid basis function monomial list for each dimension: mo_list[ndim].ev[polyOrder]
static struct { GiNaC::lst (*ev[4])(const std::vector<GiNaC::symbol>&);
} gkhyb_mo_list[] = {
  {NULL, NULL, NULL, NULL}, // No 0D basis functions
  {NULL, gkhyb_1x1v_p1, gkhyb_1x2v_p1, NULL},
  {NULL,          NULL, gkhyb_2x2v_p1, NULL},
  {NULL,          NULL, gkhyb_3x2v_p1, NULL},
};

// Serendipity GK hybrid velocity basis function monomial list for each dimension: mo_list[ndim].ev[polyOrder]
static struct { GiNaC::lst (*ev[4])(const std::vector<GiNaC::symbol>&);
} gkhyb_vel_mo_list[] = {
  {NULL, NULL, NULL, NULL}, // No 0D basis functions
  {NULL, gkhyb_vel_1v_p1, gkhyb_vel_2v_p1, NULL},
};

Gkyl::ModalBasis::ModalBasis(ModalBasisType type, int ndim, int vdim, const std::vector<GiNaC::symbol>& invars, int polyOrder)
: ndim(ndim), vdim(vdim), polyOrder(polyOrder)
{
  assert(ndim<=6 && polyOrder<=3);

  for (int d=0; d<ndim; ++d) vars.push_back(invars[d]);

  if (type == Gkyl::MODAL_SER) {
    assert(ser_mo_list[ndim].ev[polyOrder] != NULL);
    bc = gsOrthoNorm(ser_mo_list[ndim].ev[polyOrder](vars));
  }
  else if (type == Gkyl::MODAL_TEN) {
    assert(ten_mo_list[ndim].ev[polyOrder] != NULL);
    bc = gsOrthoNorm(ten_mo_list[ndim].ev[polyOrder](vars));
  }
  else if (type == Gkyl::MODAL_HYB) {
    assert(vdim > 0 && vdim < ndim);
    assert(polyOrder == 1);
    int cdim = ndim-vdim;
    assert(hyb_mo_list[cdim].ev[vdim] != NULL);
    bc = gsOrthoNorm(hyb_mo_list[cdim].ev[vdim](vars));
  }
  else if (type == Gkyl::MODAL_GKHYB) {
    assert(vdim > 0 && vdim < ndim);
    assert(polyOrder == 1);
    int cdim = ndim-vdim;
    assert(gkhyb_mo_list[cdim].ev[vdim] != NULL);
    bc = gsOrthoNorm(gkhyb_mo_list[cdim].ev[vdim](vars));
  }  
  else if (type == Gkyl::MODAL_GKHYB_VEL) {
    assert(vdim > 0 && vdim < 3);
    assert(polyOrder == 1);
    assert(gkhyb_vel_mo_list[1].ev[vdim] != NULL);
    bc = gsOrthoNorm(gkhyb_vel_mo_list[1].ev[vdim](vars));
  }  
}

GiNaC::lst
Gkyl::ModalBasis::get_vars() const
{
  GiNaC::lst v;
  for (int i=0; i<ndim; ++i)
    v.append( vars[i] );
  return v;
}

GiNaC::lst
Gkyl::ModalBasis::diffBasis(int n) const
{
  GiNaC::lst db;
  for (auto bidx = bc.begin(); bidx != bc.end(); ++bidx)
    db.append( GiNaC::diff(*bidx, vars[n]) );
  return db;
}

GiNaC::ex
Gkyl::ModalBasis::innerProd(const GiNaC::ex &f1, const GiNaC::ex &f2) const
{
  GiNaC::ex out = (f1*f2).expand();
  for (int i=0; i<ndim; ++i)
    out = GiNaC::integral(vars[i], -1, 1, out).eval_integ();
  return out;
}

GiNaC::ex
Gkyl::ModalBasis::norm(const GiNaC::ex &f) const
{
  return GiNaC::sqrt(innerProd(f, f));
}

GiNaC::ex
Gkyl::ModalBasis::proj(const GiNaC::ex &u, const GiNaC::ex &v) const
{
  return innerProd(u,v)/innerProd(u,u)*u;
}

GiNaC::lst
Gkyl::ModalBasis::gsOrthoNorm(const GiNaC::lst& vec) const
{
  GiNaC::lst orthoVec { vec[0]/norm(vec[0]) };

  if (vec.nops() > 1) {
    auto vitr = vec.begin(); ++vitr;
    for ( ; vitr != vec.end(); ++vitr) {
      GiNaC::ex pj;
      for (auto jitr = orthoVec.begin(); jitr != orthoVec.end(); ++jitr)
        pj += proj(*jitr, *vitr);
      GiNaC::ex v = *vitr - pj;
      orthoVec.append(v/norm(v));
    }
  }
  return orthoVec;
}

GiNaC::ex
Gkyl::ModalBasis::expand(const GiNaC::symbol& f) const
{
  GiNaC::ex fh;
  int i = 0;
  for (auto bidx = bc.begin() ; bidx != bc.end(); ++bidx, ++i)
    fh += (*bidx)*GiNaC::indexed(f, GiNaC::idx(i,1));
  return fh;
}

GiNaC::lst
Gkyl::ModalBasis::calcInnerProdList(const GiNaC::lst &lst, const GiNaC::ex &f) const
{
  GiNaC::lst out;
  for (auto lidx = lst.begin(); lidx != lst.end(); ++lidx)
    out.append( innerProd(*lidx, f) );
  return out;
}
  
