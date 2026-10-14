#pragma once

#include <ginac/ginac.h>

GiNaC::lst tensor_2x_p2(const std::vector<GiNaC::symbol> &vars);

GiNaC::lst tensor_2x_p3(const std::vector<GiNaC::symbol>& vars);

GiNaC::lst tensor_3x_p2(const std::vector<GiNaC::symbol>& vars);

GiNaC::lst tensor_4x_p2(const std::vector<GiNaC::symbol>& vars);

GiNaC::lst tensor_5x_p2(const std::vector<GiNaC::symbol>& vars);
