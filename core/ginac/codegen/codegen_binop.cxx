#include <modal_basis.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <gkyl_util.h>

using namespace GiNaC;

static struct gkyl_kern_op_count
total_op(const ex& expr)
{
  struct gkyl_kern_op_count count = { 0 };

  count.num_sum = expr.nops()-1;
  for (int i=0; i<expr.nops(); ++i)
    count.num_prod += expr.op(i).nops()-1;

  return count;
}

static void
gen_ser_mul_op(std::ostream& fh, std::ostream& fc, const Gkyl::ModalBasis& basis)
{
  int ndim = basis.get_ndim(), polyOrder = basis.get_polyOrder();
  lst bc = basis.get_basis();
  
  // function declaration
  fh << std::endl
     << "GKYL_CU_DH void binop_mul_" << ndim << "d_ser_" << "p" << polyOrder
     << "(const double *f, const double *g, double *fg );" << std::endl;

  // declare function returning op counts
  fh << "struct gkyl_kern_op_count op_count_binop_mul_" << ndim << "d_ser_" << "p" << polyOrder
     << "(void);" << std::endl;

  // function definition
  fc << "GKYL_CU_DH" << std::endl;
  fc << "void" << std::endl;
  fc << "binop_mul_" << ndim << "d_ser_" << "p" << polyOrder
       << "(const double *f, const double *g, double *fg )" << std::endl;
  fc << "{" << std::endl;  
  fc << "  double tmp[" << basis.get_numbasis() << "] = {0.};" << std::endl;

  int nsum = 0, nprod = 0;
  symbol f("f"), g("g");
  auto fg = basis.expand(f)*basis.expand(g);

  for (int i=0; i<basis.get_numbasis(); ++i) {
    std::cout << i << " " << std::flush;
    auto out = basis.innerProd(bc[i], fg).expand().evalf();
    fc << "  tmp[" << i << "] = " << csrc << out << ";" << std::endl;
    struct gkyl_kern_op_count count = total_op(out);
    nsum += count.num_sum;
    nprod += count.num_prod;
  }
  std::cout << std::endl;
  fc << " " << std::endl;

  for (int i=0; i<basis.get_numbasis(); ++i) {
    std::cout << i << " " << std::flush;
    fc << "  fg[" << i << "] = tmp[" << i << "];" << std::endl;
  }
  std::cout << std::endl;

  fc << "  // nsum = " << nsum << ", nprod = " << nprod << std::endl;
  // close function
  fc << "}" << std::endl << std::endl;

  // write out function to return op counts
  fc << "struct gkyl_kern_op_count op_count_binop_mul_" << ndim << "d_ser_" << "p" << polyOrder
     << "(void)" << std::endl;
  fc << "{" << std::endl;
  fc << "  return (struct gkyl_kern_op_count) { .num_sum = " << nsum << ", .num_prod = " << nprod
     << " };" << std::endl;
  fc << "}" << std::endl;
}

