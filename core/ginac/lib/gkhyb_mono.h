#pragma once

#include <ginac/ginac.h>

// 1x1v
GiNaC::lst gkhyb_1x1v_p1(const std::vector<GiNaC::symbol> &vars);
// 1x2v
GiNaC::lst gkhyb_1x2v_p1(const std::vector<GiNaC::symbol> &vars);
// 2x2v
GiNaC::lst gkhyb_2x2v_p1(const std::vector<GiNaC::symbol> &vars);
// 3x2v
GiNaC::lst gkhyb_3x2v_p1(const std::vector<GiNaC::symbol>& vars);
