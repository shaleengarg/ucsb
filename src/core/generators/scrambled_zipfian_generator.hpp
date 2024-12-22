#pragma once

#include <cassert>

#include "src/core/generators/zipfian_generator.hpp"

namespace ucsb::core {

class scrambled_zipfian_generator_t : public generator_gt<size_t> {
  public:
    inline scrambled_zipfian_generator_t(size_t min, size_t max, float zipfian_const)
        : base_(min), num_items_(max - min + 1), generator_(0, 10'000'000'000LL, zipfian_const) {}

    inline scrambled_zipfian_generator_t(size_t min, size_t max)
        : base_(min), num_items_(max - min + 1),
          //generator_(0, 10'000'000'000LL, zipfian_generator_t::zipfian_const_k, zetan_k) {
          //generator_(0, num_items_, zipfian_generator_t::zipfian_const_k, zetan_k) {
          generator_(min, max, zipfian_generator_t::zipfian_const_k, zetan_k) {
                printf("%s: called with min:%ld, max:%ld\n", __func__, min, max);
          }

    inline scrambled_zipfian_generator_t(size_t num_items) : scrambled_zipfian_generator_t(0, num_items - 1) {}

    inline size_t generate() override { return scramble(generator_.generate()); }
    inline size_t last() override { return scramble(generator_.last()); }

  private:
    static constexpr float zetan_k = 26.46902820178302;

    inline size_t scramble(size_t value) const noexcept {
            size_t val = base_ + fnv_hash64(value) % num_items_;
            //size_t val = base_ + value % num_items_;
            return val;
    }

    inline size_t fnv_hash64(size_t val) const noexcept {
        size_t constexpr fnv_offset_basis64 = 0xCBF29CE484222325ull;
        size_t constexpr fnv_prime64 = 1099511628211ull;
        size_t hash = fnv_offset_basis64;
#pragma unroll
        for (int i = 0; i < 8; ++i) {
            size_t octet = val & 0x00ff;
            val = val >> 8;
            hash = hash ^ octet;
            hash = hash * fnv_prime64;
        }
        return hash;
    }

    size_t const base_;
    size_t const num_items_;
    zipfian_generator_t generator_;
};

} // namespace ucsb::core
