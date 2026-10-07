#include <hyb_mono.h>

GiNaC::lst
hyb_1x1v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], vx = vars[1];

  GiNaC::lst l { 1,x,vx,vx*x,vx*vx,vx*vx*x };
  return l;
}

GiNaC::lst
hyb_1x2v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], vx = vars[1], vy = vars[2];

  GiNaC::lst l { 1,x,vx,vy,vx*x,vy*x,vx*vy,vx*vy*x,vx*vx,vx*vx*x,vx*vx*vy,vx*vx*vy*x,vy*vy,vy*vy*x,vx*vy*vy,vx*vy*vy*x };
  return l;
}

GiNaC::lst
hyb_1x3v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], vx = vars[1], vy = vars[2], vz = vars[3];

  GiNaC::lst l { 1,x,vx,vy,vz,vx*x,vy*x,vx*vy,vz*x,vx*vz,vy*vz,vx*vy*x,vx*vz*x,vy*vz*x,vx*vy*vz,vx*vy*vz*x,vx*vx,vx*vx*x,vx*vx*vy,vx*vx*vz,vx*vx*vy*x,vx*vx*vz*x,vx*vx*vy*vz,vx*vx*vy*vz*x,vy*vy,vy*vy*x,vx*vy*vy,vy*vy*vz,vx*vy*vy*x,vy*vy*vz*x,vx*vy*vy*vz,vx*vy*vy*vz*x,vz*vz,vz*vz*x,vx*vz*vz,vy*vz*vz,vx*vz*vz*x,vy*vz*vz*x,vx*vy*vz*vz,vx*vy*vz*vz*x };
  return l;
}

GiNaC::lst
hyb_2x1v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], vx = vars[2];

  GiNaC::lst l { 1,x,y,vx,x*y,vx*x,vx*y,vx*x*y,vx*vx,vx*vx*x,vx*vx*y,vx*vx*x*y };
  return l;
}

GiNaC::lst
hyb_2x2v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], vx = vars[2], vy = vars[3];

  GiNaC::lst l { 1,x,y,vx,vy,x*y,vx*x,vx*y,vy*x,vy*y,vx*vy,vx*x*y,vy*x*y,vx*vy*x,vx*vy*y,vx*vy*x*y,vx*vx,vx*vx*x,vx*vx*y,vx*vx*vy,vx*vx*x*y,vx*vx*vy*x,vx*vx*vy*y,vx*vx*vy*x*y,vy*vy,vy*vy*x,vy*vy*y,vx*vy*vy,vy*vy*x*y,vx*vy*vy*x,vx*vy*vy*y,vx*vy*vy*x*y };
  return l;
}

GiNaC::lst
hyb_2x3v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], vx = vars[2], vy = vars[3], vz = vars[4];

  GiNaC::lst l { 1,x,y,vx,vy,vz,x*y,vx*x,vx*y,vy*x,vy*y,vx*vy,vz*x,vz*y,vx*vz,vy*vz,vx*x*y,vy*x*y,vx*vy*x,vx*vy*y,vz*x*y,vx*vz*x,vx*vz*y,vy*vz*x,vy*vz*y,vx*vy*vz,vx*vy*x*y,vx*vz*x*y,vy*vz*x*y,vx*vy*vz*x,vx*vy*vz*y,vx*vy*vz*x*y,vx*vx,vx*vx*x,vx*vx*y,vx*vx*vy,vx*vx*vz,vx*vx*x*y,vx*vx*vy*x,vx*vx*vy*y,vx*vx*vz*x,vx*vx*vz*y,vx*vx*vy*vz,vx*vx*vy*x*y,vx*vx*vz*x*y,vx*vx*vy*vz*x,vx*vx*vy*vz*y,vx*vx*vy*vz*x*y,vy*vy,vy*vy*x,vy*vy*y,vx*vy*vy,vy*vy*vz,vy*vy*x*y,vx*vy*vy*x,vx*vy*vy*y,vy*vy*vz*x,vy*vy*vz*y,vx*vy*vy*vz,vx*vy*vy*x*y,vy*vy*vz*x*y,vx*vy*vy*vz*x,vx*vy*vy*vz*y,vx*vy*vy*vz*x*y,vz*vz,vz*vz*x,vz*vz*y,vx*vz*vz,vy*vz*vz,vz*vz*x*y,vx*vz*vz*x,vx*vz*vz*y,vy*vz*vz*x,vy*vz*vz*y,vx*vy*vz*vz,vx*vz*vz*x*y,vy*vz*vz*x*y,vx*vy*vz*vz*x,vx*vy*vz*vz*y,vx*vy*vz*vz*x*y };
  return l;
}

GiNaC::lst
hyb_3x1v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], vx = vars[3];

  GiNaC::lst l { 1,x,y,z,vx,x*y,x*z,y*z,vx*x,vx*y,vx*z,x*y*z,vx*x*y,vx*x*z,vx*y*z,vx*x*y*z,vx*vx,vx*vx*x,vx*vx*y,vx*vx*z,vx*vx*x*y,vx*vx*x*z,vx*vx*y*z,vx*vx*x*y*z };
  return l;
}

