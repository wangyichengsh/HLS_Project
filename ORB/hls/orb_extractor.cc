#include "orb_extractor.h"

// -------------------------------------------------------
// ORB BRIEF pattern (256 pairs), precomputed for patch=31
// These are the standard ORB bit-test point pairs
// (x1,y1,x2,y2) relative to keypoint center
// -------------------------------------------------------
// Directly from OpenCV's orb.cpp bit_pattern_31_[]
// Format: {x1, y1, x2, y2} - point pair for each of 256 bit tests
static const int8_t BRIEF_PATTERN[256][4] = {
    { 8,-3, 9, 5}, { 4, 2, 7,-12}, {-11, 9,-8, 2}, { 7,-12,12,-13},
    { 2,-13, 2,12}, { 1,-7, 1, 6}, { -2,-10,-2,-4}, {-13,-13,-11,-8},
    {-13,-3,-12,-9}, {10, 4,11, 9}, {-13,-8,-8,-9}, {-11, 7,-9,12},
    { 7, 7,12, 6}, {-4,-5,-3, 0}, {-13, 2,-12,-3}, { -9, 0,-7, 5},
    {12,-6,12,-1}, {-3, 6,-2,12}, { -6,-13,-4,-8}, {11,-13,12,-8},
    { 4, 7, 5, 1}, { 5,-3,10,-3}, { 3,-7, 6,12}, { -8,-7,-6,-2},
    {-2,11,-1,-10}, {-13,12,-8,10}, {-7, 3,-5,-3}, {-4, 2,-3, 7},
    {-10,-12,-6,11}, { 5,-12, 6,-7}, { 5,-6, 7,-1}, { 1, 0, 4,-5},
    { 9,11,11,-13}, { 4, 7, 4,12}, { 2,-1, 4, 4}, {-4,-12,-2, 7},
    {-8,-5,-7,-10}, { 4,11, 9,12}, { 0,-8, 1,-13}, {-13,-2,-8, 2},
    {-3,-2,-2, 3}, {-6, 9,-4,-9}, { 8,12,10, 7}, { 0, 9, 1, 3},
    { 7,-5,11,-10}, {-13,-6,-11, 0}, {10, 7,12, 1}, {-6,-3,-6,12},
    {10,-9,12,-4}, {-13, 8,-8,-12}, {-13, 0,-8,-4}, { 3, 3, 7, 8},
    { 5, 7,10,-7}, {-1, 7, 1,-12}, { 3,-10, 5, 6}, { 2,-4, 3,-10},
    {-13, 0,-13, 5}, {-13,-7,-12,12}, {-13, 3,-11, 8}, {-7,12,-4, 7},
    { 6,-10,12, 8}, {-9,-1,-7,-6}, {-2,-5, 0,12}, {-12, 5,-7, 5},
    { 3,-10, 8,-13}, {-7,-7,-4, 5}, {-3,-2,-1,-7}, { 2, 9, 5,-11},
    {-11,-13,-5,-13}, {-1, 6, 0,-1}, { 5,-3, 5, 2}, {-4,-13,-4,12},
    {-9,-6,-9, 6}, {-12,-10,-8,-4}, {10, 2,12,-3}, { 7,12,12,12},
    {-7,-13,-6, 5}, {-4, 9,-3, 4}, { 7,-1,12, 2}, {-7, 6,-5, 1},
    {-13,11,-12, 5}, {-3, 7,-2,-6}, { 7,-8,12,-7}, {-13,-7,-11,-12},
    { 1,-3,12,12}, { 2,-6, 3, 0}, {-4, 3,-2,-13}, {-1,-13, 1, 9},
    { 7, 1, 8,-6}, { 1,-1, 3,12}, { 9, 1,12, 6}, {-1,-9,-1, 3},
    {-13,-13,-10, 5}, { 7, 7,10,12}, {12,-5,12, 9}, { 6, 3, 7,11},
    { 5,-13, 6,10}, { 2,-12, 2, 3}, { 3, 8, 4,-6}, { 2, 6,12,-13},
    { 9,-12,10, 3}, {-8, 4,-7, 9}, {-11,12,-4,-6}, { 1,12, 2,-8},
    { 6,-9, 7,-4}, { 2, 3, 3,-2}, { 6, 3,11, 0}, { 3,-3, 8,-8},
    { 7, 8, 9, 3}, {-11,-5,-6,-4}, {-10,11,-5,10}, {-5,-8,-3,12},
    {-10, 5,-9, 0}, { 8,-1,12,-6}, { 4,-6, 6,-11}, {-10,12,-8, 7},
    { 4,-2, 6, 7}, {-2, 0,-2,12}, {-5,-8,-5, 2}, { 7,-6,10,12},
    {-9,-13,-8,-8}, {-5,-13,-5,-2}, { 8,-8, 9,-13}, {-9,-11,-9, 0},
    { 1,-8, 1,-2}, { 7,-4, 9, 1}, {-2, 1,-1,-4}, {11,-6,12,-11},
    {-12,-9,-6, 4}, { 3, 7, 7,12}, { 5, 5,10, 8}, { 0,-4, 2, 8},
    {-9,12,-5,-13}, { 0, 7, 2,12}, {-1, 2, 1, 7}, { 5,11, 7,-9},
    { 3, 5, 6,-8}, {-13,-4,-8, 9}, {-5, 9,-3,-3}, {-4,-7,-3,-12},
    { 6, 5, 8, 0}, {-7, 6,-6,12}, {-13, 6,-5,-2}, { 1,-10, 3,10},
    { 4, 1, 8,-4}, {-2,-2, 2,-13}, { 2,-12,12,12}, {-2,-13, 0,-6},
    { 4, 1, 9, 3}, {-6,-10,-3,-5}, {-3,-13,-1, 1}, { 7, 5,12,-11},
    { 4,-2, 5,-7}, {-13, 9,-9,-5}, { 7, 1, 8, 6}, { 7,-8, 7, 6},
    {-7,-4,-7, 1}, {-8,11,-7,-8}, {-13, 6,-12,-8}, { 2, 4, 3, 9},
    {10,-5,12, 3}, {-6,-5,-6, 7}, { 8,-3, 9,-8}, { 2,-12, 2, 8},
    {-11,-2,-10, 3}, {-12,-13,-7,-9}, {-11, 0,-10,-5}, { 5,-3,11, 8},
    {-2,-13,-1,12}, {-1,-8, 0, 9}, {-13,-11,-12,-5}, {-10,-2,-10,11},
    {-3, 9,-2,-13}, { 2,-3, 3, 2}, {-9,-13,-4, 0}, {-4, 6,-3,-10},
    {-4,12,-2,-7}, {-6,-11,-4, 9}, { 6,-3, 6,11}, {-13,11,-5, 5},
    {11,11,12, 6}, { 7,-5,12,-2}, {-1,12, 0, 7}, {-4,-8,-3,-2},
    {-7, 1,-6, 7}, {-13,-12,-8,-13}, {-7,-2,-6,-8}, {-8, 5,-6,-9},
    {-5,-1,-4, 5}, {-13, 7,-8,10}, { 1, 5, 5,-13}, { 1, 0,10,-13},
    { 9,12,10,-1}, { 5,-8,10,-9}, {-1,11, 1,-13}, {-9,-3,-6, 2},
    {-1,-10, 1,12}, {-13, 1,-8,-10}, { 8,-11,10,-6}, { 2,-13, 3,-6},
    { 7,-13,12,-9}, {-10,-10,-5,-7}, {-10,-8,-8,-13}, { 4,-6, 8, 5},
    { 3,12, 8,-13}, {-4, 2,-3,-3}, { 5,-13,10,-12}, { 4,-13, 5,-1},
    {-9, 9,-4, 3}, { 0, 3, 3,-9}, {-12, 1,-6, 1}, { 3, 2, 4,-8},
    {-10,-10,-10, 9}, { 8,-13,12,12}, {-8,-12,-6,-5}, { 2, 2, 3, 7},
    {10, 6,11,-8}, { 6, 8, 8,-12}, {-7,10,-6, 5}, {-3,-9,-3, 9},
    {-1,-13,-1, 5}, {-3,-7,-3, 4}, {-8,-2,-8, 3}, { 4, 2,12,12},
    { 2,-5, 3,11}, { 6,-9,11,-13}, { 3,-1, 7,12}, {11,-1,12, 4},
    {-3, 0,-3, 6}, { 4,-11, 4,12}, { 2,-4, 2, 1}, {-10,-6,-8, 1},
    {-13, 7,-11, 1}, {-13,12,-11,-13}, { 6, 0,11,-13}, { 0,-1, 1, 4},
    {-13, 3,-9,-2}, {-9, 8,-6,-3}, {-13,-6,-8,-2}, { 5,-9, 8,10},
    { 2, 7, 3,-9}, {-1,-6,-1,-1}, { 9, 5,11,-2}, {11,-3,12,-8},
    { 3, 0, 3, 5}, {-1, 4, 0,10}, { 3,-6, 4, 5}, {-13, 0,-10, 5},
    { 5, 8,12,11}, { 8, 9, 9,-6}, { 7,-4, 8,-12}, {-10, 4,-10, 9},
    { 7, 3,12, 4}, { 9,-7,10,-2}, { 7, 0,12,-2}, {-1,-6, 0,-11}
};

