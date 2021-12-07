#include "ethlc.hpp"

/**
 * @brief   private: Execute Generic Shell Command
 *
 * @param[in]   command Command to execute.
 * @param[out]  output  Shell output.
 * @param[in]   mode read/write access
 *
 * @return 0 for success, 1 otherwise.
 *
*/
bool ethlc::exec_shell_cmd( const std::string&  command,
                            std::string&        output,
                            const std::string&  mode = "r")
{
    // Create the stringstream
    std::stringstream sout;
    // Run Popen
    FILE *in;
    char buff[512];
    // Test output
    if(!(in = popen(command.c_str(), mode.c_str()))){
        return 1;
    }
    // Parse output
    while(fgets(buff, sizeof(buff), in)!=NULL){
        sout << buff;
    }
    // Close
    int exit_code = pclose(in);
    // set output
    output = sout.str();
    // Return exit code
    return exit_code;
}



/**
 * @brief   public: Open-dev
 *
 * @param[in] address   dev IPv4-addr
 *
 * @return 0 for success, 1 otherwise.
 *
*/
bool ethlc::ethlc_open(const std::string& paddress)
{
    // 1st: record addr
    address = paddress.c_str();
    // 2nd: ARPING it
    std::string command = "arping -c 1 " + address + " -I tap0"+ " 2>&1"; // !!!redirecting stderr to stdout
    int code = exec_shell_cmd(command, details);
    return (code == 0);
}

/**
 * @brief   public: Work with dev
 *
 * @return 0 for success, 1 otherwise.
 *
*/
bool ethlc::ethlc_proc(void)
{
    // 1st: PING it
    std::string command = "ping -c 1 " + address + " 2>&1"; // !!!redirecting stderr to stdout
    int code = exec_shell_cmd(command, details);
    return (code == 0);
}

/**
 * @brief   public: Close-dev
 *
 * @return 0 for success, 1 otherwise.
 *
*/
bool ethlc::ethlc_close(void)
{
    // 1st: ARPING it
    std::string command = "arping -c 1 " + address + " -I tap0"+ " 2>&1"; // !!!redirecting stderr to stdout
    int code = exec_shell_cmd(command, details);
    return (code == 0);
    //return true;
}

/**
 * @brief   public: Out2usr detailes of shell output
 *
 * @param[out]  output  Shell output.
 *
*/
void ethlc::ethlc_gdet(std::string& pdetails)
{
    pdetails = details;
}
