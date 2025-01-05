// test_main.cpp

// Include the headers of the modules you want to test
#include "bitboard.h"
#include "position.h"
#include "search.h"
#include "uci.h"
#include "thread_pool.h"

#include <gtest/gtest.h>

// Example: Mocking any dependencies if necessary
// #include "mock_dependency.h"

int main(int argc, char **argv)
{
    UCI::init(Options);
    Bitboards::init();
    Position::init();
    // Threads.set(static_cast<size_t>(Options["Threads"]));
    Search::clear(); // After threads are up

    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
