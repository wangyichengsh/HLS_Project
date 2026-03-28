#include <iostream>
#include <vector>
#include <string>



// OpenCV includes (used for the Testbench)
#include "opencv2/opencv.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/features2d.hpp"

// HLS design headers
#include "orb_extractor.h"

// If you are using Vitis Vision Libraries for the HLS part, 
// you would include "common/xf_headers.hpp" here.

using namespace std;


// C++ Helper to mimic your Python fill_result
void fill_result_cpu(cv::Mat& result, const cv::Mat& fill_image) {
    // 1. Define the area in 'result' where 'fill_image' will be placed
    // Starting at (0,0). You can change these coordinates to center it.
    cv::Rect roi(0, 0, fill_image.cols, fill_image.rows);
    
    // 2. Create a "header" that points to that specific area of result
    cv::Mat result_patch = result(roi); 

    // 3. Create a mask based ONLY on that small area
    cv::Mat mask;
    cvtColor(result_patch, mask, cv::COLOR_BGR2GRAY);
    compare(mask, 0, mask, cv::CMP_EQ); 
    
    // 4. Copy fill_image into the specific patch of result using the mask
    fill_image.copyTo(result_patch, mask);
}

// ---------------------------------------------------------------------------
// Helper: pack cv::Mat (grayscale) into AXI stream
// ---------------------------------------------------------------------------
// static void mat_to_axi_stream(const cv::Mat &gray, hls::stream<pixel_t> &stream)
// {
//     assert(gray.type() == CV_8UC1);
//     for (int r = 0; r < gray.rows; r++) {
//         for (int c = 0; c < gray.cols; c++) {
//             pixel_t px;
//             px.data = gray.at<uint8_t>(r, c);
//             px.user = (r == 0 && c == 0) ? 1 : 0;  // TUSER: Start of Frame
//             px.last = (c == gray.cols - 1) ? 1 : 0; // TLAST: End of Line
//             px.keep = 1;
//             px.strb = 1;
//             stream.write(px);
//         }
//     }
// }

static void mat_to_axi_stream(const cv::Mat &gray, hls::stream<pixel_t> &stream)
{
    assert(gray.type() == CV_8UC1);
    assert(gray.cols % 8 == 0);  

    for (int r = 0; r < gray.rows; r++) {
        for (int c = 0; c < gray.cols; c += 8) {
            pixel_t px;
            px.data = 0;
            for (int k = 0; k < 8; k++) {
                px.data |= ((uint64_t)gray.at<uint8_t>(r, c + k)) << (k * 8);
            }
            px.last = (c + 8 >= gray.cols) ? 1 : 0;  
            px.keep = 0xFF;   
            px.strb = 0xFF;
            stream.write(px);
        }
    }
}

// ---------------------------------------------------------------------------
// Helper: convert HLS Keypoint array → vector<cv::KeyPoint>
// ---------------------------------------------------------------------------
static vector<cv::KeyPoint> hls_kps_to_cv(const Keypoint kps[], int n)
{
    vector<cv::KeyPoint> out;
    out.reserve(n);
    for (int i = 0; i < n; i++) {
        cv::KeyPoint kp;
        kp.pt       = cv::Point2f((float)kps[i].x, (float)kps[i].y);
        kp.angle    = (float)kps[i].angle;
        kp.response = (float)kps[i].score;
        kp.size     = 31.0f;
        out.push_back(kp);
    }
    return out;
}

// ---------------------------------------------------------------------------
// Helper: convert HLS Descriptor array → cv::Mat (N x 32, CV_8UC1)
//   so OpenCV BFMatcher can match HLS descriptors directly
// ---------------------------------------------------------------------------
static cv::Mat hls_descs_to_cv(const Descriptor descs[], int n)
{
   // 1. Safety check for empty keypoint sets
    if (n <= 0 || descs == nullptr) {
        return cv::Mat();
    }

    // 2. Create a Matrix: n rows (keypoints) by 32 columns (bytes)
    // CV_8UC1 means 8-bit unsigned char, 1 channel
    cv::Mat out(n, 32, CV_8UC1);

    for (int i = 0; i < n; i++) {
        // 3. Get the pointer to the start of the i-th row
        uint8_t* row_ptr = out.ptr<uint8_t>(i);

        // 4. Copy the entire 32-byte struct at once
        // This is much faster than bit-shifting in a nested loop
        std::memcpy(row_ptr, &descs[i], sizeof(Descriptor));
    }

    return out;
}

