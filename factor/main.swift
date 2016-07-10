//
//  main.swift
//  factor
//
//  Created by Tim Wilson-Brown on 4/04/2016.
//  Copyright © 2016 teor - gmail: teor2345
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

// Prime Module

func appendNextPrime<IntT: IntegerType>(inout primeArray: [IntT]) {
  if primeArray.isEmpty {
    primeArray.append(2)
  } else if primeArray.count == 1 {
      primeArray.append(3)
  } else {
    var nextPrime = primeArray.last! + 2
    // Loop until we find a prime and return
    while true {
      for prime in primeArray {
        // Prime: not divisible by any prime less than or equal to its
        //        square root
        if nextPrime < prime * prime {
          primeArray.append(nextPrime)
          return
        }
        // Composite: divisible by a prime
        if nextPrime % prime == 0 {
          nextPrime = nextPrime + 2
          break
        }
      }
    }
  }
}

func primeAtIndexUsingKnownPrimes<IntT: IntegerType>(index: Int, inout knownPrimes: [IntT]) -> IntT {
  // Make sure there are enough primes
  while knownPrimes.count <= index {
    appendNextPrime(&knownPrimes)
  }
  return knownPrimes[index]
}

func primeAtIndex<IntT: IntegerType>(index: Int) -> IntT {
  var dummyPrimes = [IntT]()
  return primeAtIndexUsingKnownPrimes(index, knownPrimes: &dummyPrimes)
}

func indexOfPrimeUsingKnownPrimes<IntT: IntegerType>(prime: IntT, inout knownPrimes: [IntT]) -> Int {
  // Make sure there are enough primes
  while knownPrimes.isEmpty || knownPrimes.last! < prime {
    appendNextPrime(&knownPrimes)
  }
  // If this fails, we've been passed a composite, or a value thats 1 or less
  //assert(knownPrimes.contains(prime))
  return knownPrimes.indexOf(prime)!
}

func indexOfPrime<IntT: IntegerType>(prime: IntT) -> Int {
  var dummyPrimes = [IntT]()
  return indexOfPrimeUsingKnownPrimes(prime, knownPrimes: &dummyPrimes)
}

func nextPrimeUsingKnownPrimes<IntT: IntegerType>(prime: IntT, inout knownPrimes: [IntT]) -> IntT {
  let index = indexOfPrimeUsingKnownPrimes(prime, knownPrimes: &knownPrimes)
  return primeAtIndexUsingKnownPrimes(index + 1, knownPrimes: &knownPrimes)
}

func nextPrime<IntT: IntegerType>(prime: IntT) -> IntT {
  var dummyPrimes = [IntT]()
  return nextPrimeUsingKnownPrimes(prime, knownPrimes: &dummyPrimes)
}

// If you only want to check one prime, this function is better than indexOfPrime,
// because it only uses known primes up to the square root of the candidate
func isPrimeUsingKnownPrimes<IntT: IntegerType>(candidate: IntT, inout knownPrimes: [IntT]) -> Bool {
  // Short-Circuit known primes
  if knownPrimes.contains(candidate) {
    return true
  }
  var divisor = primeAtIndexUsingKnownPrimes(0, knownPrimes: &knownPrimes)
  while candidate >= divisor * divisor {
    // Composite: divisible by a prime
    if candidate % divisor == 0 {
      return false
    }
    divisor = nextPrimeUsingKnownPrimes(divisor, knownPrimes: &knownPrimes)
  }
  // Prime: not divisible by any prime less than or equal to its
  //        square root
  return true
}

func isPrime<IntT: IntegerType>(candidate: IntT) -> Bool {
  var dummyPrimes = [IntT]()
  return isPrimeUsingKnownPrimes(candidate, knownPrimes: &dummyPrimes)
}

// Factor Module

func primeFactorsUsingKnownPrimes<IntT: IntegerType>(n: IntT, inout knownPrimes: [IntT]) -> [IntT] {
  // We can't handle negative numbers without choosing between signed and
  // unsigned integers. (And that would screw up the generics.)
  //assert(n >= 0)
  // Handle things that don't have prime factors
  if n == 0 || n == 1 {
    return [n]
  }
  // Short-Circuit known primes
  if knownPrimes.contains(n) {
    return [n]
  }

  // Do the calculation
  var residual = n
  var factors = [IntT]()

  var divisor = primeAtIndexUsingKnownPrimes(0, knownPrimes: &knownPrimes)
  // If residual is less than divisor squared, it's the final factor
  while residual >= divisor*divisor {
    while residual % divisor == 0 {
      residual = residual / divisor
      factors.append(divisor)
    }
    divisor = nextPrimeUsingKnownPrimes(divisor, knownPrimes: &knownPrimes)
  }
  if residual > 1 {
    //assert(isPrimeUsingKnownPrimes(residual, knownPrimes: &knownPrimes))
    factors.append(residual)
  }
  return factors
}

func primeFactors<IntT: IntegerType>(n: IntT) -> [IntT] {
  var dummyPrimes = [IntT]()
  return primeFactorsUsingKnownPrimes(n, knownPrimes: &dummyPrimes)
}

// Convert the list of prime factors into p^a * q^b format (a bag)
func primeFactorDescription<IntT: IntegerType>(factors: [IntT]) -> String {
  if factors.isEmpty {
    return ""
  }

  var desc = ""
  var index = 0
  var power = 1
  while index < factors.count {
    // if the next factor is different, or we're at the end
    if index + 1 >= factors.count || factors[index + 1] != factors[index] {
      // print this factor at its power
      desc += String(factors[index])
      if power > 1 {
        desc += "^" + String(power)
      }
      power = 1
      // multiply by the next factor, if there is one
      if (index < factors.count - 1) {
        desc += " * "
      }
    } else {
      // increase the power of this factor, don't print anything yet
      power += 1
    }
    index += 1
  }
  return desc
}

// Smoke Test

//while primes.isEmpty || primes.last! < 10000 {
//  appendNextPrime(&primes)
//}

//for prime in primes {
  // Don't re-use the prime array to check its own values
//  assert(isPrime(prime))
//}

// print(primes, separator: ", ", terminator: "\n");

// Factor Run

var primes = [UIntMax]()
var i = UIntMax(2)
var longest = UIntMax(0)
var longestFactors = [UIntMax]()
var longestFactorStr = ""
while i <= 100*1000*1000 {
  let factors = primeFactorsUsingKnownPrimes(i, knownPrimes: &primes)
  let factorStr = primeFactorDescription(factors)
  //print("\(i): \(factorStr)")
  if factorStr.characters.count > longestFactorStr.characters.count {
    longest = i
    longestFactors = factors
    longestFactorStr = factorStr
    print("\(longestFactorStr) = \(longest)")
  }
  i += 1
}