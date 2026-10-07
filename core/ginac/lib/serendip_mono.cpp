#include "serendip_mono.h"

GiNaC::lst
serendip_1x_p0(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::lst l { 1 };
  return l;
}
GiNaC::lst
serendip_1x_p1(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0];
  GiNaC::lst l { 1, x };
  return l;  
}
GiNaC::lst
serendip_1x_p2(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0];
  GiNaC::lst l { 1, x, x*x };
    return l;
}
GiNaC::lst
serendip_1x_p3(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0];
  GiNaC::lst l { 1, x, x*x, x*x*x };
  return l;
}

GiNaC::lst
serendip_2x_p0(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::lst l { 1 };
  return l;
}
GiNaC::lst
serendip_2x_p1(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1];
  GiNaC::lst l { 1, x, y, x*y };
  return l;  
}
GiNaC::lst
serendip_2x_p2(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1];
  GiNaC::lst l { 1,x,y,x*y,x*x,y*y,x*x*y,x*y*y };
  return l;
}
GiNaC::lst
serendip_2x_p3(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1];
  GiNaC::lst l { 1,x,y,x*y,x*x,y*y,x*x*y,x*y*y,x*x*x,y*y*y,x*x*x*y,x*y*y*y };
  return l;
}

GiNaC::lst
serendip_3x_p0(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::lst l { 1 };
  return l;
}
GiNaC::lst
serendip_3x_p1(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2];
  GiNaC::lst l { 1,x,y,z,x*y,x*z,y*z,x*y*z };
  return l;  
}
GiNaC::lst
serendip_3x_p2(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2];
  GiNaC::lst l { 1,x,y,z,x*y,x*z,y*z,x*x,y*y,z*z,x*y*z,x*x*y,x*y*y,x*x*z,y*y*z,x*z*z,y*z*z,x*x*y*z,x*y*y*z,x*y*z*z };
  return l;
}
GiNaC::lst
serendip_3x_p3(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2];
  GiNaC::lst l { 1,x,y,z,x*y,x*z,y*z,x*x,y*y,z*z,x*y*z,x*x*y,x*y*y,x*x*z,y*y*z,x*z*z,y*z*z,x*x*x,y*y*y,z*z*z,x*x*y*z,x*y*y*z,x*y*z*z,x*x*x*y,x*y*y*y,x*x*x*z,y*y*y*z,x*z*z*z,y*z*z*z,x*x*x*y*z,x*y*y*y*z,x*y*z*z*z };
  return l;
}

GiNaC::lst
serendip_4x_p0(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::lst l { 1 };
  return l;
}
GiNaC::lst
serendip_4x_p1(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], u = vars[3];
  GiNaC::lst l { 1,x,y,z,u,x*y,x*z,y*z,u*x,u*y,u*z,x*y*z,u*x*y,u*x*z,u*y*z,u*x*y*z };
  return l;  
}
GiNaC::lst
serendip_4x_p2(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], u = vars[3];
  GiNaC::lst l { 1,x,y,z,u,x*y,x*z,y*z,u*x,u*y,u*z,x*x,y*y,z*z,u*u,x*y*z,u*x*y,u*x*z,u*y*z,x*x*y,x*y*y,x*x*z,y*y*z,x*z*z,y*z*z,u*x*x,u*y*y,u*z*z,u*u*x,u*u*y,u*u*z,u*x*y*z,x*x*y*z,x*y*y*z,x*y*z*z,u*x*x*y,u*x*y*y,u*x*x*z,u*y*y*z,u*x*z*z,u*y*z*z,u*u*x*y,u*u*x*z,u*u*y*z,u*x*x*y*z,u*x*y*y*z,u*x*y*z*z,u*u*x*y*z };
  return l;
}
GiNaC::lst
serendip_4x_p3(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], u = vars[3];
  GiNaC::lst l { 1,x,y,z,u,x*y,x*z,y*z,u*x,u*y,u*z,x*x,y*y,z*z,u*u,x*y*z,u*x*y,u*x*z,u*y*z,x*x*y,x*y*y,x*x*z,y*y*z,x*z*z,y*z*z,u*x*x,u*y*y,u*z*z,u*u*x,u*u*y,u*u*z,x*x*x,y*y*y,z*z*z,u*u*u,u*x*y*z,x*x*y*z,x*y*y*z,x*y*z*z,u*x*x*y,u*x*y*y,u*x*x*z,u*y*y*z,u*x*z*z,u*y*z*z,u*u*x*y,u*u*x*z,u*u*y*z,x*x*x*y,x*y*y*y,x*x*x*z,y*y*y*z,x*z*z*z,y*z*z*z,u*x*x*x,u*y*y*y,u*z*z*z,u*u*u*x,u*u*u*y,u*u*u*z,u*x*x*y*z,u*x*y*y*z,u*x*y*z*z,u*u*x*y*z,x*x*x*y*z,x*y*y*y*z,x*y*z*z*z,u*x*x*x*y,u*x*y*y*y,u*x*x*x*z,u*y*y*y*z,u*x*z*z*z,u*y*z*z*z,u*u*u*x*y,u*u*u*x*z,u*u*u*y*z,u*x*x*x*y*z,u*x*y*y*y*z,u*x*y*z*z*z,u*u*u*x*y*z };
  return l;
}