static void
gen_ser_cross_mul_op(std::ostream& fh, std::ostream& fc,
  const Gkyl::ModalBasis& ba, const Gkyl::ModalBasis& bb)
{
  int polyOrder = ba.get_polyOrder();
  int a_ndim = ba.get_ndim();
  int b_ndim = bb.get_ndim();
  
  lst bc = bb.get_basis(); // projection is on basis function bb
  
  // function declaration
  fh << std::endl
     << "GKYL_CU_DH void binop_cross_mul_" << a_ndim << "d_" << b_ndim << "d_ser_" << "p" << polyOrder
     << "(const double *f, const double *g, double *fg );" << std::endl;

  // function definition
  fc << "GKYL_CU_DH" << std::endl;
  fc << "void" << std::endl;
  fc << "binop_cross_mul_" << a_ndim << "d_" << b_ndim << "d_ser_" << "p" << polyOrder
       << "(const double *f, const double *g, double *fg )" << std::endl;
  fc << "{" << std::endl;
  fc << "  double tmp[" << bb.get_numbasis() << "] = {0.};" << std::endl;

  symbol f("f"), g("g");
  auto fg = ba.expand(f)*bb.expand(g);

  for (int i=0; i<bb.get_numbasis(); ++i) {
    std::cout << i << " " << std::flush;
    auto out = bb.innerProd(bc[i], fg).expand().evalf();
    fc << "  tmp[" << i << "] = " << csrc << out << ";" << std::endl;
  }
  std::cout << std::endl;  
  fc << "  double tmp[" << bb.get_numbasis() << "] = {0.};" << std::endl;
  fc << " " << std::endl;

  for (int i=0; i<bb.get_numbasis(); ++i) {
    std::cout << i << " " << std::flush;
    fc << "  fg[" << i << "] = " << "tmp[" << i << "];" << std::endl;
  }
  std::cout << std::endl;  

  // close function
  fc << "}" << std::endl << std::endl;

}

static void
gen_hyb_cross_mul_op(std::ostream& fh, std::ostream& fc,
  const Gkyl::ModalBasis& ba, const Gkyl::ModalBasis& bb)
{
  int polyOrder = ba.get_polyOrder();
  int cdim = ba.get_ndim();
  int pdim = bb.get_ndim();
  int vdim = pdim-cdim;
  
  lst bc = bb.get_basis(); // projection is on basis function bb
  
  // function declaration
  fh << std::endl
     << "GKYL_CU_DH void binop_cross_mul_" << cdim << "x" << vdim << "v_hyb_" << "p" << polyOrder
     << "(const double *f, const double *g, double *fg );" << std::endl;

  // function definition
  fc << "GKYL_CU_DH" << std::endl;
  fc << "void" << std::endl;
  fc << "binop_cross_mul_" << cdim << "x" << vdim << "v_hyb_" << "p" << polyOrder
       << "(const double *f, const double *g, double *fg )" << std::endl;
  fc << "{" << std::endl;
  fc << "  double tmp[" << bb.get_numbasis() << "] = {0.};" << std::endl;

  symbol f("f"), g("g");
  auto fg = ba.expand(f)*bb.expand(g);

  for (int i=0; i<bb.get_numbasis(); ++i) {
    std::cout << i << " " << std::flush;
    auto out = bb.innerProd(bc[i], fg).expand().evalf();
    fc << "  tmp[" << i << "] = " << csrc << out << ";" << std::endl;
  }
  std::cout << std::endl;  
  fc << " " << std::endl;

  for (int i=0; i<bb.get_numbasis(); ++i) {
    std::cout << i << " " << std::flush;
    fc << "  fg[" << i << "] = " << "tmp[" << i << "];" << std::endl;
  }
  std::cout << std::endl;  

  // close function
  fc << "}" << std::endl << std::endl;

}

static void
gen_gkhyb_cross_mul_op(std::ostream& fh, std::ostream& fc,
  const Gkyl::ModalBasis& ba, const Gkyl::ModalBasis& bb)
{
  int polyOrder = ba.get_polyOrder();
  int cdim = ba.get_ndim();
  int pdim = bb.get_ndim();
  int vdim = pdim - cdim;
  
  lst bc = bb.get_basis(); // projection is on basis function bb
  
  // function declaration
  fh << std::endl
     << "GKYL_CU_DH void binop_cross_mul_" << cdim << "x" << vdim << "v_gkhyb_" << "p" << polyOrder
     << "(const double *f, const double *g, double *fg );" << std::endl;

  // function definition
  fc << "GKYL_CU_DH" << std::endl;
  fc << "void" << std::endl;
  fc << "binop_cross_mul_" << cdim << "x" << vdim << "v_gkhyb_" << "p" << polyOrder
       << "(const double *f, const double *g, double *fg )" << std::endl;
  fc << "{" << std::endl;
  fc << "  double tmp[" << bb.get_numbasis() << "] = {0.};" << std::endl;

  symbol f("f"), g("g");
  auto fg = ba.expand(f)*bb.expand(g);

  for (int i=0; i<bb.get_numbasis(); ++i) {
    std::cout << i << " " << std::flush;
    auto out = bb.innerProd(bc[i], fg).expand().evalf();
    fc << "  tmp[" << i << "] = " << csrc << out << ";" << std::endl;
  }
  std::cout << std::endl;  
  fc << " " << std::endl;

  for (int i=0; i<bb.get_numbasis(); ++i) {
    std::cout << i << " " << std::flush;
    fc << "  fg[" << i << "] = " << "tmp[" << i << "];" << std::endl;
  }
  std::cout << std::endl;  

  // close function
  fc << "}" << std::endl << std::endl;

}

