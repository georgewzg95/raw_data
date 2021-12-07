#ifndef _ETHLC_HPP_
#define _ETHLC_HPP_

#include <cstdio>
#include <iostream>
#include <sstream>
#include <string>

class ethlc {
public:
    bool ethlc_open(const std::string& paddress);
    bool ethlc_proc(void);
    bool ethlc_close(void);
    void ethlc_gdet(std::string& pdetails);
    
private:
// PROC:
    bool exec_shell_cmd(const std::string&  command,
                        std::string&        output,
                        const std::string&  mode);
// DATA:
    std::string address;
    std::string details;
};

#endif // _ETHLC_HPP_