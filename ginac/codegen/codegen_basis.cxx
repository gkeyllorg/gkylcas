#include <modal_basis.h>
#include <iostream>
#include <fstream>
#include <gkyl_util.h>
#include <string>

using namespace GiNaC;

std::string
get_basis_name(Gkyl::ModalBasisType type)
{
  std::string bn;
  if (type == Gkyl::MODAL_SER)
    bn = "ser";
  else if (type == Gkyl::MODAL_TEN)
    bn = "tensor";
  else if (type == Gkyl::MODAL_HYB)
    bn = "hyb";
  else if (type == Gkyl::MODAL_GKHYB)
    bn = "gkhyb";
  else if (type == Gkyl::MODAL_GKHYB_VEL)
    bn = "gkhyb_vel";

  return bn;
}

// Generates function that evaluates the basis functions. Generated
// function signature:
//
// static void foo(const double *z, double *b)
//
// Restrict keyword and CUDA attributes are also added
//
// fh: header file
// fc: C file
//
// vdim is only used by Vlasov hybrid basis.
//
static void
gen_eval(Gkyl::ModalBasisType type, std::ostream& fh, std::ostream& fc, const Gkyl::ModalBasis& basis)
{
  std::string bn;
  bn = get_basis_name(type);

  int ndim = basis.get_ndim(), polyOrder = basis.get_polyOrder();
  int vdim = basis.get_vdim();

  if (vdim == 0 || (ndim == vdim)) {
    // function declaration
    fh << "GKYL_CU_DH void eval_" << ndim << "d_" << bn << "_" << "p" << polyOrder
       << "(const double *z, double *b);" << std::endl;  
  
    // function definition
    fc << "GKYL_CU_DH" << std::endl;
    fc << "void" << std::endl;
    fc << "eval_" << ndim << "d_" << bn << "_" << "p" << polyOrder
         << "(const double *z, double *b )" << std::endl;
  } else {
    int cdim = ndim-vdim;
    // function declaration
    fh << "GKYL_CU_DH void eval_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
       << "(const double *z, double *b);" << std::endl;  
  
    // function definition
    fc << "GKYL_CU_DH" << std::endl;
    fc << "void" << std::endl;
    fc << "eval_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
         << "(const double *z, double *b )" << std::endl;
  }
  fc << "{" << std::endl;

  // local declarations
  if (polyOrder > 0)
    for (int d=0; d<ndim; ++d)
      fc << "  const double z" << d << " = " << "z[" << d << "];" << std::endl;

  lst bc = basis.get_basis();
  // expressions to compute basis functions
  for (int i=0; i<basis.get_numbasis(); ++i)
    fc << "  b[" << i << "] = " << csrc << bc[i].expand().evalf() << ";" << std::endl;

  // close function
  fc << "}" << std::endl << std::endl;
}

// Generates function that evaluates expansion at a given
// point. Generated function signature:
//
// static double foo(const double *z, const double *f)
//
// Restrict keyword and CUDA attributes are also added
//
// fh: header file
// fc: C file
//
static void
gen_eval_expand(Gkyl::ModalBasisType type, std::ostream& fh, std::ostream& fc, const Gkyl::ModalBasis& basis)
{
  std::string bn;
  bn = get_basis_name(type);

  int ndim = basis.get_ndim(), polyOrder = basis.get_polyOrder();
  int vdim = basis.get_vdim();

  if (vdim == 0 || (ndim == vdim)) {

    // function declaration
    fh << "GKYL_CU_DH double eval_expand_" << ndim << "d_" << bn << "_" << "p" << polyOrder
       << "(const double *z, const double *f);" << std::endl;  

    // function definition
    fc << "GKYL_CU_DH" << std::endl;
    fc << "double" << std::endl;
    fc << "eval_expand_" << ndim << "d_" << bn << "_" << "p" << polyOrder
         << "(const double *z, const double *f )" << std::endl;
  } else {
    int cdim = ndim-vdim;
    // function declaration
    fh << "GKYL_CU_DH double eval_expand_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
       << "(const double *z, const double *f);" << std::endl;  

    // function definition
    fc << "GKYL_CU_DH" << std::endl;
    fc << "double" << std::endl;
    fc << "eval_expand_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
         << "(const double *z, const double *f )" << std::endl;
  }
  fc << "{" << std::endl;

  // local declarations
  if (polyOrder > 0)
    for (int d=0; d<ndim; ++d)
      fc << "  const double z" << d << " = " << "z[" << d << "];" << std::endl;

  symbol f("f");
  auto f_expand = basis.expand(f);
  // expressions to compute expansion
  fc << "  return " << f_expand.expand().evalf() << ";" << std::endl;
  
  // close function
  fc << "}" << std::endl << std::endl;
}

