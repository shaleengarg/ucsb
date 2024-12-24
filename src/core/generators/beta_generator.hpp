#pragma once

#include <random>
#include <cassert>

#include <stdlib.h>
#include <math.h>

#include "src/core/generators/generator.hpp"
#include "src/core/generators/random_generator.hpp"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace ucsb::core {

    class beta_generator_t : public generator_gt<size_t> {
        public:

            static constexpr float alpha = 2;
            static constexpr float beta = 5;

            beta_generator_t(size_t min, size_t max) : beta_generator_t(min, max, (max-min+1), alpha, beta) {}

            beta_generator_t(size_t min, size_t max, size_t nr_keys)
                : beta_generator_t(min, max, nr_keys, alpha, beta)  {}

            beta_generator_t(size_t min, size_t max, size_t nr_keys, float alpha, float beta);

            inline size_t generate() override;
            inline size_t last() override { return last_; }

        private:
            float alpha_;
            float beta_;
            size_t last_;
            size_t min_;
            size_t max_;
            size_t items_count_;
            random_double_generator_t generator_;

            float generateStandardNormal();
            float generateGamma(float alpha);
            float generateBeta(float alpha, float beta);
    };


    beta_generator_t::beta_generator_t(size_t min, size_t max, size_t nr_keys,
            float alpha, float beta) : items_count_(nr_keys), generator_(0.f, 1.f){


        printf("%s: called with min:%ld, max:%ld, nr_keys:%ld, alpha:%f, beta:%f\n",
                __func__, min, max, nr_keys, alpha, beta);

        alpha_ = alpha;
        beta_ = beta;
        min_ = min;
        max_ = max;
    }

    size_t beta_generator_t::generate(){
        size_t key;
        float b = generateBeta(alpha_, beta_);    // b in [0,1]
        float val = min_ + b * items_count_;         // scale to [min_, max_]
        key = (size_t)roundf(val);
        last_ = key;

        return key;
    }

    /*
     * Generate Beta(alpha,beta) = X / (X+Y) where X=Gamma(alpha,1), Y=Gamma(beta,1).
     */

    float beta_generator_t::generateBeta(float alpha, float beta) {
        float x = generateGamma(alpha);
        float y = generateGamma(beta);
        return x / (x + y);
    }

    /*
     *  * Generate a standard normal random (mean=0, std=1) using the Box–Muller transform.
     *   */
    float beta_generator_t::generateStandardNormal(){
        float u1 = generator_.generate();
        float u2 = generator_.generate();

        float r  = sqrtf(-2.0f * logf(u1));
        float th = 2.0f * (float)M_PI * u2;

        float z  = r * cosf(th);  // One of the Box–Muller outputs
        return z;
    }

    /*
     * Generate Gamma(shape=alpha, scale=1) using Marsaglia & Tsang's method.
     * This handles alpha > 0.
     */
    float beta_generator_t::generateGamma(float alpha) {
        // If alpha < 1, use the Johnk's trick: gamma(alpha) = gamma(alpha+1)*U^(1/alpha).
        if (alpha < 1.0f) {
            //float u = uniformRand();
            float u = generator_.generate();
            // Recursively generate gamma(alpha+1)
            float x = generateGamma(alpha + 1.0f);
            // Scale it down
            return x * powf(u, 1.0f / alpha);
        }

        // For alpha >= 1, use Marsaglia & Tsang
        float d = alpha - 1.0f/3.0f;
        float c = 1.0f / sqrtf(9.0f * d);

        while (1) {
            float z = generateStandardNormal();
            float v = 1.0f + c * z;
            if (v <= 0.0f)
                continue;

            v = v * v * v;  // v^3
            //float u = uniformRand();
            float u = generator_.generate();

            // First quick acceptance check
            if (u < 1.0f - 0.0331f * (z * z) * (z * z)) {
                return d * v;
            }

            // Second, more strict check
            if (logf(u) < 0.5f * z * z + d * (1.0f - v + logf(v))) {
                return d * v;
            }
        }
    }

} //ucsb::core
