/*
 * Copyright (c) 2012, the Dart project authors.
 * 
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.google.dart.tools.core.analysis;

class NullTask extends Task {

  public static NullTask newBackgroundTask() {
    return new NullTask(false, true, "background");
  }

  public static NullTask newRequestTask() {
    return new NullTask(false, false, "request");
  }

  public static NullTask newUpdateTask() {
    return new NullTask(true, false, "update");
  }

  private final boolean isPriority;
  private final boolean isBackground;
  private final String typeName;

  private NullTask(boolean isPriority, boolean isBackground, String typeName) {
    this.isPriority = isPriority;
    this.isBackground = isBackground;
    this.typeName = typeName;
  }

  @Override
  public boolean isBackgroundAnalysis() {
    return isBackground;
  }

  @Override
  public boolean isPriority() {
    return isPriority;
  }

  @Override
  public void perform() {
  }

  @Override
  public String toString() {
    return getClass().getSimpleName() + "[" + typeName + "," + hashCode() + "]";
  }
}