// Generates function that evaluates gradient given an expansion at a
// point. Generated function signature:
//
// static double foo(int dir, const double *z, const double *f)
//
// Restrict keyword and CUDA attributes are also added
//
// fh: header file
// fc: C file
//
static void
gen_eval_grad_expand(Gkyl::ModalBasisType type, std::ostream& fh, std::ostream& fc, const Gkyl::ModalBasis& basis)
{
  std::string bn;
  bn = get_basis_name(type);

  int ndim = basis.get_ndim(), polyOrder = basis.get_polyOrder();
  int vdim = basis.get_vdim();

  if (vdim == 0 || (ndim == vdim)) {

    // function declaration
    fh << "GKYL_CU_DH double eval_grad_expand_" << ndim << "d_" << bn << "_" << "p" << polyOrder
       << "(int dir, const double *z, const double *f);" << std::endl;  

    // function definition
    fc << "GKYL_CU_DH" << std::endl;
    fc << "double" << std::endl;
    fc << "eval_grad_expand_" << ndim << "d_" << bn << "_" << "p" << polyOrder
         << "(int dir, const double *z, const double *f )" << std::endl;
  } else {
    int cdim = ndim-vdim;
    // function declaration
    fh << "GKYL_CU_DH double eval_grad_expand_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
       << "(int dir, const double *z, const double *f);" << std::endl;  

    // function definition
    fc << "GKYL_CU_DH" << std::endl;
    fc << "double" << std::endl;
    fc << "eval_grad_expand_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
         << "(int dir, const double *z, const double *f )" << std::endl;
  }
  fc << "{" << std::endl;

  // local declarations
  if (polyOrder > 0)
    for (int d=0; d<ndim; ++d)
      fc << "  const double z" << d << " = " << "z[" << d << "];" << std::endl;

  lst vars = basis.get_vars();
  symbol f("f");
  auto f_expand = basis.expand(f);

  for (int d=0; d<ndim; ++d) {
    fc << "  if (dir == " << d << ")" << std::endl;
    // expressions to compute expansion
    auto df = GiNaC::diff(f_expand, basis.get_var(d));
    fc << "    return " << df.expand().evalf() << ";" << std::endl;
    fc << std::endl;
  }

  fc << "  return 0.0; // can't happen, suppresses warning" << std::endl << std::endl;
  // close function
  fc << "}" << std::endl << std::endl;
}

