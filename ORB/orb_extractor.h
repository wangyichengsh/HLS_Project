#pragma once

#include <stdint.h>

#include "ap_int.h"
#include "hls_stream.h"
#include "common/xf_common.hpp"
#include "common/xf_infra.hpp"
#include "imgproc/xf_gaussian_filter.hpp"
#include "imgproc/xf_pyr_down.hpp"
#include "features/xf_fast.hpp"


#define MAX_HEIGHT  683
#define MAX_WIDTH   1024
#define MAX_KEYPOINTS 500
#define PATCH_SIZE  31      // ORB patch radius = 15
#define DESCRIPTOR_BITS 256 // standard ORB

typedef ap_axiu<8, 1, 1, 1> pixel_t;
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
    Keypoint   keypoints_out[MAX_KEYPOINTS],
    Descriptor descriptors_out[MAX_KEYPOINTS],
    int *num_keypoints
);