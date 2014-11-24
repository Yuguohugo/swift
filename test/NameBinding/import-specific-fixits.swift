// RUN: rm -f %t.*
// RUN: rm -rf %t
// RUN: mkdir -p %t
// RUN: %swift -emit-module -o %t %S/Inputs/ambiguous_left.swift
// RUN: %swift -emit-module -o %t %S/Inputs/ambiguous_right.swift
// RUN: %swift -emit-module -o %t -I %t %S/Inputs/ambiguous.swift

// RUN: echo "public var x = Int()" | %swift -target x86_64-apple-macosx10.9 -module-name FooBar -emit-module -o %t -
// RUN: %swift -parse -I=%t -serialize-diagnostics-path %t.dia %s -verify
// RUN: c-index-test -read-diagnostics %t.dia > %t.deserialized_diagnostics.txt 2>&1
// RUN: FileCheck --input-file=%t.deserialized_diagnostics.txt %s

import typealias Swift.Int
import struct Swift.Int

import class Swift.Int // expected-error {{'Int' was imported as 'class', but is a struct}} {{8-13=struct}}
import func Swift.Int // expected-error {{'Int' was imported as 'func', but is a struct}} {{8-12=struct}}
import var Swift.Int // expected-error {{'Int' was imported as 'var', but is a struct}} {{8-11=struct}}

// CHECK: [[@LINE-4]]:14: error: 'Int' was imported as 'class', but is a struct
// CHECK-NEXT: Number FIXITs = 1
// CHECK-NEXT: FIXIT: ([[FILE:.*import-specific-fixits.swift]]:[[@LINE-6]]:8 - [[FILE]]:[[@LINE-6]]:13): "struct"
// CHECK-NEXT: note: 'Int' declared here

import typealias Swift.GeneratorType // expected-error {{'GeneratorType' was imported as 'typealias', but is a protocol}} {{8-17=protocol}}
import struct Swift.GeneratorType // expected-error {{'GeneratorType' was imported as 'struct', but is a protocol}} {{8-14=protocol}}
import func Swift.GeneratorType // expected-error {{'GeneratorType' was imported as 'func', but is a protocol}} {{8-12=protocol}}

import class Swift.Int64 // expected-error {{'Int64' was imported as 'class', but is a struct}} {{8-13=struct}}

import class Swift.Bool // expected-error {{'Bool' was imported as 'class', but is a struct}} {{8-13=struct}}

import struct FooBar.x // expected-error {{'x' was imported as 'struct', but is a variable}} {{8-14=var}}

import struct Swift.println // expected-error {{'println' was imported as 'struct', but is a function}} {{8-14=func}}

// CHECK: [[@LINE-2]]:15: error: 'println' was imported as 'struct', but is a function
// CHECK-NEXT: Number FIXITs = 1
// CHECK-NEXT: FIXIT: ([[FILE]]:[[@LINE-4]]:8 - [[FILE]]:[[@LINE-4]]:14): "func"
// CHECK-NOT: note: 'println' declared here


import func ambiguous.funcOrVar // expected-error{{ambiguous name 'funcOrVar' in module 'ambiguous'}}
import var ambiguous.funcOrVar // expected-error{{ambiguous name 'funcOrVar' in module 'ambiguous'}}
import struct ambiguous.funcOrVar // expected-error{{ambiguous name 'funcOrVar' in module 'ambiguous'}}

// CHECK: [[@LINE-4]]:13: error: ambiguous name 'funcOrVar' in module 'ambiguous'
// CHECK-NEXT: Number FIXITs = 0
// CHECK-NEXT: note: found this candidate
// CHECK-NEXT: Number FIXITs = 0
// CHECK-NEXT: note: found this candidate

import func ambiguous.someVar // expected-error{{ambiguous name 'someVar' in module 'ambiguous'}}
import var ambiguous.someVar // expected-error{{ambiguous name 'someVar' in module 'ambiguous'}}
import struct ambiguous.someVar // expected-error{{ambiguous name 'someVar' in module 'ambiguous'}}

import struct ambiguous.SomeStruct // expected-error{{ambiguous name 'SomeStruct' in module 'ambiguous'}}
import typealias ambiguous.SomeStruct // expected-error{{ambiguous name 'SomeStruct' in module 'ambiguous'}}
import class ambiguous.SomeStruct // expected-error{{ambiguous name 'SomeStruct' in module 'ambiguous'}}

import func ambiguous.overloadedFunc // no-warning