GiNaC::lst
serendip_5x_p0(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::lst l { 1 };
  return l;
}
GiNaC::lst
serendip_5x_p1(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], u = vars[3], v = vars[4];
  GiNaC::lst l { 1,x,y,z,u,v,x*y,x*z,y*z,u*x,u*y,u*z,v*x,v*y,v*z,u*v,x*y*z,u*x*y,u*x*z,u*y*z,v*x*y,v*x*z,v*y*z,u*v*x,u*v*y,u*v*z,u*x*y*z,v*x*y*z,u*v*x*y,u*v*x*z,u*v*y*z,u*v*x*y*z };
  return l;  
}
GiNaC::lst
serendip_5x_p2(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], u = vars[3], v = vars[4];
  GiNaC::lst l { 1,x,y,z,u,v,x*y,x*z,y*z,u*x,u*y,u*z,v*x,v*y,v*z,u*v,x*x,y*y,z*z,u*u,v*v,x*y*z,u*x*y,u*x*z,u*y*z,v*x*y,v*x*z,v*y*z,u*v*x,u*v*y,u*v*z,x*x*y,x*y*y,x*x*z,y*y*z,x*z*z,y*z*z,u*x*x,u*y*y,u*z*z,u*u*x,u*u*y,u*u*z,v*x*x,v*y*y,v*z*z,u*u*v,v*v*x,v*v*y,v*v*z,u*v*v,u*x*y*z,v*x*y*z,u*v*x*y,u*v*x*z,u*v*y*z,x*x*y*z,x*y*y*z,x*y*z*z,u*x*x*y,u*x*y*y,u*x*x*z,u*y*y*z,u*x*z*z,u*y*z*z,u*u*x*y,u*u*x*z,u*u*y*z,v*x*x*y,v*x*y*y,v*x*x*z,v*y*y*z,v*x*z*z,v*y*z*z,u*v*x*x,u*v*y*y,u*v*z*z,u*u*v*x,u*u*v*y,u*u*v*z,v*v*x*y,v*v*x*z,v*v*y*z,u*v*v*x,u*v*v*y,u*v*v*z,u*v*x*y*z,u*x*x*y*z,u*x*y*y*z,u*x*y*z*z,u*u*x*y*z,v*x*x*y*z,v*x*y*y*z,v*x*y*z*z,u*v*x*x*y,u*v*x*y*y,u*v*x*x*z,u*v*y*y*z,u*v*x*z*z,u*v*y*z*z,u*u*v*x*y,u*u*v*x*z,u*u*v*y*z,v*v*x*y*z,u*v*v*x*y,u*v*v*x*z,u*v*v*y*z,u*v*x*x*y*z,u*v*x*y*y*z,u*v*x*y*z*z,u*u*v*x*y*z,u*v*v*x*y*z };
  return l;
}
GiNaC::lst
serendip_5x_p3(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], u = vars[3], v = vars[4];
  GiNaC::lst l { 1,x,y,z,u,v,x*y,x*z,y*z,u*x,u*y,u*z,v*x,v*y,v*z,u*v,x*x,y*y,z*z,u*u,v*v,x*y*z,u*x*y,u*x*z,u*y*z,v*x*y,v*x*z,v*y*z,u*v*x,u*v*y,u*v*z,x*x*y,x*y*y,x*x*z,y*y*z,x*z*z,y*z*z,u*x*x,u*y*y,u*z*z,u*u*x,u*u*y,u*u*z,v*x*x,v*y*y,v*z*z,u*u*v,v*v*x,v*v*y,v*v*z,u*v*v,x*x*x,y*y*y,z*z*z,u*u*u,v*v*v,u*x*y*z,v*x*y*z,u*v*x*y,u*v*x*z,u*v*y*z,x*x*y*z,x*y*y*z,x*y*z*z,u*x*x*y,u*x*y*y,u*x*x*z,u*y*y*z,u*x*z*z,u*y*z*z,u*u*x*y,u*u*x*z,u*u*y*z,v*x*x*y,v*x*y*y,v*x*x*z,v*y*y*z,v*x*z*z,v*y*z*z,u*v*x*x,u*v*y*y,u*v*z*z,u*u*v*x,u*u*v*y,u*u*v*z,v*v*x*y,v*v*x*z,v*v*y*z,u*v*v*x,u*v*v*y,u*v*v*z,x*x*x*y,x*y*y*y,x*x*x*z,y*y*y*z,x*z*z*z,y*z*z*z,u*x*x*x,u*y*y*y,u*z*z*z,u*u*u*x,u*u*u*y,u*u*u*z,v*x*x*x,v*y*y*y,v*z*z*z,u*u*u*v,v*v*v*x,v*v*v*y,v*v*v*z,u*v*v*v,u*v*x*y*z,u*x*x*y*z,u*x*y*y*z,u*x*y*z*z,u*u*x*y*z,v*x*x*y*z,v*x*y*y*z,v*x*y*z*z,u*v*x*x*y,u*v*x*y*y,u*v*x*x*z,u*v*y*y*z,u*v*x*z*z,u*v*y*z*z,u*u*v*x*y,u*u*v*x*z,u*u*v*y*z,v*v*x*y*z,u*v*v*x*y,u*v*v*x*z,u*v*v*y*z,x*x*x*y*z,x*y*y*y*z,x*y*z*z*z,u*x*x*x*y,u*x*y*y*y,u*x*x*x*z,u*y*y*y*z,u*x*z*z*z,u*y*z*z*z,u*u*u*x*y,u*u*u*x*z,u*u*u*y*z,v*x*x*x*y,v*x*y*y*y,v*x*x*x*z,v*y*y*y*z,v*x*z*z*z,v*y*z*z*z,u*v*x*x*x,u*v*y*y*y,u*v*z*z*z,u*u*u*v*x,u*u*u*v*y,u*u*u*v*z,v*v*v*x*y,v*v*v*x*z,v*v*v*y*z,u*v*v*v*x,u*v*v*v*y,u*v*v*v*z,u*v*x*x*y*z,u*v*x*y*y*z,u*v*x*y*z*z,u*u*v*x*y*z,u*v*v*x*y*z,u*x*x*x*y*z,u*x*y*y*y*z,u*x*y*z*z*z,u*u*u*x*y*z,v*x*x*x*y*z,v*x*y*y*y*z,v*x*y*z*z*z,u*v*x*x*x*y,u*v*x*y*y*y,u*v*x*x*x*z,u*v*y*y*y*z,u*v*x*z*z*z,u*v*y*z*z*z,u*u*u*v*x*y,u*u*u*v*x*z,u*u*u*v*y*z,v*v*v*x*y*z,u*v*v*v*x*y,u*v*v*v*x*z,u*v*v*v*y*z,u*v*x*x*x*y*z,u*v*x*y*y*y*z,u*v*x*y*z*z*z,u*u*u*v*x*y*z,u*v*v*v*x*y*z };
  return l;
}

