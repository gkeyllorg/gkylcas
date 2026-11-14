#include <ginac/ginac.h>
#include <gkhyb_mono.h>

GiNaC::lst
gkhyb_1x1v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], vx = vars[1];
  
  GiNaC::lst l { 1,x,vx,vx*x,vx*vx,vx*vx*x };
  return l; 
}

GiNaC::lst
gkhyb_1x2v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], vx = vars[1], vy = vars[2];
  
  GiNaC::lst l { 1,x,vx,vy,vx*x,vy*x,vx*vy,vx*vy*x,vx*vx,vx*vx*x,vx*vx*vy,vx*vx*vy*x };
  return l;  
}

GiNaC::lst
gkhyb_2x2v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], vx = vars[2], vy = vars[3];
  
  GiNaC::lst l { 1,x,y,vx,vy,x*y,vx*x,vx*y,vy*x,vy*y,vx*vy,vx*x*y,vy*x*y,vx*vy*x,vx*vy*y,vx*vy*x*y,vx*vx,vx*vx*x,vx*vx*y,vx*vx*vy,vx*vx*x*y,vx*vx*vy*x,vx*vx*vy*y,vx*vx*vy*x*y };
  return l;  
}

GiNaC::lst
gkhyb_3x2v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol x = vars[0], y = vars[1], z = vars[2], vx = vars[3], vy = vars[4];  
  
  GiNaC::lst l { 1,x,y,z,vx,vy,x*y,x*z,y*z,vx*x,vx*y,vx*z,vy*x,vy*y,vy*z,vx*vy,x*y*z,vx*x*y,vx*x*z,vx*y*z,vy*x*y,vy*x*z,vy*y*z,vx*vy*x,vx*vy*y,vx*vy*z,vx*x*y*z,vy*x*y*z,vx*vy*x*y,vx*vy*x*z,vx*vy*y*z,vx*vy*x*y*z,vx*vx,vx*vx*x,vx*vx*y,vx*vx*z,vx*vx*vy,vx*vx*x*y,vx*vx*x*z,vx*vx*y*z,vx*vx*vy*x,vx*vx*vy*y,vx*vx*vy*z,vx*vx*x*y*z,vx*vx*vy*x*y,vx*vx*vy*x*z,vx*vx*vy*y*z,vx*vx*vy*x*y*z };
  return l;  
}