// -------------------------------------------------------
// Compute intensity centroid angle for a keypoint
// Returns angle in degrees * 256 (Q8 fixed point)
// -------------------------------------------------------
static int16_t compute_orientation_buf(
    uint8_t buf[], int kx, int ky, int rows, int cols)
{
    int32_t m10 = 0, m01 = 0;
    const int R = 15; // patch radius

    ORIENT_ROW: for (int dy = -R; dy <= R; dy++) {

        int row = ky + dy;
        if (row < 0 || row >= rows) continue;

        ORIENT_COL: for (int dx = -R; dx <= R; dx++) {
            #pragma HLS PIPELINE II=1
            int col = kx + dx;
            if (col < 0 || col >= cols) continue;
            if (dx*dx + dy*dy > R*R) continue;

            uint8_t val = buf[row * cols + col];
            m10 += dx * val;
            m01 += dy * val;
        }
    }

    // Approximate atan2 using lookup / CORDIC (simplified here)
    // In real HLS you'd use hls::atan2 or a LUT
    int32_t angle_deg = 0;
    if (m10 != 0 || m01 != 0) {
        // Simple octant-based approximation
        // For production: use ap_fixed atan2 or cordic
        if (m10 >= 0 && m01 >= 0) {
            angle_deg = (m01 * 90) / (m10 + m01 + 1);
        } else if (m10 < 0 && m01 >= 0) {
            angle_deg = 90 + ((-m10) * 90) / (-m10 + m01 + 1);
        } else if (m10 < 0 && m01 < 0) {
            angle_deg = 180 + ((-m01) * 90) / (-m10 + (-m01) + 1);
        } else {
            angle_deg = 270 + (m10 * 90) / (m10 + (-m01) + 1);
        }
    }
    return (int16_t)(angle_deg);
}

