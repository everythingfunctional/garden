module garden_input_test_case_m
    use iso_varying_string, only: varying_string, operator(//), put_line, var_str
    use strff, only: operator(.includes.), to_string
    use garden_command_line_m, only: DEBUG
    use garden_input_m, only: input_t
    use garden_test_m, only: &
            filter_result_t, test_t, filter_failed, filter_matched
    use garden_test_case_result_m, only: test_case_result_t
    use garden_test_interfaces_m, only: computation_i, input_test_i
    use garden_result_m, only: fail
    use garden_test_result_item_m, only: test_result_item_t

    implicit none
    private
    public :: input_test_case_t

    type, extends(test_t) :: input_test_case_t
        private
        type(varying_string) :: description_
        procedure(input_test_i), nopass, pointer :: test
        logical :: has_setup_and_teardown
        procedure(computation_i), nopass, pointer :: setup
        procedure(computation_i), nopass, pointer :: teardown
    contains
        private
        procedure, public :: description
        procedure, public :: filter
        procedure, public :: num_cases
        procedure, public :: run_with_input
        procedure, public :: run_without_input
    end type

    interface input_test_case_t
        module procedure constructor_basic
        module procedure constructor_bracketed
    end interface
contains
    function constructor_basic(description, test) result(input_test_case)
        type(varying_string), intent(in) :: description
        procedure(input_test_i) :: test
        type(input_test_case_t) :: input_test_case

        input_test_case%description_ = description
        input_test_case%test => test
        input_test_case%has_setup_and_teardown = .false.
    end function

    function constructor_bracketed( &
            description, test, setup, teardown) result(input_test_case)
        type(varying_string), intent(in) :: description
        procedure(input_test_i) :: test
        procedure(computation_i) :: setup
        procedure(computation_i) :: teardown
        type(input_test_case_t) :: input_test_case

        input_test_case%description_ = description
        input_test_case%test => test
        input_test_case%has_setup_and_teardown = .true.
        input_test_case%setup => setup
        input_test_case%teardown => teardown
    end function

    pure function description(self)
        class(input_test_case_t), intent(in) :: self
        type(varying_string) :: description

        description = self%description_
    end function

    function filter(self, filter_string) result(filter_result)
        class(input_test_case_t), intent(in) :: self
        type(varying_string), intent(in) :: filter_string
        type(filter_result_t) :: filter_result

        if (self%description_.includes.filter_string) then
            filter_result = filter_matched(self)
        else
            filter_result = filter_failed()
        end if
    end function

    pure function num_cases(self)
        class(input_test_case_t), intent(in) :: self
        integer :: num_cases

        associate(unused => self)
        end associate

        num_cases = 1
    end function

    recursive function run_with_input(self, input) result(result_)
        class(input_test_case_t), intent(in) :: self
        class(input_t), intent(in) :: input
        type(test_result_item_t) :: result_

        if (DEBUG) call put_line( &
                "Beginning execution of: " // self%description_ &
                // merge(" on image " // to_string(this_image()), var_str(""), num_images() > 1))
        if (self%has_setup_and_teardown) call self%setup
        result_ = test_result_item_t(test_case_result_t( &
                self%description_, self%test(input)))
        if (self%has_setup_and_teardown) call self%teardown
        if (DEBUG) call put_line( &
                "Completed execution of: " // self%description_&
                // merge(" on image " // to_string(this_image()), var_str(""), num_images() > 1))
    end function

    function run_without_input(self) result(result_)
        class(input_test_case_t), intent(in) :: self
        type(test_result_item_t) :: result_

        if (DEBUG) call put_line( &
                "Improper use of: " // self%description_&
                // merge(" on image " // to_string(this_image()), var_str(""), num_images() > 1))
        result_ = test_result_item_t(test_case_result_t( &
                self%description_, fail("No input provided")))
    end function
end module
