#include "tensor_mono.h"

GiNaC::lst
tensor_2x_p2(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1];
  auto x2 = x*x;
  auto y2 = y*y;
  
  GiNaC::lst l { 1,x,y,x*y,x2,y2,x2*y,x*y2,x2*y2 };
  return l;
}

GiNaC::lst
tensor_2x_p3(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1];

  auto x2 = x*x;
  auto y2 = y*y;
  auto x3 = x*x*x;
  auto y3 = y*y*y;
  
  GiNaC::lst l { 1,x,y,x*y,x2,y2,x2*y,x*y2,x3,y3,x2*y2,x3*y,x*y3,x3*y2,x2*y3,x3*y3 };
  return l;
}

GiNaC::lst
tensor_3x_p2(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2];
  auto x2 = x*x;
  auto y2 = y*y;
  auto z2 = z*z;

  GiNaC::lst l { 1,x,y,z,x*y,x*z,y*z,x2,y2,z2,x*y*z,x2*y,x*y2,x2*z,y2*z,x*z2,y*z2,x2*y*z,x*y2*z,x*y*z2,x2*y2,x2*z2,y2*z2,x2*y2*z,x2*y*z2,x*y2*z2,x2*y2*z2  };
  return l;
}

GiNaC::lst
tensor_4x_p2(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], u = vars[3];
  auto x2 = x*x;
  auto y2 = y*y;
  auto z2 = z*z;
  auto u2 = u*u;

  GiNaC::lst l { 1,x,y,z,u,x*y,x*z,y*z,u*x,u*y,u*z,x2,y2,z2,u2,x*y*z,u*x*y,u*x*z,u*y*z,x2*y,x*y2,x2*z,y2*z,x*z2,y*z2,u*x2,u*y2,u*z2,u2*x,u2*y,u2*z,u*x*y*z,x2*y*z,x*y2*z,x*y*z2,u*x2*y,u*x*y2,u*x2*z,u*y2*z,u*x*z2,u*y*z2,u2*x*y,u2*x*z,u2*y*z,x2*y2,x2*z2,y2*z2,u2*x2,u2*y2,u2*z2,u*x2*y*z,u*x*y2*z,u*x*y*z2,u2*x*y*z,x2*y2*z,x2*y*z2,x*y2*z2,u*x2*y2,u*x2*z2,u*y2*z2,u2*x2*y,u2*x*y2,u2*x2*z,u2*y2*z,u2*x*z2,u2*y*z2,u*x2*y2*z,u*x2*y*z2,u*x*y2*z2,u2*x2*y*z,u2*x*y2*z,u2*x*y*z2,x2*y2*z2,u2*x2*y2,u2*x2*z2,u2*y2*z2,u*x2*y2*z2,u2*x2*y2*z,u2*x2*y*z2,u2*x*y2*z2,u2*x2*y2*z2 };
  return l;
}