// -------------------------------------------------------
// Rotate a BRIEF pattern point by angle and sample image
// -------------------------------------------------------
static uint8_t sample_pixel_buf(
    uint8_t buf[], int cx, int cy,
    int8_t px, int8_t py,
    int16_t cos_a, int16_t sin_a,
    int rows, int cols)
{ 
    // Rotate point (px,py) by angle
    int rx = (px * cos_a - py * sin_a) >> 8;
    int ry = (px * sin_a + py * cos_a) >> 8;

    int sx = cx + rx;
    int sy = cy + ry;

    if (sx < 0) sx = 0;
    if (sy < 0) sy = 0;
    if (sx >= cols) sx = cols - 1;
    if (sy >= rows) sy = rows - 1;

    return buf[sy * cols + sx];
}

// -------------------------------------------------------
// Compute steered BRIEF descriptor for one keypoint
// -------------------------------------------------------
static void compute_descriptor_buf(
    uint8_t buf[], int kx, int ky, int16_t angle,
    int rows, int cols, uint64_t desc_out[4])
{ 
#pragma HLS ARRAY_PARTITION variable=BRIEF_PATTERN complete dim=0
    uint64_t d[4] = {0, 0, 0, 0};
    // Precompute cos/sin in Q8
    // Use ap_fixed or a small LUT for cos/sin
    // Simplified: use integer approximation
    int16_t cos_a, sin_a;
    // Map angle (0-359) to Q8 cos/sin
    // For real implementation: use ROM lookup table
    int a = angle;
    // Very coarse approximation - replace with LUT in production
    if      (a <  45) { cos_a = 256;  sin_a = a*256/45;   }
    else if (a <  90) { cos_a = (90-a)*256/45; sin_a = 256; }
    else if (a < 135) { cos_a = -(a-90)*256/45; sin_a = 256; }
    else if (a < 180) { cos_a = -256; sin_a = (180-a)*256/45; }
    else if (a < 225) { cos_a = -256; sin_a = -(a-180)*256/45; }
    else if (a < 270) { cos_a = -(270-a)*256/45; sin_a = -256; }
    else if (a < 315) { cos_a = (a-270)*256/45; sin_a = -256; }
    else              { cos_a = 256; sin_a = -(360-a)*256/45; }

    d[0] = d[1] = d[2] = d[3] = 0;

    BRIEF_LOOP: for (int i = 0; i < 256; i++) {
#pragma HLS PIPELINE II=1
        uint8_t p1 = sample_pixel_buf(buf, kx, ky,
                                  BRIEF_PATTERN[i][0],
                                  BRIEF_PATTERN[i][1],
                                  cos_a, sin_a,
                                  rows, cols);
        uint8_t p2 = sample_pixel_buf(buf, kx, ky,
                                  BRIEF_PATTERN[i][2],
                                  BRIEF_PATTERN[i][3],
                                  cos_a, sin_a,
                                  rows, cols);
                                  
        if (p1 < p2) {
            d[i / 64] |= (uint64_t)1 << (i % 64);
        }
    }
    desc_out[0] = d[0];
    desc_out[1] = d[1];
    desc_out[2] = d[2];
    desc_out[3] = d[3];
}