// Generates function that flips sign of odd monomial powers in basis
// expansion. Generated function signature:
//
// static void foo(int dir, const double *fin, double *fout)
//
// Restrict keyword and CUDA attributes are also added
//
// fh: header file
// fc: C file
//
static void
gen_flip_odd_sign(Gkyl::ModalBasisType type,
  std::ostream& fh, std::ostream& fc, const Gkyl::ModalBasis& basis)
{
  std::string bn;
  bn = get_basis_name(type);
  
  int ndim = basis.get_ndim(), polyOrder = basis.get_polyOrder();
  int vdim = basis.get_vdim();

  if (vdim == 0 || (ndim == vdim)) {

    // function declarations
    fh << "GKYL_CU_DH void flip_odd_sign_" << ndim << "d_" << bn << "_" << "p" << polyOrder
         << "(int dir, const double *f, double *fout );" << std::endl;  
  
    // function definition
    fc << "GKYL_CU_DH" << std::endl;
    fc << "void" << std::endl;
    fc << "flip_odd_sign_" << ndim << "d_" << bn << "_" << "p" << polyOrder
         << "(int dir, const double *f, double *fout )" << std::endl;
  } else {
    int cdim = ndim-vdim;
    // function declarations
    fh << "GKYL_CU_DH void flip_odd_sign_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
         << "(int dir, const double *f, double *fout );" << std::endl;  
  
    // function definition
    fc << "GKYL_CU_DH" << std::endl;
    fc << "void" << std::endl;
    fc << "flip_odd_sign_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
         << "(int dir, const double *f, double *fout )" << std::endl;
  }
  fc << "{" << std::endl;
  
  lst vars = basis.get_vars(), bc = basis.get_basis();

  for (int d=0; d<ndim; ++d) {
    exmap m; m[vars[d]] = -vars[d];
    auto bcflip = bc.subs(m);
    lst signs;
    fc << "  if (dir == " << d << ") {" << std::endl;
    for (int i=0; i<basis.get_numbasis(); ++i) {
      auto sign = bcflip[i]/bc[i];
      fc << "    fout[" << i << "] = " << sign << "*" << "f[" << i <<  "];" << std::endl;
    }
    fc << "  }" << std::endl;
  }

  // close function
  fc << "}" << std::endl << std::endl;
}

// Generates function that flips sign of even monomial powers in basis
// expansion. Generated function signature:
//
// static void foo(int dir, const double *fin, double *fout)
//
// Restrict keyword and CUDA attributes are also added
//
// fh: header file
// fc: C file
//
static void
gen_flip_even_sign(Gkyl::ModalBasisType type,
  std::ostream& fh, std::ostream& fc, const Gkyl::ModalBasis& basis)
{
  std::string bn;
  bn = get_basis_name(type);
  
  int ndim = basis.get_ndim(), polyOrder = basis.get_polyOrder();
  int vdim = basis.get_vdim();

  if (vdim == 0 || (ndim == vdim)) {

    // function declarations
    fh << "GKYL_CU_DH void flip_even_sign_" << ndim << "d_" << bn << "_" << "p" << polyOrder
         << "(int dir, const double *f, double *fout );" << std::endl;  

    // function definition
    fc << "GKYL_CU_DH" << std::endl;
    fc << "void" << std::endl;
    fc << "flip_even_sign_" << ndim << "d_" << bn << "_" << "p" << polyOrder
         << "(int dir, const double *f, double *fout )" << std::endl;
  } else {
    int cdim = ndim-vdim;
    // function declarations
    fh << "GKYL_CU_DH void flip_even_sign_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
         << "(int dir, const double *f, double *fout );" << std::endl;  

    // function definition
    fc << "GKYL_CU_DH" << std::endl;
    fc << "void" << std::endl;
    fc << "flip_even_sign_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
         << "(int dir, const double *f, double *fout )" << std::endl;
  }
  fc << "{" << std::endl;
  
  lst vars = basis.get_vars(), bc = basis.get_basis();

  for (int d=0; d<ndim; ++d) {
    exmap m; m[vars[d]] = -vars[d];
    auto bcflip = bc.subs(m);
    lst signs;
    fc << "  if (dir == " << d << ") {" << std::endl;
    for (int i=0; i<basis.get_numbasis(); ++i) {
      auto sign = -bcflip[i]/bc[i];
      fc << "    fout[" << i << "] = " << sign << "*" << "f[" << i <<  "];" << std::endl;
    }
    fc << "  }" << std::endl;
  }

  // close function
  fc << "}" << std::endl << std::endl;  
}

