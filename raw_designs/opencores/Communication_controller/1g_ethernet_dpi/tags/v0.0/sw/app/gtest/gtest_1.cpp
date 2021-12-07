#include <gtest/gtest.h>
#include <string>

#include "ethlc.hpp"

//TEST_F(TestDev, test_1)
TEST(TestDev, test_1)
{
    // dec vars
    std::string device_address;
    std::string details;
    bool result;
    
    // prep WRONG ipv4-addr
    device_address = "192.168.43.6";
    
    // proc
    ethlc *dev = new ethlc();
    ASSERT_NE(dev, (void *)0);
    
    result = dev->ethlc_open(device_address);
    dev->ethlc_gdet(details);
    ASSERT_EQ(result, false) << std::endl << details; // arping with wrong-addr -> FALSE
    
    result = dev->ethlc_proc();
    dev->ethlc_gdet(details);
    ASSERT_EQ(result, false) << std::endl << details; // ping 
    
    result = dev->ethlc_close();
    dev->ethlc_gdet(details);
    ASSERT_EQ(result, false) << std::endl << details; // arping ..
    
    // Final
    delete dev;
}
