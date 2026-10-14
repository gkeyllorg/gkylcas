#include <ginac/ginac.h>
#include <gkhyb_vel_mono.h>

GiNaC::lst
gkhyb_vel_1v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol vx = vars[0];
  
  GiNaC::lst l { 1,vx,vx*vx };
  return l; 
}

GiNaC::lst
gkhyb_vel_2v_p1(const std::vector<GiNaC::symbol> &vars)
{
  GiNaC::symbol vx = vars[0], vy = vars[1];
  
  GiNaC::lst l { 1,vx,vy,vx*vy,vx*vx,vx*vx*vy };
  return l;  
}
