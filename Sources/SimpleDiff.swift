//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

// Code in this file is based on simplediff by Paul Butler
// simplediff: https://github.com/paulgb/simplediff

internal enum SimpleDiffOperation<T> {
  case insert(elements: [T])
  case delete(elements: [T])
  case noop(elements: [T])
}

internal func simpleDiff<T where T: Hashable, T: Equatable>(_ before: Array<T>, after: Array<T>) -> [SimpleDiffOperation<T>] {
  
  var oldIndexMap: [T: [Int]] = before.enumerated().reduce([:]) { dict, e in
    var newDict = dict
    var temp = dict[e.element] ?? []
    temp.append(e.offset)
    newDict[e.element] = temp
    return newDict
  }
  
  var overlap = [Int: Int]()
  var subStartOld = 0
  var subStartNew = 0
  var subLength = 0

  for (indexNew, element) in after.enumerated() {
    var newOverlap = [Int: Int]()
    
    for indexOld in oldIndexMap[element] ?? [] {
      
      let overlapLength = (overlap[indexOld - 1] ?? 0) + 1
      newOverlap[indexOld] = overlapLength
      
      if overlapLength > subLength {
        subLength = overlapLength
        subStartOld = indexOld - subLength + 1
        subStartNew = indexNew - subLength + 1
      }
    }
    
    overlap = newOverlap
  }
  
  if subLength == 0 {
    return (before.count > 0 ? [SimpleDiffOperation.delete(elements: Array(before))] : []) + (after.count > 0 ? [SimpleDiffOperation.insert(elements: Array(after))] : [])
  } else {
    let beforeOperations = simpleDiff(Array(before[0..<subStartOld]), after: Array(after[0..<subStartNew]))
    let noopOperation = SimpleDiffOperation.noop(elements: Array(after[subStartNew..<subStartNew+subLength]))
    let afterOperations = simpleDiff(Array(before[subStartOld+subLength..<before.count]), after: Array(after[subStartNew+subLength..<after.count]))
    return beforeOperations + [noopOperation] + afterOperations
  }
}