static void dump_to_bram(
    img_mat_t &src,
    uint8_t    dst[MAX_HEIGHT * MAX_WIDTH],
    int        rows, int cols)
{
    DUMP_LOOP: for (int i = 0; i < rows * cols; i++) {
    #pragma HLS PIPELINE II=1
        dst[i] = (uint8_t)src.read(i);
    }
}

static void dump_fast_mask(
    img_mat_t &src,
    uint8_t    dst[MAX_HEIGHT * MAX_WIDTH])
{
    FAST_DUMP_LOOP: for (int i = 0; i < LOOP_COUNT; i++) {
    #pragma HLS PIPELINE II=1
    #pragma HLS LOOP_TRIPCOUNT min=LOOP_COUNT max=LOOP_COUNT
        XF_TNAME(XF_8UC1, XF_NPPC8) val = src.read(i);
        for (int k = 0; k < XF_NPPC8; k++) {
        #pragma HLS UNROLL
            dst[i * XF_NPPC8 + k] = (uint8_t)(val >> (k * 8));
        }
    }
}

static void split_blur(
    img_mat_t &src,
    img_mat_t &dst_fast,      
    uint8_t    dst_buf[])
{
    for (int i = 0; i < LOOP_COUNT; i++) {
    #pragma HLS PIPELINE II=1
        XF_TNAME(XF_8UC1, XF_NPPC8) val = src.read(i);
        dst_fast.write(i, val);  
        for (int k = 0; k < XF_NPPC8; k++) {
        #pragma HLS UNROLL
            dst_buf[i * XF_NPPC8 + k] = (uint8_t)(val >> (k * 8));
        }
    }
}