static void
gen_node_coords(Gkyl::ModalBasisType type, std::ostream& fh, std::ostream& fc, const Gkyl::ModalBasis& basis)
{
  std::string bn;
  bn = get_basis_name(type);

  int ndim = basis.get_ndim(), polyOrder = basis.get_polyOrder();
  int vdim = basis.get_vdim();

  if (vdim == 0 || (ndim == vdim)) {

    // function declaration
    fh << "GKYL_CU_DH void node_coords_" << ndim << "d_" << bn << "_" << "p" << polyOrder
       << "(double *node_coords);" << std::endl;

  } else {
    int cdim = ndim-vdim;
    // function declaration
    fh << "GKYL_CU_DH void node_coords_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
       << "(double *node_coords);" << std::endl;
  }

  // C code is not generated here. Need to fix this eventually
}

static void
gen_nodal_to_modal(Gkyl::ModalBasisType type, std::ostream& fh, std::ostream& fc, const Gkyl::ModalBasis& basis)
{
  std::string bn;
  bn = get_basis_name(type);

  int ndim = basis.get_ndim(), polyOrder = basis.get_polyOrder();
  int vdim = basis.get_vdim();

  if (vdim == 0 || (ndim == vdim)) {

    // function declaration
    fh << "GKYL_CU_DH void nodal_to_modal_" << ndim << "d_" << bn << "_" << "p" << polyOrder
       << "(const double *fnodal, double *fmodal);" << std::endl;
  } else {
    int cdim = ndim-vdim;
    // function declaration
    fh << "GKYL_CU_DH void nodal_to_modal_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
       << "(const double *fnodal, double *fmodal);" << std::endl;
  }

  // C code is not generated here. Need to fix this eventually
}

static void
gen_quad_to_modal(Gkyl::ModalBasisType type, std::ostream& fh, std::ostream& fc, const Gkyl::ModalBasis& basis)
{
  std::string bn;
  bn = get_basis_name(type);

  int ndim = basis.get_ndim(), polyOrder = basis.get_polyOrder();
  int vdim = basis.get_vdim();

  if (vdim == 0 || (ndim == vdim)) {

    // function declaration
    fh << "GKYL_CU_DH void quad_to_modal_" << ndim << "d_" << bn << "_" << "p" << polyOrder
       << "(const double *fquad, double *fmodal, long linc2);" << std::endl;
  } else {
    int cdim = ndim-vdim;
    // function declaration
    fh << "GKYL_CU_DH void quad_to_modal_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
       << "(const double *fquad, double *fmodal, long linc2);" << std::endl;
  }

  // C code is not generated here. Need to fix this eventually
}

static void
gen_modal_to_quad(Gkyl::ModalBasisType type, std::ostream& fh, std::ostream& fc, const Gkyl::ModalBasis& basis)
{
  std::string bn;
  bn = get_basis_name(type);

  int ndim = basis.get_ndim(), polyOrder = basis.get_polyOrder();
  int vdim = basis.get_vdim();

  if (vdim == 0 || (ndim == vdim)) {

    // function declaration
    fh << "GKYL_CU_DH void modal_to_quad_" << ndim << "d_" << bn << "_" << "p" << polyOrder
       << "(const double *fmodal, double *fquad, long linc2);" << std::endl;
  } else {
    int cdim = ndim-vdim;
    // function declaration
    fh << "GKYL_CU_DH void modal_to_quad_" << cdim << "x" << vdim << "v_" << bn << "_" << "p" << polyOrder
       << "(const double *fmodal, double *fquad, long linc2);" << std::endl;
  }

  // C code is not generated here. Need to fix this eventually
}