bool match_and_merge(
    const cv::Mat                  &desc1,
    const cv::Mat                  &desc2,
    const vector<cv::KeyPoint>     &kp1,
    const vector<cv::KeyPoint>     &kp2,
    const cv::Mat                  &image1,
    const cv::Mat                  &image2,
    const string               &output_path)
{
    // ---- Matching ----
    cv::BFMatcher matcher(cv::NORM_HAMMING);
    vector<vector<cv::DMatch>> knn_matches;
    matcher.knnMatch(desc1, desc2, knn_matches, 2);

    // Lowe ratio test
    vector<cv::Point2f> pts1, pts2;
    for (size_t i = 0; i < knn_matches.size(); i++) {
        if (knn_matches[i][0].distance < 0.75f * knn_matches[i][1].distance) {
            pts1.push_back(kp1[knn_matches[i][0].queryIdx].pt);
            pts2.push_back(kp2[knn_matches[i][0].trainIdx].pt);
        }
    }

    cout << "  Good matches: " << pts1.size() << "\n";

    if (pts1.size() <= 4) {
        cout << "  Not enough matches for homography.\n";
        return false;
    }

    // ---- Homography ----
    cv::Mat H = findHomography(pts1, pts2, cv::RANSAC);
    if (H.empty()) {
        cout << "  Homography estimation failed.\n";
        return false;
    }

    // ---- Warp ----
    cv::Size result_size(image1.cols + image2.cols,
                     max(image1.rows, image2.rows));
    cv::Mat result;
    cv::warpPerspective(image1, result, H, result_size);

    // ---- Fill black regions with image2 ----
    cv::Rect roi(0, 0,
             min(image2.cols, result.cols),
             min(image2.rows, result.rows));
    cv::Mat result_patch = result(roi);
    cv::Mat mask;
    cvtColor(result_patch, mask, cv::COLOR_BGR2GRAY);
    compare(mask, 0, mask, cv::CMP_EQ);
    image2(cv::Rect(0, 0, roi.width, roi.height)).copyTo(result_patch, mask);

    // ---- Save ----
    imwrite(output_path, result);
    cout << "  Saved: " << output_path << "\n";
    return true;
}


int main(int argc, char** argv) {
    // 1. Load Images
    string img1_path = "foto1A.jpg";
    string img2_path = "foto1B.jpg";
    // string img1_path = "image1.jpeg";
    // string img2_path = "image2.jpeg";
    
    cv::Mat image1 = imread(img1_path, cv::IMREAD_COLOR);
    cv::Mat image2 = imread(img2_path, cv::IMREAD_COLOR);

    if (image1.empty() || image2.empty()) {
        cout << "Error: Could not load images!" << endl;
        return -1;
    }

    // 2. Pre-processing (mimicking your mode logic)
    cv::Mat gray1, gray2;
    cvtColor(image1, gray1, cv::COLOR_BGR2GRAY);
    cvtColor(image2, gray2, cv::COLOR_BGR2GRAY);

    // 3. Feature Detection (ORB)
    // In Vitis Vision, you might eventually move ORB to hardware, 
    // but in the Testbench, we use the CPU version for verification.
    cv::Ptr<cv::ORB> detector = cv::ORB::create();
    vector<cv::KeyPoint> kp1, kp2;
    cv::Mat descriptors1, descriptors2;

    detector->detectAndCompute(gray1, cv::noArray(), kp1, descriptors1);
    detector->detectAndCompute(gray2, cv::noArray(), kp2, descriptors2);


    // ---- Run HLS DUT ----
    static Keypoint   hls_kps1[MAX_KEYPOINTS],  hls_kps2[MAX_KEYPOINTS];
    static uint64_t   hls_kps1_raw[MAX_KEYPOINTS];
    static uint64_t   hls_kps2_raw[MAX_KEYPOINTS];
    static Descriptor hls_desc1[MAX_KEYPOINTS], hls_desc2[MAX_KEYPOINTS];
    int hls_n1 = 0, hls_n2 = 0;

    hls::stream<pixel_t> axi_in1("axi_in1");
    hls::stream<pixel_t> axi_in2("axi_in2");


    mat_to_axi_stream(gray1, axi_in1);
    mat_to_axi_stream(gray2, axi_in2);

    std::cout << "\nRunning HLS ORB...\n";
    // orb_extract(axi_in1, gray1.rows, gray1.cols,
    //             hls_kps1_raw, hls_desc1, &hls_n1);          
    // orb_extract(axi_in2, gray2.rows, gray2.cols,
    //             hls_kps2_raw, hls_desc2, &hls_n2); 
    orb_extract(axi_in1, 128, 128,
                hls_kps1_raw, hls_desc1, &hls_n1);          
    orb_extract(axi_in2, 128, 128,
                hls_kps2_raw, hls_desc2, &hls_n2);                        
    std::cout << "Image 1 HLS detected  : " << hls_n1 << " keypoints\n";
    std::cout << "Image 2 HLS detected  : " << hls_n2 << " keypoints\n";

    // ---- Convert HLS outputs to OpenCV types for matching ----
    for (int i = 0; i < hls_n1; i++) unpack_keypoint(hls_kps1_raw[i], hls_kps1[i]);
    for (int i = 0; i < hls_n2; i++) unpack_keypoint(hls_kps2_raw[i], hls_kps2[i]);
    vector<cv::KeyPoint> cv_kp1  = hls_kps_to_cv(hls_kps1, hls_n1);
    vector<cv::KeyPoint> cv_kp2  = hls_kps_to_cv(hls_kps2, hls_n2);
    cv::Mat              cv_desc1 = hls_descs_to_cv(hls_desc1, hls_n1);
    cv::Mat              cv_desc2 = hls_descs_to_cv(hls_desc2, hls_n2);

    match_and_merge(descriptors1, descriptors2, kp1, kp2, image1, image2, "result_opencv.jpg");
    match_and_merge(cv_desc1, cv_desc2, cv_kp1, cv_kp2, image1, image2, "result_hls.jpg");
    
    return 0;
}