static void dataflow_pipeline(
    hls::stream<pixel_t> &image_in,
    uint8_t blur_buf[MAX_HEIGHT * MAX_WIDTH],
    uint8_t fast_buf[MAX_HEIGHT * MAX_WIDTH],
    int rows, int cols)
{
#pragma HLS DATAFLOW  
    img_mat_t img_raw(rows, cols);
    img_mat_t img_blur(rows, cols);
    img_mat_t img_blur_fast(rows, cols);
    img_mat_t img_fast(rows, cols);

#pragma HLS stream variable=img_raw.data
#pragma HLS stream variable=img_blur.data
#pragma HLS stream variable=img_blur_fast.data
#pragma HLS stream variable=img_fast.data

    xf::cv::axiStrm2xfMat<64, XF_8UC1, MAX_HEIGHT, MAX_WIDTH, XF_NPPC8>
        (image_in, img_raw);

    xf::cv::GaussianBlur<7, XF_BORDER_REFLECT_101,
                    XF_8UC1, MAX_HEIGHT, MAX_WIDTH, XF_NPPC8>
    (img_raw, img_blur, 2.0f);

    split_blur(img_blur, img_blur_fast, blur_buf);

    xf::cv::fast<1, XF_8UC1, MAX_HEIGHT, MAX_WIDTH, XF_NPPC8>
    (img_blur_fast, img_fast, 20);

    dump_fast_mask(img_fast, fast_buf);
}


// -------------------------------------------------------
// Top-level ORB extractor
// -------------------------------------------------------
void orb_extract(
    hls::stream<pixel_t> &image_in,
    int rows, int cols,
    uint64_t   keypoints_out[MAX_KEYPOINTS],  
    Descriptor descriptors_out[MAX_KEYPOINTS],
    int *num_keypoints)
{
#pragma HLS INTERFACE axis      port=image_in
#pragma HLS INTERFACE s_axilite port=rows
#pragma HLS INTERFACE s_axilite port=cols
#pragma HLS INTERFACE m_axi     port=keypoints_out   bundle=KP_BUS \
                                depth=MAX_KEYPOINTS   offset=slave
#pragma HLS INTERFACE m_axi     port=descriptors_out bundle=DESC_BUS \
                                depth=MAX_KEYPOINTS   offset=slave
#pragma HLS INTERFACE s_axilite port=num_keypoints
#pragma HLS INTERFACE s_axilite port=return

    // ---------- Step 1: Receive AXI stream into Mat ----------

    static uint8_t blur_buf[MAX_HEIGHT * MAX_WIDTH];
    #pragma HLS BIND_STORAGE variable=blur_buf type=RAM_T2P impl=BRAM
    static uint8_t fast_buf[MAX_HEIGHT * MAX_WIDTH];
    #pragma HLS BIND_STORAGE variable=fast_buf type=RAM_2P impl=BRAM

    static Keypoint kp_buf[MAX_KEYPOINTS];
    #pragma HLS BIND_STORAGE variable=kp_buf type=RAM_T2P impl=BRAM

    dataflow_pipeline(image_in, blur_buf, fast_buf, rows, cols);

    // ---------- Step 4: Collect keypoints from FAST mask ----------
    int nkp = 0;


    COLLECT_KP: for (int r = PATCH_SIZE/2; r < rows - PATCH_SIZE/2; r++) {
        for (int c = PATCH_SIZE/2; c < cols - PATCH_SIZE/2; c++) {
            #pragma HLS PIPELINE II=1
            uint8_t val = fast_buf[r * cols + c]; 
            int idx = (nkp < MAX_KEYPOINTS) ? nkp : MAX_KEYPOINTS - 1;
            bool valid = (val > 0) && (nkp < MAX_KEYPOINTS);
            if (valid) {
                kp_buf[idx].x     = c;
                kp_buf[idx].y     = r;
                kp_buf[idx].score = val;
                kp_buf[idx].angle = 0;  
                nkp++;
            }
        }  
    }
    *num_keypoints = nkp;
    


    // ---------- Step 5: Orientation + Descriptor ----------
    DESC_LOOP: for (int i = 0; i < nkp; i++) {
        int kx = kp_buf[i].x;
        int ky = kp_buf[i].y;

        int16_t angle = compute_orientation_buf(blur_buf, kx, ky, rows, cols);
        kp_buf[i].angle = angle;

        compute_descriptor_buf(blur_buf, kx, ky, angle, rows, cols, descriptors_out[i].d);
    }

    WRITEBACK: for (int i = 0; i < nkp; i++) {
    #pragma HLS PIPELINE II=1
        keypoints_out[i] = pack_keypoint(kp_buf[i]);
    }
}