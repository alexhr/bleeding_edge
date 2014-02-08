// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_CPU_MIPS_H_
#define VM_CPU_MIPS_H_

#include "vm/allocation.h"

namespace dart {

// TargetCPUFeatures gives CPU features for the architecture that we are
// generating code for. HostCPUFeatures gives the CPU features for the
// architecture that we are actually running on. When the architectures
// are the same, TargetCPUFeatures will query HostCPUFeatures. When they are
// different (i.e. we are running in a simulator), HostCPUFeatures will
// additionally mock the options needed for the target architecture so that
// they may be altered for testing.

class HostCPUFeatures: public AllStatic {
 public:
  static void InitOnce();
  static char* hardware() {
    DEBUG_ASSERT(initialized_);
    return hardware_;
  }

 private:
  static char* hardware_;
#if defined(DEBUG)
  static bool initialized_;
#endif
};

class TargetCPUFeatures : public AllStatic {
 public:
  static void InitOnce() { HostCPUFeatures::InitOnce(); }
  static bool double_truncate_round_supported() { return false; }
};

}  // namespace dart

#endif  // VM_CPU_MIPS_H_