GiNaC::lst
tensor_5x_p2(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], u = vars[3], v = vars[4];
  auto x2 = x*x;
  auto y2 = y*y;
  auto z2 = z*z;
  auto u2 = u*u;
  auto v2 = v*v;

  GiNaC::lst l { 1,x,y,z,u,v,x*y,x*z,y*z,u*x,u*y,u*z,v*x,v*y,v*z,u*v,x2,y2,z2,u2,v2,x*y*z,u*x*y,u*x*z,u*y*z,v*x*y,v*x*z,v*y*z,u*v*x,u*v*y,u*v*z,x2*y,x*y2,x2*z,y2*z,x*z2,y*z2,u*x2,u*y2,u*z2,u2*x,u2*y,u2*z,v*x2,v*y2,v*z2,u2*v,v2*x,v2*y,v2*z,u*v2,u*x*y*z,v*x*y*z,u*v*x*y,u*v*x*z,u*v*y*z,x2*y*z,x*y2*z,x*y*z2,u*x2*y,u*x*y2,u*x2*z,u*y2*z,u*x*z2,u*y*z2,u2*x*y,u2*x*z,u2*y*z,v*x2*y,v*x*y2,v*x2*z,v*y2*z,v*x*z2,v*y*z2,u*v*x2,u*v*y2,u*v*z2,u2*v*x,u2*v*y,u2*v*z,v2*x*y,v2*x*z,v2*y*z,u*v2*x,u*v2*y,u*v2*z,x2*y2,x2*z2,y2*z2,u2*x2,u2*y2,u2*z2,v2*x2,v2*y2,v2*z2,u2*v2,u*v*x*y*z,u*x2*y*z,u*x*y2*z,u*x*y*z2,u2*x*y*z,v*x2*y*z,v*x*y2*z,v*x*y*z2,u*v*x2*y,u*v*x*y2,u*v*x2*z,u*v*y2*z,u*v*x*z2,u*v*y*z2,u2*v*x*y,u2*v*x*z,u2*v*y*z,v2*x*y*z,u*v2*x*y,u*v2*x*z,u*v2*y*z,x2*y2*z,x2*y*z2,x*y2*z2,u*x2*y2,u*x2*z2,u*y2*z2,u2*x2*y,u2*x*y2,u2*x2*z,u2*y2*z,u2*x*z2,u2*y*z2,v*x2*y2,v*x2*z2,v*y2*z2,u2*v*x2,u2*v*y2,u2*v*z2,v2*x2*y,v2*x*y2,v2*x2*z,v2*y2*z,v2*x*z2,v2*y*z2,u*v2*x2,u*v2*y2,u*v2*z2,u2*v2*x,u2*v2*y,u2*v2*z,u*v*x2*y*z,u*v*x*y2*z,u*v*x*y*z2,u2*v*x*y*z,u*v2*x*y*z,u*x2*y2*z,u*x2*y*z2,u*x*y2*z2,u2*x2*y*z,u2*x*y2*z,u2*x*y*z2,v*x2*y2*z,v*x2*y*z2,v*x*y2*z2,u*v*x2*y2,u*v*x2*z2,u*v*y2*z2,u2*v*x2*y,u2*v*x*y2,u2*v*x2*z,u2*v*y2*z,u2*v*x*z2,u2*v*y*z2,v2*x2*y*z,v2*x*y2*z,v2*x*y*z2,u*v2*x2*y,u*v2*x*y2,u*v2*x2*z,u*v2*y2*z,u*v2*x*z2,u*v2*y*z2,u2*v2*x*y,u2*v2*x*z,u2*v2*y*z,x2*y2*z2,u2*x2*y2,u2*x2*z2,u2*y2*z2,v2*x2*y2,v2*x2*z2,v2*y2*z2,u2*v2*x2,u2*v2*y2,u2*v2*z2,u*v*x2*y2*z,u*v*x2*y*z2,u*v*x*y2*z2,u2*v*x2*y*z,u2*v*x*y2*z,u2*v*x*y*z2,u*v2*x2*y*z,u*v2*x*y2*z,u*v2*x*y*z2,u2*v2*x*y*z,u*x2*y2*z2,u2*x2*y2*z,u2*x2*y*z2,u2*x*y2*z2,v*x2*y2*z2,u2*v*x2*y2,u2*v*x2*z2,u2*v*y2*z2,v2*x2*y2*z,v2*x2*y*z2,v2*x*y2*z2,u*v2*x2*y2,u*v2*x2*z2,u*v2*y2*z2,u2*v2*x2*y,u2*v2*x*y2,u2*v2*x2*z,u2*v2*y2*z,u2*v2*x*z2,u2*v2*y*z2,u*v*x2*y2*z2,u2*v*x2*y2*z,u2*v*x2*y*z2,u2*v*x*y2*z2,u*v2*x2*y2*z,u*v2*x2*y*z2,u*v2*x*y2*z2,u2*v2*x2*y*z,u2*v2*x*y2*z,u2*v2*x*y*z2,u2*x2*y2*z2,v2*x2*y2*z2,u2*v2*x2*y2,u2*v2*x2*z2,u2*v2*y2*z2,u2*v*x2*y2*z2,u*v2*x2*y2*z2,u2*v2*x2*y2*z,u2*v2*x2*y*z2,u2*v2*x*y2*z2,u2*v2*x2*y2*z2 };
  return l;
}
