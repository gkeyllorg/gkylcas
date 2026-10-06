#pragma once

#include <vector>
#include <ginac/ginac.h>

namespace Gkyl {
  /* Basis type */
  enum ModalBasisType { MODAL_SER, MODAL_TEN, MODAL_HYB, MODAL_GKHYB, MODAL_GKHYB_VEL };
  
  class ModalBasis {
  public:
    /* Construct new modal basis object */
    ModalBasis(ModalBasisType type, int ndim, int vdim, const std::vector<GiNaC::symbol>& vars, int polyOrder);
    
    /* Dimensions and polyorder */
    int get_ndim() const { return ndim; }
    int get_vdim() const { return vdim; }
    int get_polyOrder() const { return polyOrder; }
    
    /* Get number of basis functions */
    int get_numbasis() const { return bc.nops(); }
    /* Get list of basis functions */
    GiNaC::lst get_basis() const { return bc; }
    /* Get variables */
    GiNaC::lst get_vars() const;
    /* Return nth variable */
    const GiNaC::symbol& get_var(int n) const { return vars[n]; }

    /* Get derivative of basis functions wrt to n-th indep. var */
    GiNaC::lst diffBasis(int n) const;

    /* Generate indexed expansion with symbol 'f' and basis */
    GiNaC::ex expand(const GiNaC::symbol& f) const;

    /* Compute inner product of f1 and f2 */
    GiNaC::ex innerProd(const GiNaC::ex &f1, const GiNaC::ex &f2) const;

    /* Calculate inner product with list of expressions */
    GiNaC::lst calcInnerProdList(const GiNaC::lst &lst, const GiNaC::ex &f) const;

  private:
    int ndim, vdim, polyOrder;
    GiNaC::lst bc; // orthonormal basis set
    std::vector<GiNaC::symbol> vars; // Variable list

    /* Compute L2-norm of f */
    GiNaC::ex norm(const GiNaC::ex &f) const;
    /* Compute projection of u on v */
    GiNaC::ex proj(const GiNaC::ex &u, const GiNaC::ex &v) const;

    /* Orthonormalize list of monomials */
    GiNaC::lst gsOrthoNorm(const GiNaC::lst& vec) const;
  };
}
