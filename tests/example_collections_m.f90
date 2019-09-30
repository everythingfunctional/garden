module example_collections_m
    use example_asserts_m, only: NUM_PASSING_FROM_EXAMPLE => NUM_ASSERTS_IN_PASSING

    implicit none
    private

    character(len=*), parameter, public :: EXAMPLE_CASE_DESCRIPTION_1 = &
            "Example Case Description 1"
    character(len=*), parameter, public :: EXAMPLE_CASE_DESCRIPTION_2 = &
            "Example Case Description 2"
    character(len=*), parameter, public :: EXAMPLE_COLLECTION_DESCRIPTION = &
            "Example Collection Description"
    character(len=*), parameter, public :: EXAMPLE_FAILING_CASE_DESCRIPTION = &
            "Example Failing Case Description"
    character(len=*), parameter, public :: FAILURE_MESSAGE = "Failure Message"
    character(len=*), parameter, public :: MIDDLE_COLLECTION_DESCRIPTION = &
            "Middle Collection Description"
    character(len=*), parameter, public :: NOT_IN_DESCRIPTIONS = "NOT IN DESCRIPTION"
    integer, parameter, public :: NUM_ASSERTS_IN_PASSING = NUM_PASSING_FROM_EXAMPLE * 3
    integer, parameter, public :: NUM_ASSERTS_IN_FAILING = NUM_PASSING_FROM_EXAMPLE * 2 + 1
    integer, parameter, public :: NUM_CASES_IN_PASSING = 3
    integer, parameter, public :: NUM_CASES_IN_FAILING = 3
    integer, parameter, public :: NUM_FAILING_ASSERTS = 1
    integer, parameter, public :: NUM_FAILING_CASES = 1

    public :: exampleFailingCollection, examplePassingCollection, runCollection
contains
    function exampleTestCase1() result(test_case)
        use example_asserts_m, only: exampleMultipleAsserts
        use Vegetables_m, only: TestItem_t, it

        type(TestItem_t) :: test_case

        test_case = it(EXAMPLE_CASE_DESCRIPTION_1, exampleMultipleAsserts)
    end function exampleTestCase1

    function exampleTestCase2() result(test_case)
        use example_asserts_m, only: exampleMultipleAsserts
        use Vegetables_m, only: TestItem_t, it

        type(TestItem_t) :: test_case

        test_case = it(EXAMPLE_CASE_DESCRIPTION_2, exampleMultipleAsserts)
    end function exampleTestCase2

    function exampleFail() result(result_)
        use Vegetables_m, only: Result_t, fail

        type(Result_t) :: result_

        result_ = fail(FAILURE_MESSAGE)
    end function exampleFail

    function exampleFailingTestCase() result(test_case)
        use Vegetables_m, only: TestItem_t, it

        type(TestItem_t) :: test_case

        test_case = it(EXAMPLE_FAILING_CASE_DESCRIPTION, exampleFail)
    end function exampleFailingTestCase

    function exampleFailingCollection() result(test_collection)
        use Vegetables_m, only: &
                SimpleTestCollection_t, TestItem_t, SimpleTestCollection

        type(SimpleTestCollection_t) :: test_collection

        type(TestItem_t) :: cases(3)

        cases(1) = exampleTestCase1()
        cases(2) = exampleTestCase2()
        cases(3) = exampleFailingTestCase()
        test_collection = SimpleTestCollection(EXAMPLE_COLLECTION_DESCRIPTION, cases)
    end function exampleFailingCollection

    function middleCollection() result(test_collection)
        use Vegetables_m, only: TestItem_t, describe

        type(TestItem_t) :: test_collection

        type(TestItem_t) :: cases(2)

        cases(1) = exampleTestCase1()
        cases(2) = exampleTestCase2()
        test_collection = describe(MIDDLE_COLLECTION_DESCRIPTION, cases)
    end function middleCollection

    function examplePassingCollection() result(test_collection)
        use Vegetables_m, only: &
                SimpleTestCollection_t, TestItem_t, SimpleTestCollection

        type(SimpleTestCollection_t) :: test_collection

        type(TestItem_t) :: items(2)

        items(1) = middleCollection()
        items(2) = exampleTestCase2()
        test_collection = SimpleTestCollection(EXAMPLE_COLLECTION_DESCRIPTION, items)
    end function examplePassingCollection

    function runCollection(example_collection) result(example_results)
        use Vegetables_m, only: &
                SimpleTestCollection_t, Transformed_t, fail, Transformed

        class(*), intent(in) :: example_collection
        type(Transformed_t) :: example_results

        select type (example_collection)
        type is (SimpleTestCollection_t)
            example_results = Transformed(example_collection%run())
        class default
            example_results = Transformed(fail("Expected to get a TestCase_t"))
        end select
    end function runCollection
end module example_collections_m