void
gen_ser_basis()
{
  // compute time-stamp
  char buff[70];
  time_t t = time(NULL);
  struct tm curr_tm = *localtime(&t);
  strftime(buff, sizeof buff, "%c", &curr_tm);
  
  int dims[] = { 1, 2, 3, 4, 5, 6 };
  int max_order[] = { 3, 3, 3, 3, 3, 2 };

  symbol z0("z0"), z1("z1"), z2("z2"), z3("z3"), z4("z4"), z5("z5");
  std::vector<symbol> vars { z0, z1, z2, z3, z4, z5 };

  std::ofstream header("kernels/basis/gkyl_basis_ser_kernels.h", std::ofstream::out);
  header << "// " << buff << std::endl;
  header << "#pragma once" << std::endl;
  header << "#include <gkyl_util.h>" << std::endl;
  header << "EXTERN_C_BEG" << std::endl;
  
  std::ofstream eval_file("kernels/basis/basis_eval_ser.c", std::ofstream::out);
  std::ofstream flip_file("kernels/basis/basis_flip_sign_ser.c", std::ofstream::out);

  eval_file << "// " << buff << std::endl;
  eval_file << "#include <gkyl_basis_ser_kernels.h>" << std::endl;

  flip_file << "// " << buff << std::endl;
  flip_file << "#include <gkyl_basis_ser_kernels.h>" << std::endl;

  for (int d=0; d<6; ++d) {
    int dim = dims[d];
    for (int p=0; p<=max_order[d]; ++p) {
      std::cout << dim << "dp" << p << " ";      
      Gkyl::ModalBasis mbasis(Gkyl::MODAL_SER, dim, 0, vars, p);
      
      // generate eval method
      gen_eval(Gkyl::MODAL_SER, header, eval_file, mbasis);
      // generate eval_expand method
      gen_eval_expand(Gkyl::MODAL_SER, header, eval_file, mbasis);
      gen_eval_grad_expand(Gkyl::MODAL_SER, header, eval_file, mbasis);      
      // generate flip_sign method
      gen_flip_odd_sign(Gkyl::MODAL_SER, header, flip_file, mbasis);
      gen_flip_even_sign(Gkyl::MODAL_SER, header, flip_file, mbasis);      
      // generate node_coords
      gen_node_coords(Gkyl::MODAL_SER, header, flip_file, mbasis);
      // generate nodal to modal
      gen_nodal_to_modal(Gkyl::MODAL_SER, header, flip_file, mbasis);
      // generate Gauss-Legendre quadrature nodal to modal
      gen_quad_to_modal(Gkyl::MODAL_SER, header, flip_file, mbasis);
      // generate modal to Gauss-Legendre quadrature nodal 
      gen_modal_to_quad(Gkyl::MODAL_SER, header, flip_file, mbasis);
    }
    std::cout << std::endl;
  }
  header << "EXTERN_C_END" << std::endl;
}

