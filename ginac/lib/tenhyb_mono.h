#pragma once
#include <vector>
#include <ginac/ginac.h>

// Tensor-hybrid basis monomials: tensor product of p=1 tensor in
// configuration space and p=2 tensor in velocity space (2^cdim*3^vdim
// monomials), ordered following the 6D p=2 tensor monomial ordering
// (basis-pre-calc-tensorhybrid.mac; dumped by calcTensorHybMonoList).
GiNaC::lst tenhyb_1x1v_p1(const std::vector<GiNaC::symbol> &vars);
GiNaC::lst tenhyb_1x2v_p1(const std::vector<GiNaC::symbol> &vars);
GiNaC::lst tenhyb_1x3v_p1(const std::vector<GiNaC::symbol> &vars);
GiNaC::lst tenhyb_2x1v_p1(const std::vector<GiNaC::symbol> &vars);
GiNaC::lst tenhyb_2x2v_p1(const std::vector<GiNaC::symbol> &vars);
GiNaC::lst tenhyb_2x3v_p1(const std::vector<GiNaC::symbol> &vars);
GiNaC::lst tenhyb_3x1v_p1(const std::vector<GiNaC::symbol> &vars);
GiNaC::lst tenhyb_3x2v_p1(const std::vector<GiNaC::symbol> &vars);
GiNaC::lst tenhyb_3x3v_p1(const std::vector<GiNaC::symbol> &vars);