GiNaC::lst
hyb_3x2v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], vx = vars[3], vy = vars[4];

  GiNaC::lst l { 1,x,y,z,vx,vy,x*y,x*z,y*z,vx*x,vx*y,vx*z,vy*x,vy*y,vy*z,vx*vy,x*y*z,vx*x*y,vx*x*z,vx*y*z,vy*x*y,vy*x*z,vy*y*z,vx*vy*x,vx*vy*y,vx*vy*z,vx*x*y*z,vy*x*y*z,vx*vy*x*y,vx*vy*x*z,vx*vy*y*z,vx*vy*x*y*z,vx*vx,vx*vx*x,vx*vx*y,vx*vx*z,vx*vx*vy,vx*vx*x*y,vx*vx*x*z,vx*vx*y*z,vx*vx*vy*x,vx*vx*vy*y,vx*vx*vy*z,vx*vx*x*y*z,vx*vx*vy*x*y,vx*vx*vy*x*z,vx*vx*vy*y*z,vx*vx*vy*x*y*z,vy*vy,vy*vy*x,vy*vy*y,vy*vy*z,vx*vy*vy,vy*vy*x*y,vy*vy*x*z,vy*vy*y*z,vx*vy*vy*x,vx*vy*vy*y,vx*vy*vy*z,vy*vy*x*y*z,vx*vy*vy*x*y,vx*vy*vy*x*z,vx*vy*vy*y*z,vx*vy*vy*x*y*z };
  return l;
}

GiNaC::lst
hyb_3x3v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], vx = vars[3], vy = vars[4], vz = vars[5];

  GiNaC::lst l { 1,x,y,z,vx,vy,vz,x*y,x*z,y*z,vx*x,vx*y,vx*z,vy*x,vy*y,vy*z,vx*vy,vz*x,vz*y,vz*z,vx*vz,vy*vz,x*y*z,vx*x*y,vx*x*z,vx*y*z,vy*x*y,vy*x*z,vy*y*z,vx*vy*x,vx*vy*y,vx*vy*z,vz*x*y,vz*x*z,vz*y*z,vx*vz*x,vx*vz*y,vx*vz*z,vy*vz*x,vy*vz*y,vy*vz*z,vx*vy*vz,vx*x*y*z,vy*x*y*z,vx*vy*x*y,vx*vy*x*z,vx*vy*y*z,vz*x*y*z,vx*vz*x*y,vx*vz*x*z,vx*vz*y*z,vy*vz*x*y,vy*vz*x*z,vy*vz*y*z,vx*vy*vz*x,vx*vy*vz*y,vx*vy*vz*z,vx*vy*x*y*z,vx*vz*x*y*z,vy*vz*x*y*z,vx*vy*vz*x*y,vx*vy*vz*x*z,vx*vy*vz*y*z,vx*vy*vz*x*y*z,vx*vx,vx*vx*x,vx*vx*y,vx*vx*z,vx*vx*vy,vx*vx*vz,vx*vx*x*y,vx*vx*x*z,vx*vx*y*z,vx*vx*vy*x,vx*vx*vy*y,vx*vx*vy*z,vx*vx*vz*x,vx*vx*vz*y,vx*vx*vz*z,vx*vx*vy*vz,vx*vx*x*y*z,vx*vx*vy*x*y,vx*vx*vy*x*z,vx*vx*vy*y*z,vx*vx*vz*x*y,vx*vx*vz*x*z,vx*vx*vz*y*z,vx*vx*vy*vz*x,vx*vx*vy*vz*y,vx*vx*vy*vz*z,vx*vx*vy*x*y*z,vx*vx*vz*x*y*z,vx*vx*vy*vz*x*y,vx*vx*vy*vz*x*z,vx*vx*vy*vz*y*z,vx*vx*vy*vz*x*y*z,vy*vy,vy*vy*x,vy*vy*y,vy*vy*z,vx*vy*vy,vy*vy*vz,vy*vy*x*y,vy*vy*x*z,vy*vy*y*z,vx*vy*vy*x,vx*vy*vy*y,vx*vy*vy*z,vy*vy*vz*x,vy*vy*vz*y,vy*vy*vz*z,vx*vy*vy*vz,vy*vy*x*y*z,vx*vy*vy*x*y,vx*vy*vy*x*z,vx*vy*vy*y*z,vy*vy*vz*x*y,vy*vy*vz*x*z,vy*vy*vz*y*z,vx*vy*vy*vz*x,vx*vy*vy*vz*y,vx*vy*vy*vz*z,vx*vy*vy*x*y*z,vy*vy*vz*x*y*z,vx*vy*vy*vz*x*y,vx*vy*vy*vz*x*z,vx*vy*vy*vz*y*z,vx*vy*vy*vz*x*y*z,vz*vz,vz*vz*x,vz*vz*y,vz*vz*z,vx*vz*vz,vy*vz*vz,vz*vz*x*y,vz*vz*x*z,vz*vz*y*z,vx*vz*vz*x,vx*vz*vz*y,vx*vz*vz*z,vy*vz*vz*x,vy*vz*vz*y,vy*vz*vz*z,vx*vy*vz*vz,vz*vz*x*y*z,vx*vz*vz*x*y,vx*vz*vz*x*z,vx*vz*vz*y*z,vy*vz*vz*x*y,vy*vz*vz*x*z,vy*vz*vz*y*z,vx*vy*vz*vz*x,vx*vy*vz*vz*y,vx*vy*vz*vz*z,vx*vz*vz*x*y*z,vy*vz*vz*x*y*z,vx*vy*vz*vz*x*y,vx*vy*vz*vz*x*z,vx*vy*vz*vz*y*z,vx*vy*vz*vz*x*y*z };
  return l;
}