void
gen_hyb_basis()
{
  // compute time-stamp
  char buff[70];
  time_t t = time(NULL);
  struct tm curr_tm = *localtime(&t);
  strftime(buff, sizeof buff, "%c", &curr_tm);
  
  int dims[] = { 1, 2, 3, 4, 5, 6 };
  int max_order[] = { 1, 1, 1, 1, 1, 1 };

  symbol z0("z0"), z1("z1"), z2("z2"), z3("z3"), z4("z4"), z5("z5");
  std::vector<symbol> vars { z0, z1, z2, z3, z4, z5 };

  std::ofstream header("kernels/basis/gkyl_basis_hyb_kernels.h", std::ofstream::out);
  header << "// " << buff << std::endl;
  header << "#pragma once" << std::endl;
  header << "#include <gkyl_util.h>" << std::endl;
  header << "EXTERN_C_BEG" << std::endl;
  
  std::ofstream eval_file("kernels/basis/basis_eval_hyb.c", std::ofstream::out);
  std::ofstream flip_file("kernels/basis/basis_flip_sign_hyb.c", std::ofstream::out);

  eval_file << "// " << buff << std::endl;
  eval_file << "#include <gkyl_basis_hyb_kernels.h>" << std::endl;

  flip_file << "// " << buff << std::endl;
  flip_file << "#include <gkyl_basis_hyb_kernels.h>" << std::endl;

  // All dim combinations needed when one accounts for surface 
  // evaluation, GK and sims that are only kinetic in 1 v-space dir.
  for (int cd=1; cd<4; ++cd) {
    for (int vd=1; vd<4; ++vd) {
      int dim = cd+vd;
      int p = 1;
      std::cout << cd << "x"<< vd << "vp" << p << " ";      
      Gkyl::ModalBasis mbasis(Gkyl::MODAL_HYB, dim, vd, vars, p);
        
      // generate eval method
      gen_eval(Gkyl::MODAL_HYB, header, eval_file, mbasis);
      // generate eval_expand method
      gen_eval_expand(Gkyl::MODAL_HYB, header, eval_file, mbasis);
      gen_eval_grad_expand(Gkyl::MODAL_HYB, header, eval_file, mbasis);
      // generate flip_sign methods
      gen_flip_odd_sign(Gkyl::MODAL_HYB, header, flip_file, mbasis);
      gen_flip_even_sign(Gkyl::MODAL_HYB, header, flip_file, mbasis);
      // generate node_coords
      gen_node_coords(Gkyl::MODAL_HYB, header, flip_file, mbasis);
      // generate nodal to modal
      gen_nodal_to_modal(Gkyl::MODAL_HYB, header, flip_file, mbasis);
      // generate Gauss-Legendre quadrature nodal to modal
      gen_quad_to_modal(Gkyl::MODAL_HYB, header, flip_file, mbasis);
      // generate modal to Gauss-Legendre quadrature nodal 
      gen_modal_to_quad(Gkyl::MODAL_HYB, header, flip_file, mbasis);
      std::cout << std::endl;
    }
  }
  header << "EXTERN_C_END" << std::endl;
}

void
gen_gkhyb_basis()
{
  // compute time-stamp
  char buff[70];
  time_t t = time(NULL);
  struct tm curr_tm = *localtime(&t);
  strftime(buff, sizeof buff, "%c", &curr_tm);
  
  int dims[] = { 1, 2, 3, 4, 5, 6 };
  int max_order[] = { 1, 1, 1, 1, 1, 1 };

  symbol z0("z0"), z1("z1"), z2("z2"), z3("z3"), z4("z4"), z5("z5");
  std::vector<symbol> vars { z0, z1, z2, z3, z4, z5 };

  std::ofstream header("kernels/basis/gkyl_basis_gkhyb_kernels.h", std::ofstream::out);
  header << "// " << buff << std::endl;
  header << "#pragma once" << std::endl;
  header << "#include <gkyl_util.h>" << std::endl;
  header << "EXTERN_C_BEG" << std::endl;
  
  std::ofstream eval_file("kernels/basis/basis_eval_gkhyb.c", std::ofstream::out);
  std::ofstream flip_file("kernels/basis/basis_flip_sign_gkhyb.c", std::ofstream::out);

  eval_file << "// " << buff << std::endl;
  eval_file << "#include <gkyl_basis_gkhyb_kernels.h>" << std::endl;

  flip_file << "// " << buff << std::endl;
  flip_file << "#include <gkyl_basis_gkhyb_kernels.h>" << std::endl;

  for (int cd=1; cd<4; ++cd) {
    for (int vd=std::min(cd,2); vd<3; ++vd) {
      int dim = cd+vd;
      int p = 1;
      std::cout << cd << "x"<< vd << "vp" << p << " ";      
      Gkyl::ModalBasis mbasis(Gkyl::MODAL_GKHYB, dim, vd, vars, p);
        
      // generate eval method
      gen_eval(Gkyl::MODAL_GKHYB, header, eval_file, mbasis);
      // generate eval_expand method
      gen_eval_expand(Gkyl::MODAL_GKHYB, header, eval_file, mbasis);
      gen_eval_grad_expand(Gkyl::MODAL_GKHYB, header, eval_file, mbasis);
      // generate flip_sign methods
      gen_flip_odd_sign(Gkyl::MODAL_GKHYB, header, flip_file, mbasis);
      gen_flip_even_sign(Gkyl::MODAL_GKHYB, header, flip_file, mbasis);
      // generate node_coords
      gen_node_coords(Gkyl::MODAL_GKHYB, header, flip_file, mbasis);
      // generate nodal to modal
      gen_nodal_to_modal(Gkyl::MODAL_GKHYB, header, flip_file, mbasis);
      // generate Gauss-Legendre quadrature nodal to modal
      gen_quad_to_modal(Gkyl::MODAL_GKHYB, header, flip_file, mbasis);
      // generate modal to Gauss-Legendre quadrature nodal 
      gen_modal_to_quad(Gkyl::MODAL_GKHYB, header, flip_file, mbasis);
      std::cout << std::endl;
    }
  }
  header << "EXTERN_C_END" << std::endl;
}

