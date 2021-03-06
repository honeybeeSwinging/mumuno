//
//  Medium_075_Sort_Colors.swift
//  algorithms
//
//  Created by 李晓东 on 2018/3/31.
//  Copyright © 2018年 XD. All rights reserved.
//

/*
 
 https://leetcode.com/problems/sort-colors/
 
 #75 Sort Colors
 
 Given an array with n objects colored red, white or blue, sort them so that objects of the same color are adjacent, with the colors in the order red, white and blue.
 
 Here, we will use the integers 0, 1, and 2 to represent the color red, white, and blue respectively.
 
 Note:
 You are not suppose to use the library's sort function for this problem.
 
 click to show follow up.
 
 Follow up:
 A rather straight forward solution is a two-pass algorithm using counting sort.
 First, iterate the array counting number of 0's, 1's, and 2's, then overwrite array with total number of 0's, then 1's and followed by 2's.
 
 Could you come up with an one-pass algorithm using only constant space?
 
 Inspired by @xianlei at https://leetcode.com/discuss/1827/anyone-with-one-pass-and-constant-space-solution
 
 题解：
 0 -> 红
 1 -> 白
 2 -> 蓝
 给定一个数组里面的元素用来表示红白蓝三种颜色，排序后使得代表相同颜色的元素相邻在一起，
 
 要求不使用自带排序函数，计数排序
 
 */

import Foundation

struct Medium_075_Sort_Colors {
    static func sortColors(_ nums: inout [Int]) {
        var red = -1
        var blue = -1
        var white = -1
        
        for i in 0..<nums.count {
            if nums[i] == 0 {
                blue += 1
                white += 1
                red += 1
                nums[blue] = 2
                nums[white] = 1
                nums[red] = 0
            } else if nums[i] == 1 {
                blue += 1
                white += 1
                nums[blue] = 2
                nums[white] = 1
            } else {
                blue += 1
                nums[blue] = 2
            }
        }
    }
}