void
gen_all_ser_mul_op()
{
  // compute time-stamp
  char buff[70];
  time_t t = time(NULL);
  struct tm curr_tm = *localtime(&t);
  strftime(buff, sizeof buff, "%c", &curr_tm);
  
  int dims[] = { 1, 2, 3 };
  int max_order[] = { 3, 3, 3 };

  symbol z0("z0"), z1("z1"), z2("z2"), z3("z3"), z4("z4"), z5("z5");
  std::vector<symbol> vars { z0, z1, z2, z3, z4, z5 };

  std::ofstream mul_file_h("kernels/bin_op/gkyl_binop_mul_ser.h", std::ofstream::out);
  mul_file_h << "// " << buff << std::endl;
  mul_file_h << "#pragma once" << std::endl;
  mul_file_h << "#include <gkyl_util.h>" << std::endl;
  mul_file_h << "EXTERN_C_BEG" << std::endl;
  
  struct timespec tstart = gkyl_wall_clock();

  for (int d=0; d<3; ++d) {
    int dim = dims[d];
    for (int p=0; p<=max_order[d]; ++p) {
      std::cout << dim << "dp" << p << " " << std::flush;
      Gkyl::ModalBasis mbasis(Gkyl::MODAL_SER, dim, 0, vars, p);

      // each function is written to its own file to allow building
      // kernels in parallel
      std::ostringstream fn;
      fn << "kernels/bin_op/binop_mul_" << dim << "d_ser_" << "p" << p << ".c";
      std::ofstream mul_file_c(fn.str().c_str(), std::ofstream::out);
      mul_file_c << "// " << buff << std::endl;
      mul_file_c << "#include <gkyl_binop_mul_ser.h>" << std::endl;
      
      // generate multiply method
      gen_ser_mul_op(mul_file_h, mul_file_c, mbasis);
    }
    std::cout << std::endl;
  }

  mul_file_h << "EXTERN_C_END" << std::endl;

  double tm = gkyl_time_diff_now_sec(tstart);
  std::cout << "Took " << tm << " seconds" << std::endl;  
}