void
gen_gkhyb_vel_basis()
{
  // compute time-stamp
  char buff[70];
  time_t t = time(NULL);
  struct tm curr_tm = *localtime(&t);
  strftime(buff, sizeof buff, "%c", &curr_tm);
  
  int dims[] = { 1, 2, };
  int max_order[] = { 1, 1, };

  symbol z0("z0"), z1("z1");
  std::vector<symbol> vars { z0, z1, };

  std::ofstream header("kernels/basis/gkyl_basis_gkhyb_vel_kernels.h", std::ofstream::out);
  header << "// " << buff << std::endl;
  header << "#pragma once" << std::endl;
  header << "#include <gkyl_util.h>" << std::endl;
  header << "EXTERN_C_BEG" << std::endl;
  
  std::ofstream eval_file("kernels/basis/basis_eval_gkhyb_vel.c", std::ofstream::out);
  std::ofstream flip_file("kernels/basis/basis_flip_sign_gkhyb_vel.c", std::ofstream::out);

  eval_file << "// " << buff << std::endl;
  eval_file << "#include <gkyl_basis_gkhyb_vel_kernels.h>" << std::endl;

  flip_file << "// " << buff << std::endl;
  flip_file << "#include <gkyl_basis_gkhyb_vel_kernels.h>" << std::endl;

  for (int vd=1; vd<3; ++vd) {
    int dim = vd;
    int p = 1;
    std::cout << vd << "vp" << p << " ";      
    Gkyl::ModalBasis mbasis(Gkyl::MODAL_GKHYB_VEL, vd, vd, vars, p);
      
    // generate eval method
    gen_eval(Gkyl::MODAL_GKHYB_VEL, header, eval_file, mbasis);
    // generate eval_expand method
    gen_eval_expand(Gkyl::MODAL_GKHYB_VEL, header, eval_file, mbasis);
    gen_eval_grad_expand(Gkyl::MODAL_GKHYB_VEL, header, eval_file, mbasis);
    // generate flip_sign methods
    gen_flip_odd_sign(Gkyl::MODAL_GKHYB_VEL, header, flip_file, mbasis);
    gen_flip_even_sign(Gkyl::MODAL_GKHYB_VEL, header, flip_file, mbasis);
    // generate node_coords
    gen_node_coords(Gkyl::MODAL_GKHYB_VEL, header, flip_file, mbasis);
    // generate nodal to modal
    gen_nodal_to_modal(Gkyl::MODAL_GKHYB_VEL, header, flip_file, mbasis);
    // generate Gauss-Legendre quadrature nodal to modal
    gen_quad_to_modal(Gkyl::MODAL_GKHYB_VEL, header, flip_file, mbasis);
    // generate modal to Gauss-Legendre quadrature nodal 
    gen_modal_to_quad(Gkyl::MODAL_GKHYB_VEL, header, flip_file, mbasis);
    std::cout << std::endl;
  }
  
  header << "EXTERN_C_END" << std::endl;
}

