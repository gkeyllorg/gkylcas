#include <acutest.h>
#include <modal_basis.h>

void
test_ser_1d()
{
  using namespace GiNaC;

  symbol x("x");
  std::vector<symbol> vars { x };
  Gkyl::ModalBasis mbasis(Gkyl::MODAL_SER, 1, 0, vars, 2);

  lst bc = mbasis.get_basis();
  TEST_CHECK( bc.nops() == 3 );
}

void
test_ser_inner_prod()
{
  using namespace GiNaC;

  symbol x("x"), y("y"), z("z");
  std::vector<symbol> vars { x, y, z };
  Gkyl::ModalBasis mbasis(Gkyl::MODAL_SER, 3, 0, vars, 2);

  lst bc = mbasis.get_basis();

}

TEST_LIST = {
  { "ser_1d", test_ser_1d },
  { "ser_inner_prod", test_ser_inner_prod },
  { NULL, NULL },
};
