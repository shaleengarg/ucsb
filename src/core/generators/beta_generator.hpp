#pragma once

#include <random>
#include <cassert>

#include "src/core/generators/generator.hpp"
#include "src/core/generators/random_generator.hpp"

namespace ucsb::core {

        class beta_generator_t : public generator_gt<size_t> {
                public:

                        static constexpr float alpha = 2;
                        static constexpr float beta = 5;

                        beta_generator_t(size_t min, size_t max) : beta_generator_t(min, max, (max-min+1), alpha, beta) {}

                        beta_generator_t(size_t min, size_t max, size_t nr_keys)
                                : beta_generator_t(min, max, nr_keys, alpha, beta)  {}

                        beta_generator_t(size_t min, size_t max, size_t nr_keys, float alpha, float beta);

                        //inline size_t generate() override { return generate(items_count_); }
                        inline size_t generate() override { return 0L; }
                        inline size_t last() override { return last_; }

                private:
                        float alpha_;
                        float beta_;
                        size_t last_;
                        size_t min;
                        size_t max;
                        size_t items_count_;
                        random_double_generator_t generator_;
        };


        beta_generator_t::beta_generator_t(size_t min, size_t max, size_t nr_keys, float alpha, float beta)
                : generator_(0.f, 1.f), items_count_(nr_keys){


                printf("%s: called with min:%ld, max:%ld, nr_keys:%ld, alpha:%f, beta:%f\n",
                                __func__, min, max, nr_keys, alpha, beta);
        }

        //size_t beta_generator_t::generate()

        /*
         *  * Generate Beta(alpha,beta) = X / (X+Y) where X=Gamma(alpha,1), Y=Gamma(beta,1).
         *   */
        /*
        float beta_generator_t::generateBeta(float alpha, float beta) {
                    float x = generateGamma(alpha);
                        float y = generateGamma(beta);
                            return x / (x + y);
        }
        */

} //ucsb::core