void
gen_ten_basis()
{
  // compute time-stamp
  char buff[70];
  time_t t = time(NULL);
  struct tm curr_tm = *localtime(&t);
  strftime(buff, sizeof buff, "%c", &curr_tm);
  
  int dims[] = { 2, 3, 4, 5 };
  int max_order[] = { 3, 2, 2, 2 };

  symbol z0("z0"), z1("z1"), z2("z2"), z3("z3"), z4("z4"), z5("z5");
  std::vector<symbol> vars { z0, z1, z2, z3, z4, z5 };

  std::ofstream header("kernels/basis/gkyl_basis_tensor_kernels.h", std::ofstream::out);
  header << "// " << buff << std::endl;
  header << "#pragma once" << std::endl;
  header << "#include <gkyl_util.h>" << std::endl;
  header << "EXTERN_C_BEG" << std::endl;
  
  std::ofstream eval_file("kernels/basis/basis_eval_tensor.c", std::ofstream::out);
  std::ofstream flip_file("kernels/basis/basis_flip_sign_tensor.c", std::ofstream::out);

  eval_file << "// " << buff << std::endl;
  eval_file << "#include <gkyl_basis_tensor_kernels.h>" << std::endl;

  flip_file << "// " << buff << std::endl;
  flip_file << "#include <gkyl_basis_tensor_kernels.h>" << std::endl;

  for (int d=0; d<4; ++d) {
    int dim = dims[d];
    for (int p=2; p<=max_order[d]; ++p) {
      std::cout << dim << "dp" << p << " ";      
      Gkyl::ModalBasis mbasis(Gkyl::MODAL_TEN, dim, 0, vars, p);
      
      // generate eval method
      gen_eval(Gkyl::MODAL_TEN, header, eval_file, mbasis);
      // generate eval expansion method
      gen_eval_expand(Gkyl::MODAL_TEN, header, eval_file, mbasis);
      gen_eval_grad_expand(Gkyl::MODAL_TEN, header, eval_file, mbasis);
      // generate flip_sign method
      gen_flip_odd_sign(Gkyl::MODAL_TEN, header, flip_file, mbasis);
      gen_flip_even_sign(Gkyl::MODAL_TEN, header, flip_file, mbasis);
      // generate node_coords
      gen_node_coords(Gkyl::MODAL_TEN, header, flip_file, mbasis);
      // generate nodal to modal
      gen_nodal_to_modal(Gkyl::MODAL_TEN, header, flip_file, mbasis);
      // generate Gauss-Legendre quadrature nodal to modal
      gen_quad_to_modal(Gkyl::MODAL_TEN, header, flip_file, mbasis);
      // generate modal to Gauss-Legendre quadrature nodal 
      gen_modal_to_quad(Gkyl::MODAL_TEN, header, flip_file, mbasis);
    }
    std::cout << std::endl;
  }
  header << "EXTERN_C_END" << std::endl;
}

int
main(int argc, char **argv)
{
  struct timespec tstart = gkyl_wall_clock();
  gen_ser_basis();
  double tm = gkyl_time_diff_now_sec(tstart);
  std::cout << "Generating of modal serendipity basis took " << tm << " seconds" << std::endl;
  
  tstart = gkyl_wall_clock();
  gen_ten_basis();
  tm = gkyl_time_diff_now_sec(tstart);
  std::cout << "Generating of modal tensor basis took " << tm << " seconds" << std::endl;

  tstart = gkyl_wall_clock();
  gen_hyb_basis();
  tm = gkyl_time_diff_now_sec(tstart);
  std::cout << "Generating of modal hybrid basis took " << tm << " seconds" << std::endl;
  
  tstart = gkyl_wall_clock();
  gen_gkhyb_basis();
  tm = gkyl_time_diff_now_sec(tstart);
  std::cout << "Generating of modal gk hybrid basis took " << tm << " seconds" << std::endl;
  
  tstart = gkyl_wall_clock();
  gen_gkhyb_vel_basis();
  tm = gkyl_time_diff_now_sec(tstart);
  std::cout << "Generating of modal gk hybrid vel basis took " << tm << " seconds" << std::endl;
  
  return 1;
}
