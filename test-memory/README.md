
# Browser Memory Allocation

These are tests to understand how of allocation of large memory blocks work in various JavaScript engines.  Chrome, being a 32 bit application on Mac, is limited in the amount of memory it can allocate (2 GBs?).

  * Case: Allocate 2GBs in one function call
  * Case: Allocate 2GBs incrementally
  