void
gen_all_ser_cross_mul_op()
{
  // compute time-stamp
  char buff[70];
  time_t t = time(NULL);
  struct tm curr_tm = *localtime(&t);
  strftime(buff, sizeof buff, "%c", &curr_tm);
  
  int a_dims[] = { 1, 2, 3 };
  int max_order[] = { 3, 2, 2 };

  symbol z0("z0"), z1("z1"), z2("z2"), z3("z3"), z4("z4"), z5("z5");
  std::vector<symbol> vars { z0, z1, z2, z3, z4, z5 };

  std::ofstream mul_file_h("kernels/bin_op/gkyl_binop_cross_mul_ser.h", std::ofstream::out);
  mul_file_h << "// " << buff << std::endl;
  mul_file_h << "#pragma once" << std::endl;
  mul_file_h << "#include <gkyl_util.h>" << std::endl;
  mul_file_h << "EXTERN_C_BEG" << std::endl;
  
  struct timespec tstart = gkyl_wall_clock();

  for (int da=0; da<3; ++da) {
    std::cout << std::endl;

    int a_dim = a_dims[da];
    for (int p=0; p<=max_order[da]; ++p) {
      for (int b_dim=2*a_dim; b_dim<=a_dim+3; ++b_dim) {
        std::cout << a_dim << "d" << b_dim <<  "d" << "p" << p << " " << std::flush;

        Gkyl::ModalBasis m1(Gkyl::MODAL_SER, a_dim, 0, vars, p);
        Gkyl::ModalBasis m2(Gkyl::MODAL_SER, b_dim, 0, vars, p);

        // each function is written to its own file to allow building
        // kernels in parallel
        std::ostringstream fn;
        fn << "kernels/bin_op/binop_cross_mul_" << a_dim << "d_" << b_dim << "d_ser_" << "p" << p << ".c";
        std::ofstream mul_file_c(fn.str().c_str(), std::ofstream::out);
        mul_file_c << "// " << buff << std::endl;
        mul_file_c << "#include <gkyl_binop_cross_mul_ser.h>" << std::endl;
        
        // generate multiply method
        gen_ser_cross_mul_op(mul_file_h, mul_file_c, m1, m2);
      }

      // Include a 3d x 5d multiplication for gyrokinetics:
      if (a_dim == 3) {
        int b_dim = 5;
        std::cout << a_dim << "d" << b_dim <<  "d" << "p" << p << " " << std::flush;

        Gkyl::ModalBasis m1(Gkyl::MODAL_SER, a_dim, 0, vars, p);
        Gkyl::ModalBasis m2(Gkyl::MODAL_SER, b_dim, 0, vars, p);

        // each function is written to its own file to allow building
        // kernels in parallel
        std::ostringstream fn;
        fn << "kernels/bin_op/binop_cross_mul_" << a_dim << "d_" << b_dim << "d_ser_" << "p" << p << ".c";
        std::ofstream mul_file_c(fn.str().c_str(), std::ofstream::out);
        mul_file_c << "// " << buff << std::endl;
        mul_file_c << "#include <gkyl_binop_cross_mul_ser.h>" << std::endl;
        
        // generate multiply method
        gen_ser_cross_mul_op(mul_file_h, mul_file_c, m1, m2);
      }
    }


    std::cout << std::endl;
  }

  mul_file_h << "EXTERN_C_END" << std::endl;

  double tm = gkyl_time_diff_now_sec(tstart);
  std::cout << "Took " << tm << " seconds" << std::endl;  
}

void
gen_all_hyb_cross_mul_op()
{
  // compute time-stamp
  char buff[70];
  time_t t = time(NULL);
  struct tm curr_tm = *localtime(&t);
  strftime(buff, sizeof buff, "%c", &curr_tm);
  
  int a_dims[] = { 1, 2, 3 };

  symbol z0("z0"), z1("z1"), z2("z2"), z3("z3"), z4("z4"), z5("z5");
  std::vector<symbol> vars { z0, z1, z2, z3, z4, z5 };

  std::ofstream mul_file_h("kernels/bin_op/gkyl_binop_cross_mul_hyb.h", std::ofstream::out);
  mul_file_h << "// " << buff << std::endl;
  mul_file_h << "#pragma once" << std::endl;
  mul_file_h << "#include <gkyl_util.h>" << std::endl;
  mul_file_h << "EXTERN_C_BEG" << std::endl;
  
  struct timespec tstart = gkyl_wall_clock();

  for (int da=0; da<3; ++da) {
    std::cout << std::endl;

    int a_dim = a_dims[da];
    int p = 1;
    // Include all combinations to account for gyrokinetics and models that are
    // kinetic in only one velocity direction.
    for (int b_dim=a_dim+1; b_dim<=a_dim+3; ++b_dim) {
      int vdim = b_dim-a_dim;

      std::cout << a_dim <<  "x" << vdim << "v" << "p" << p << " " << std::flush;

      Gkyl::ModalBasis m1(Gkyl::MODAL_SER, a_dim, 0, vars, p);
      Gkyl::ModalBasis m2(Gkyl::MODAL_HYB, b_dim, vdim, vars, p);

      // each function is written to its own file to allow building
      // kernels in parallel
      std::ostringstream fn;
      fn << "kernels/bin_op/binop_cross_mul_" << a_dim << "x" << vdim << "v_hyb_" << "p" << p << ".c";
      std::ofstream mul_file_c(fn.str().c_str(), std::ofstream::out);
      mul_file_c << "// " << buff << std::endl;
      mul_file_c << "#include <gkyl_binop_cross_mul_hyb.h>" << std::endl;
      
      // generate multiply method
      gen_hyb_cross_mul_op(mul_file_h, mul_file_c, m1, m2);
    }

    std::cout << std::endl;
  }

  mul_file_h << "EXTERN_C_END" << std::endl;

  double tm = gkyl_time_diff_now_sec(tstart);
  std::cout << "Took " << tm << " seconds" << std::endl;  
}

