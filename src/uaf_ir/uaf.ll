; ModuleID = 'uaf.c'
source_filename = "uaf.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.A = type { void (i8*)*, i8* }
%struct.B = type { i32, i32 }

@.str = private unnamed_addr constant [19 x i8] c"In vuln function!\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @vuln() #0 !dbg !24 {
entry:
  %call = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str, i64 0, i64 0)), !dbg !27
  ret void, !dbg !28
}

declare dso_local i32 @printf(i8*, ...) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 !dbg !29 {
entry:
  %retval = alloca i32, align 4
  %a = alloca %struct.A*, align 8
  %b = alloca %struct.B*, align 8
  store i32 0, i32* %retval, align 4
  call void @llvm.dbg.declare(metadata %struct.A** %a, metadata !32, metadata !DIExpression()), !dbg !33
  %call = call noalias i8* @malloc(i64 16) #4, !dbg !34
  %0 = bitcast i8* %call to %struct.A*, !dbg !35
  store %struct.A* %0, %struct.A** %a, align 8, !dbg !33
  %1 = load %struct.A*, %struct.A** %a, align 8, !dbg !36
  %2 = bitcast %struct.A* %1 to i8*, !dbg !36
  call void @free(i8* %2) #4, !dbg !37
  call void @llvm.dbg.declare(metadata %struct.B** %b, metadata !38, metadata !DIExpression()), !dbg !39
  %call1 = call noalias i8* @malloc(i64 8) #4, !dbg !40
  %3 = bitcast i8* %call1 to %struct.B*, !dbg !41
  store %struct.B* %3, %struct.B** %b, align 8, !dbg !39
  %4 = load %struct.B*, %struct.B** %b, align 8, !dbg !42
  %B1 = getelementptr inbounds %struct.B, %struct.B* %4, i32 0, i32 0, !dbg !43
  store i32 ptrtoint (void ()* @vuln to i32), i32* %B1, align 4, !dbg !44
  %5 = load %struct.A*, %struct.A** %a, align 8, !dbg !45
  %fnptr = getelementptr inbounds %struct.A, %struct.A* %5, i32 0, i32 0, !dbg !46
  %6 = load void (i8*)*, void (i8*)** %fnptr, align 8, !dbg !46
  %7 = load %struct.A*, %struct.A** %a, align 8, !dbg !47
  %buf = getelementptr inbounds %struct.A, %struct.A* %7, i32 0, i32 1, !dbg !48
  %8 = load i8*, i8** %buf, align 8, !dbg !48
  call void %6(i8* %8), !dbg !45
  ret i32 0, !dbg !49
}

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #2

; Function Attrs: nounwind
declare dso_local noalias i8* @malloc(i64) #3

; Function Attrs: nounwind
declare dso_local void @free(i8*) #3

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone speculatable willreturn }
attributes #3 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!20, !21, !22}
!llvm.ident = !{!23}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Ubuntu clang version 11.1.0-++20210428103915+1fdec59bffc1-1~exp1~20210428204556.164", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "uaf.c", directory: "/mnt/d/c2rust/C2SafeRust/src/uaf_ir")
!2 = !{}
!3 = !{!4, !14}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !5, size: 64)
!5 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "A", file: !1, line: 4, size: 128, elements: !6)
!6 = !{!7, !13}
!7 = !DIDerivedType(tag: DW_TAG_member, name: "fnptr", scope: !5, file: !1, line: 5, baseType: !8, size: 64)
!8 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !9, size: 64)
!9 = !DISubroutineType(types: !10)
!10 = !{null, !11}
!11 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !12, size: 64)
!12 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!13 = !DIDerivedType(tag: DW_TAG_member, name: "buf", scope: !5, file: !1, line: 6, baseType: !11, size: 64, offset: 64)
!14 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !15, size: 64)
!15 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "B", file: !1, line: 9, size: 64, elements: !16)
!16 = !{!17, !19}
!17 = !DIDerivedType(tag: DW_TAG_member, name: "B1", scope: !15, file: !1, line: 10, baseType: !18, size: 32)
!18 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!19 = !DIDerivedType(tag: DW_TAG_member, name: "B2", scope: !15, file: !1, line: 11, baseType: !18, size: 32, offset: 32)
!20 = !{i32 7, !"Dwarf Version", i32 4}
!21 = !{i32 2, !"Debug Info Version", i32 3}
!22 = !{i32 1, !"wchar_size", i32 4}
!23 = !{!"Ubuntu clang version 11.1.0-++20210428103915+1fdec59bffc1-1~exp1~20210428204556.164"}
!24 = distinct !DISubprogram(name: "vuln", scope: !1, file: !1, line: 14, type: !25, scopeLine: 14, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!25 = !DISubroutineType(types: !26)
!26 = !{null}
!27 = !DILocation(line: 15, column: 5, scope: !24)
!28 = !DILocation(line: 16, column: 1, scope: !24)
!29 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 18, type: !30, scopeLine: 19, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!30 = !DISubroutineType(types: !31)
!31 = !{!18}
!32 = !DILocalVariable(name: "a", scope: !29, file: !1, line: 20, type: !4)
!33 = !DILocation(line: 20, column: 15, scope: !29)
!34 = !DILocation(line: 20, column: 31, scope: !29)
!35 = !DILocation(line: 20, column: 19, scope: !29)
!36 = !DILocation(line: 21, column: 10, scope: !29)
!37 = !DILocation(line: 21, column: 5, scope: !29)
!38 = !DILocalVariable(name: "b", scope: !29, file: !1, line: 22, type: !14)
!39 = !DILocation(line: 22, column: 15, scope: !29)
!40 = !DILocation(line: 22, column: 31, scope: !29)
!41 = !DILocation(line: 22, column: 19, scope: !29)
!42 = !DILocation(line: 23, column: 5, scope: !29)
!43 = !DILocation(line: 23, column: 8, scope: !29)
!44 = !DILocation(line: 23, column: 11, scope: !29)
!45 = !DILocation(line: 24, column: 5, scope: !29)
!46 = !DILocation(line: 24, column: 8, scope: !29)
!47 = !DILocation(line: 24, column: 14, scope: !29)
!48 = !DILocation(line: 24, column: 17, scope: !29)
!49 = !DILocation(line: 26, column: 5, scope: !29)
