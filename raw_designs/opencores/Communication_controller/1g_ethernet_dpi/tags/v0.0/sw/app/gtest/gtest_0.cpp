#include <gtest/gtest.h>
#include <string>

#include "ethlc.hpp"

//TEST_F(TestDev, test_0)
TEST(TestDev, test_0)
{
    // dec vars
    std::string device_address;
    std::string details;
    bool result;
    
    // prep CORRECT ipv4-addr
    device_address = "192.168.43.5"; // ..\vtest\sw\dev\test_main\src\main\test_main.c
    
    // proc
    ethlc *dev = new ethlc();
    ASSERT_NE(dev, (void *)0);
    
    result = dev->ethlc_open(device_address);
    dev->ethlc_gdet(details);
    ASSERT_EQ(result, true) << std::endl << details;
    
    result = dev->ethlc_proc();
    dev->ethlc_gdet(details);
    ASSERT_EQ(result, true) << std::endl << details;
    
    result = dev->ethlc_close();
    dev->ethlc_gdet(details);
    ASSERT_EQ(result, true) << std::endl << details;
    
    // Final
    delete dev;
}
