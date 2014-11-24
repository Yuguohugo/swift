// RUN: %swift -emit-ir -target x86_64-apple-macosx10.9 -o - -primary-file %s | FileCheck %s

// Currently, this can't be a SIL file because we don't parse
// conformances correctly.

protocol Kindable {
  var kind: Int { get }
}

extension Int: Kindable {
  var kind: Int { return 0 }
}

extension Float: Kindable {
  var kind: Int { return 1 }
}

// CHECK: define hidden void @_TF21existential_metatypes5test0FT_T_()
// CHECK:      [[V:%.*]] = alloca { %swift.type*, i8** }, align 8
func test0() {
// CHECK-NEXT: [[T0:%.*]] = getelementptr inbounds { %swift.type*, i8** }* [[V]], i32 0, i32 0
// CHECK-NEXT: store %swift.type* getelementptr inbounds (%swift.full_type* @_TMdSi, i32 0, i32 1), %swift.type** [[T0]], align 8
// CHECK-NEXT: [[T0:%.*]] = getelementptr inbounds { %swift.type*, i8** }* [[V]], i32 0, i32 1
// CHECK-NEXT: store i8** getelementptr inbounds ([1 x i8*]* @_TWPSi21existential_metatypes8KindableS_, i32 0, i32 0), i8*** [[T0]], align 8
  var v: Kindable.Type = Int.self

// CHECK-NEXT: [[T0:%.*]] = getelementptr inbounds { %swift.type*, i8** }* [[V]], i32 0, i32 0
// CHECK-NEXT: store %swift.type* getelementptr inbounds (%swift.full_type* @_TMdSf, i32 0, i32 1), %swift.type** [[T0]], align 8
// CHECK-NEXT: [[T0:%.*]] = getelementptr inbounds { %swift.type*, i8** }* [[V]], i32 0, i32 1
// CHECK-NEXT: store i8** getelementptr inbounds ([1 x i8*]* @_TWPSf21existential_metatypes8KindableS_, i32 0, i32 0), i8*** [[T0]], align 8
  v = Float.self

// CHECK-NEXT: ret void
}

// CHECK: define hidden void @_TF21existential_metatypes5test1FGSqPMPS_8Kindable__T_(i128)
// CHECK:     [[TYPE_WORD:%.*]] = trunc i128 %0 to i64
// CHECK:     [[TYPE_WORD:%.*]] = trunc i128 %0 to i64
// CHECK:     [[TYPE:%.*]] = inttoptr i64 [[TYPE_WORD]] to %swift.type*
// CHECK:     [[WITNESS_SHIFT:%.*]] = lshr i128 %0, 64
// CHECK:     [[WITNESS_WORD:%.*]] = trunc i128 [[WITNESS_SHIFT]] to i64
// CHECK:     [[WITNESS:%.*]] = inttoptr i64 [[WITNESS_WORD]] to i8**
func use(t: Kindable.Type) {}
func test1(opt: Kindable.Type?) {
  switch opt {
  case .Some(let t):
    use(t)
  case .None:
    break
  }
}
