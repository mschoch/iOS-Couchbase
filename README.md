## Mobile Couchbase for iOS - Everything is Fat Branch

This branch is intended to illustrate one way iOS-Couchbase could move towards a single target for each library, creating fat binaries (armv6, armv7, i386).

### Summary of Changes

* Demo.app and it's non-couchbase dependencies have been removed
* Git Submodules for Vendor libraries also point to my clone
* openssl/lib now contains pre-built fat libraries as well as existing ones
* iMonkey now has a single target which produces a fat libiMonkey.a
* iErl14 now has a single target which produces a fat libiErl14.a
* Couchbase has 3 targets
** One which produces a fat libCouchbase.a
** The second produces Couchbase.bundle (unchanged)
** The third which produces the Couchbase User Package (zip)
* iMoneky, iErl14, and Couchbase fat binary targets are all created using a variation on the script described here:  http://stackoverflow.com/questions/3520977/build-fat-static-library-device-simulator-using-xcode-and-sdk-4

### Taking a look

     git clone git@github.com:mschoch/iOS-Couchbase.git
     cd iOS-Couchbase
     git checkout -b everything-is-fat origin/everything-is-fat
     git submodule init
     git submodule update
     open Couchbase.xcworkspace

### Details of how fat binaries are built

Producing fat binaries in Xcode 4 presents some problems because the notion of the "active architecture" gets somewhat locked in by the scheme you've selected to build.  The approach taken in this repository to work around the problem is as follows:

Each library has a target designed to build the static library.  On its own, Xcode would either build this for (armv6,armv7) or (i386) depending on whether or not you selected a device or a simulator.  Instead, we add a "Run Script" phase at the end of the build.  This script is stored in a file named "Scripts/createUniversalLibrary.sh".

The createUniversalLibrary.sh script is run after the libary has already been built.  The first thing the script determines is which platform you built for (device or simulator).  It then determines the correct parameters to build the library for the other platform and invokes the xcodebuild commandline.  NOTE: since it is the same target we started in, the script will be invoked recursively and has logic to handle this appropriately.  Once this has completed, and we are in the top-level invocation of the script, we now have 2 libraries built, one for (armv6,armv7) and the other for (i386).  Finally, we invoke lipo to merge the libraries into a single fat binary.

Along the way there are some file rename operations so that Xcode sees the result of lipo (and not the individual libraries) as its final build product.  This is important because the final fat binary is what we want to use when linking with other projects in the workspace.
 
### Observations

#### Pros

* Removing the Demo and associated libraries makes the repo feel lighter
* Reducing the number of targets/schemes in the workspace makes it more approachable

#### Cons

* Each target takes longer to run now because its building for multiple architectures
* The reliance on the scripting makes the whole thing more fragile

### Discussion

Please share your thoughts on this approach on the <a href="https://groups.google.com/group/mobile-couchbase">Google Group for Mobile Couchbase</a>
