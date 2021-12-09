#pragma once

#include "ucsb/core/types.hpp"

namespace ucsb {

class exception_t : public std::exception {
  public:
    inline exception_t(std::string const& message) : message_(message) {}
    const char* what() const noexcept override { return message_.c_str(); }

  private:
    std::string message_;
};

} // namespace ucsb