GiNaC::lst
serendip_6x_p0(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::lst l { 1 };
  return l;
}
GiNaC::lst
serendip_6x_p1(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], u = vars[3], v = vars[4], w = vars[5];
  GiNaC::lst l { 1,x,y,z,u,v,w,x*y,x*z,y*z,u*x,u*y,u*z,v*x,v*y,v*z,u*v,w*x,w*y,w*z,u*w,v*w,x*y*z,u*x*y,u*x*z,u*y*z,v*x*y,v*x*z,v*y*z,u*v*x,u*v*y,u*v*z,w*x*y,w*x*z,w*y*z,u*w*x,u*w*y,u*w*z,v*w*x,v*w*y,v*w*z,u*v*w,u*x*y*z,v*x*y*z,u*v*x*y,u*v*x*z,u*v*y*z,w*x*y*z,u*w*x*y,u*w*x*z,u*w*y*z,v*w*x*y,v*w*x*z,v*w*y*z,u*v*w*x,u*v*w*y,u*v*w*z,u*v*x*y*z,u*w*x*y*z,v*w*x*y*z,u*v*w*x*y,u*v*w*x*z,u*v*w*y*z,u*v*w*x*y*z };
  return l;  
}
GiNaC::lst
serendip_6x_p2(const std::vector<GiNaC::symbol>& vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], u = vars[3], v = vars[4], w = vars[5];
  GiNaC::lst l { 1,x,y,z,u,v,w,x*y,x*z,y*z,u*x,u*y,u*z,v*x,v*y,v*z,u*v,w*x,w*y,w*z,u*w,v*w,x*x,y*y,z*z,u*u,v*v,w*w,x*y*z,u*x*y,u*x*z,u*y*z,v*x*y,v*x*z,v*y*z,u*v*x,u*v*y,u*v*z,w*x*y,w*x*z,w*y*z,u*w*x,u*w*y,u*w*z,v*w*x,v*w*y,v*w*z,u*v*w,x*x*y,x*y*y,x*x*z,y*y*z,x*z*z,y*z*z,u*x*x,u*y*y,u*z*z,u*u*x,u*u*y,u*u*z,v*x*x,v*y*y,v*z*z,u*u*v,v*v*x,v*v*y,v*v*z,u*v*v,w*x*x,w*y*y,w*z*z,u*u*w,v*v*w,w*w*x,w*w*y,w*w*z,u*w*w,v*w*w,u*x*y*z,v*x*y*z,u*v*x*y,u*v*x*z,u*v*y*z,w*x*y*z,u*w*x*y,u*w*x*z,u*w*y*z,v*w*x*y,v*w*x*z,v*w*y*z,u*v*w*x,u*v*w*y,u*v*w*z,x*x*y*z,x*y*y*z,x*y*z*z,u*x*x*y,u*x*y*y,u*x*x*z,u*y*y*z,u*x*z*z,u*y*z*z,u*u*x*y,u*u*x*z,u*u*y*z,v*x*x*y,v*x*y*y,v*x*x*z,v*y*y*z,v*x*z*z,v*y*z*z,u*v*x*x,u*v*y*y,u*v*z*z,u*u*v*x,u*u*v*y,u*u*v*z,v*v*x*y,v*v*x*z,v*v*y*z,u*v*v*x,u*v*v*y,u*v*v*z,w*x*x*y,w*x*y*y,w*x*x*z,w*y*y*z,w*x*z*z,w*y*z*z,u*w*x*x,u*w*y*y,u*w*z*z,u*u*w*x,u*u*w*y,u*u*w*z,v*w*x*x,v*w*y*y,v*w*z*z,u*u*v*w,v*v*w*x,v*v*w*y,v*v*w*z,u*v*v*w,w*w*x*y,w*w*x*z,w*w*y*z,u*w*w*x,u*w*w*y,u*w*w*z,v*w*w*x,v*w*w*y,v*w*w*z,u*v*w*w,u*v*x*y*z,u*w*x*y*z,v*w*x*y*z,u*v*w*x*y,u*v*w*x*z,u*v*w*y*z,u*x*x*y*z,u*x*y*y*z,u*x*y*z*z,u*u*x*y*z,v*x*x*y*z,v*x*y*y*z,v*x*y*z*z,u*v*x*x*y,u*v*x*y*y,u*v*x*x*z,u*v*y*y*z,u*v*x*z*z,u*v*y*z*z,u*u*v*x*y,u*u*v*x*z,u*u*v*y*z,v*v*x*y*z,u*v*v*x*y,u*v*v*x*z,u*v*v*y*z,w*x*x*y*z,w*x*y*y*z,w*x*y*z*z,u*w*x*x*y,u*w*x*y*y,u*w*x*x*z,u*w*y*y*z,u*w*x*z*z,u*w*y*z*z,u*u*w*x*y,u*u*w*x*z,u*u*w*y*z,v*w*x*x*y,v*w*x*y*y,v*w*x*x*z,v*w*y*y*z,v*w*x*z*z,v*w*y*z*z,u*v*w*x*x,u*v*w*y*y,u*v*w*z*z,u*u*v*w*x,u*u*v*w*y,u*u*v*w*z,v*v*w*x*y,v*v*w*x*z,v*v*w*y*z,u*v*v*w*x,u*v*v*w*y,u*v*v*w*z,w*w*x*y*z,u*w*w*x*y,u*w*w*x*z,u*w*w*y*z,v*w*w*x*y,v*w*w*x*z,v*w*w*y*z,u*v*w*w*x,u*v*w*w*y,u*v*w*w*z,u*v*w*x*y*z,u*v*x*x*y*z,u*v*x*y*y*z,u*v*x*y*z*z,u*u*v*x*y*z,u*v*v*x*y*z,u*w*x*x*y*z,u*w*x*y*y*z,u*w*x*y*z*z,u*u*w*x*y*z,v*w*x*x*y*z,v*w*x*y*y*z,v*w*x*y*z*z,u*v*w*x*x*y,u*v*w*x*y*y,u*v*w*x*x*z,u*v*w*y*y*z,u*v*w*x*z*z,u*v*w*y*z*z,u*u*v*w*x*y,u*u*v*w*x*z,u*u*v*w*y*z,v*v*w*x*y*z,u*v*v*w*x*y,u*v*v*w*x*z,u*v*v*w*y*z,u*w*w*x*y*z,v*w*w*x*y*z,u*v*w*w*x*y,u*v*w*w*x*z,u*v*w*w*y*z,u*v*w*x*x*y*z,u*v*w*x*y*y*z,u*v*w*x*y*z*z,u*u*v*w*x*y*z,u*v*v*w*x*y*z,u*v*w*w*x*y*z };
  return l;
}
