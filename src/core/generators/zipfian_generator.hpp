#pragma once

#include <random>
#include <cassert>

#include "src/core/generators/generator.hpp"
#include "src/core/generators/random_generator.hpp"

namespace ucsb::core {

class zipfian_generator_t : public generator_gt<size_t> {
  public:
    static constexpr float zipfian_const_k = 0.6;
    static constexpr size_t items_max_count = (UINT64_MAX >> 24);

    zipfian_generator_t(size_t items_count) : zipfian_generator_t(0, items_count - 1) {}

    zipfian_generator_t(size_t min, size_t max, float zipfian_const = zipfian_const_k)
        : zipfian_generator_t(min, max, zipfian_const, zeta(max - min + 1, zipfian_const)) {}

    zipfian_generator_t(size_t min, size_t max, float zipfian_const, float zeta_n);

    inline size_t generate() override { return generate(items_count_); }
    inline size_t last() override { return last_; }

    size_t generate(size_t items_count);

  private:
    inline float eta() { return (1 - std::pow(2.f / items_count_, 1 - theta_)) / (1 - zeta_2_ / zeta_n_); }
    inline float zeta(size_t num, float theta) { return zeta(0, num, theta, 0.f); }
    inline float zeta(size_t last_num, size_t cur_num, float theta, float last_zeta);


    random_double_generator_t generator_;
    size_t items_count_;
    size_t base_;
    size_t count_for_zeta_;
    size_t last_;
    float theta_;
    float zeta_n_;
    float eta_;
    float alpha_;
    float zeta_2_;
    bool allow_count_decrease_;
};

zipfian_generator_t::zipfian_generator_t(size_t min, size_t max, float zipfian_const, float zeta_n)
    : generator_(0.0, 1.0), items_count_(max - min + 1), base_(min), theta_(zipfian_const),
      allow_count_decrease_(false) {
    assert(items_count_ >= 2 && items_count_ < items_max_count);

    zeta_2_ = zeta(2, theta_);
    alpha_ = 1.0 / (1.0 - theta_);
    zeta_n_ = zeta_n;
    count_for_zeta_ = items_count_;
    //zeta_n_ = zeta(count_for_zeta_, theta_);
    zeta_n_ = zeta(min, max, theta_, 0.f);
    eta_ = eta();

    /*
    printf("%s: zeta_2_:%f, alpha_:%f, zeta_n:%f, count_for_zeta_:%ld, eta_:%f\n",
                    __func__, zeta_2_, alpha_, zeta_n_, count_for_zeta_, eta_);
    */

    generate();
}

size_t zipfian_generator_t::generate(size_t num) {

        size_t ret;

#if 0
    assert(num >= 2 && num < items_max_count);
    if (num != count_for_zeta_) {
        if (num > count_for_zeta_) {
            zeta_n_ = zeta(count_for_zeta_, num, theta_, zeta_n_);
            count_for_zeta_ = num;
            eta_ = eta();
        }
        else if (num < count_for_zeta_ && allow_count_decrease_) {
            // TODO
        }
    }
#endif

    float u = generator_.generate(); // random number [0, 1]
    float uz = u * zeta_n_;

    /*
    printf("%s: first uz:%f, u:%f, zeta_n_:%f eta_:%f, alpha_:%f, theta:%f, num:%ld, base_:%ld, last_:%ld\n",
                   __func__, uz, u, zeta_n_, eta_, alpha_, theta_, num, base_, last_);
                   */

    if (uz < 1.0){
        ret = last_ = base_;
        return ret;
    }
    if (uz < 1.0 + std::pow(0.5, theta_)){
        ret = last_ = base_ + 1;
        return ret;
    }
    ret = base_ + num * std::pow(eta_ * u - eta_ + 1, alpha_);
    last_ = ret;
    return ret;
}

inline float zipfian_generator_t::zeta(size_t last_num, size_t cur_num, float theta, float last_zeta) {
    float zeta = last_zeta;
    //printf("%s: last_num:%ld, curr_num:%ld, theta:%f, last_zeta:%f\n", __func__, last_num, cur_num, theta, last_zeta);
    for (size_t i = last_num + 1; i <= cur_num; ++i)
    //for (size_t i = 1; i <= cur_num - last_num; ++i)
        zeta += 1.f / std::pow((float)i, theta);
    return zeta;
}

} // namespace ucsb::core