void
gen_all_gkhyb_cross_mul_op()
{
  // compute time-stamp
  char buff[70];
  time_t t = time(NULL);
  struct tm curr_tm = *localtime(&t);
  strftime(buff, sizeof buff, "%c", &curr_tm);
  
  int a_dims[] = { 1, 2, 3 };

  symbol z0("z0"), z1("z1"), z2("z2"), z3("z3"), z4("z4"), z5("z5");
  std::vector<symbol> vars { z0, z1, z2, z3, z4, z5 };

  std::ofstream mul_file_h("kernels/bin_op/gkyl_binop_cross_mul_gkhyb.h", std::ofstream::out);
  mul_file_h << "// " << buff << std::endl;
  mul_file_h << "#pragma once" << std::endl;
  mul_file_h << "#include <gkyl_util.h>" << std::endl;
  mul_file_h << "EXTERN_C_BEG" << std::endl;
  
  struct timespec tstart = gkyl_wall_clock();

  for (int da=0; da<3; ++da) {
    std::cout << std::endl;

    int a_dim = a_dims[da];
    int p = 1;
    // Include all combinations to account for gyrokinetics and models that are
    // kinetic in only one velocity direction.
    for (int b_dim=a_dim+std::min(a_dim,2); b_dim<=a_dim+2; ++b_dim) {
      int vdim = b_dim-a_dim;

      std::cout << a_dim <<  "x" << vdim << "v" << "p" << p << " " << std::flush;

      Gkyl::ModalBasis m1(Gkyl::MODAL_SER, a_dim, 0, vars, p);
      Gkyl::ModalBasis m2(Gkyl::MODAL_GKHYB, b_dim, vdim, vars, p);

      // each function is written to its own file to allow building
      // kernels in parallel
      std::ostringstream fn;
      fn << "kernels/bin_op/binop_cross_mul_" << a_dim << "x" << vdim << "v_gkhyb_" << "p" << p << ".c";
      std::ofstream mul_file_c(fn.str().c_str(), std::ofstream::out);
      mul_file_c << "// " << buff << std::endl;
      mul_file_c << "#include <gkyl_binop_cross_mul_gkhyb.h>" << std::endl;
      
      // generate multiply method
      gen_gkhyb_cross_mul_op(mul_file_h, mul_file_c, m1, m2);
    }

    std::cout << std::endl;
  }

  mul_file_h << "EXTERN_C_END" << std::endl;

  double tm = gkyl_time_diff_now_sec(tstart);
  std::cout << "Took " << tm << " seconds" << std::endl;  
}

int
main(int argc, char **argv)
{
  gen_all_ser_mul_op();
  gen_all_ser_cross_mul_op();
  gen_all_hyb_cross_mul_op();
  gen_all_gkhyb_cross_mul_op();
  
  return 1;
}
