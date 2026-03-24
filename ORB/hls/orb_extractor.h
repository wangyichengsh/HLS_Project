#pragma once

#include <stdint.h>

#include "ap_int.h"
#include "hls_stream.h"
#include "common/xf_common.hpp"
#include "common/xf_utility.hpp"
#include "common/xf_infra.hpp"
#include "imgproc/xf_gaussian_filter.hpp"
#include "imgproc/xf_pyr_down.hpp"
#include "features/xf_fast.hpp"


// #define MAX_HEIGHT  683
// #define MAX_WIDTH   1024
#define MAX_HEIGHT  128
#define MAX_WIDTH   128
#define MAX_KEYPOINTS 500
#define PATCH_SIZE  31      // ORB patch radius = 15
#define DESCRIPTOR_BITS 256 // standard ORB

typedef ap_axiu<8, 0, 0, 0> pixel_t;
typedef xf::cv::Mat<XF_8UC1, MAX_HEIGHT, MAX_WIDTH, XF_NPPC1> img_mat_t;

struct Keypoint {
    uint16_t x;
    uint16_t y;
    int16_t  angle;   // Q8 fixed point degrees * 256
    uint8_t  score;
};

// 256-bit descriptor: 4x 64-bit words
struct Descriptor {
    uint64_t d[4];
};

void orb_extract(
    hls::stream<pixel_t> &image_in,
    int rows, int cols,
    uint64_t   keypoints_out[MAX_KEYPOINTS],  
    Descriptor descriptors_out[MAX_KEYPOINTS],
    int *num_keypoints
);

inline uint64_t pack_keypoint(const Keypoint &kp) {
    // x(16) | y(16) | angle(16) | score(8) | pad(8) = 64bit
    return ((uint64_t)(uint16_t)kp.x)           |
           ((uint64_t)(uint16_t)kp.y     << 16) |
           ((uint64_t)(uint16_t)kp.angle << 32) |
           ((uint64_t)(uint8_t) kp.score << 48);
}

inline void unpack_keypoint(uint64_t raw, Keypoint &kp) {
    kp.x     = (uint16_t)(raw);
    kp.y     = (uint16_t)(raw >> 16);
    kp.angle = (int16_t) (raw >> 32);
    kp.score = (uint8_t) (raw >> 48);
}