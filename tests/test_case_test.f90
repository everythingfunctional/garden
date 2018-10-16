module test_case_test
    implicit none
    private

    public :: test_can_be_single_case
contains
    pure function test_can_be_single_case() result(test)
        use Vegetables_m, only: Test_t, SUCCESSFUL

        class(Test_t), allocatable :: test

        test = SUCCESSFUL()
    end function test_can_be_single_case
end module test_case_test
