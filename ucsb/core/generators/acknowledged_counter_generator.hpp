#pragma once

#include <random>

#include "ucsb/core/exception.hpp"
#include "ucsb/core/generators/counter_generator.hpp"

namespace ucsb {

struct acknowledged_counter_generator_t : public counter_generator_t {
    static const size_t window_size_k = (1 << 16);
    static const size_t window_mask_k = window_size_k - 1;

    acknowledged_counter_generator_t(uint64_t start)
        : counter_generator_t(start), limit_(start - 1), ack_window_(window_size_k, false) {}

    size_t generate() override { return counter_++; }
    size_t last() override { return limit_; }

    void Acknowledge(uint64_t value) {
        size_t cur_slot = value & window_mask_k;
        if (ack_window_[cur_slot]) {
            throw exception_t("Not enough window size");
        }
        ack_window_[cur_slot] = true;
        size_t until = limit_ + window_size_k;
        size_t i;
        for (i = limit_ + 1; i < until; i++) {
            size_t slot = i & window_mask_k;
            if (!ack_window_[slot]) {
                break;
            }
            ack_window_[slot] = false;
        }
        limit_ = i - 1;
    }

  private:
    std::vector<bool> ack_window_;
    uint64_t limit_;
};

} // namespace ucsb