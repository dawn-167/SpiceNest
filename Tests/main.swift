import Foundation

// MARK: - SpiceNest SearchService 回归测试
// 用途：验证搜索服务的搜索结果是否符合预期
// 用法：由 scripts/run_tests.sh 编译并运行
// 依据：ERROR_PREVENTION.md 第三章 P2 项 #5

func runTests() -> Int32 {
    // 获取内容目录路径（从命令行参数或环境变量）
    let contentDir: String
    if CommandLine.arguments.count > 1 {
        contentDir = CommandLine.arguments[1]
    } else if let env = ProcessInfo.processInfo.environment["SPICENEST_CONTENT_DIR"] {
        contentDir = env
    } else {
        contentDir = "./Resources/content"
    }

    print("=== SpiceNest SearchService 回归测试 ===")
    print("内容目录: \(contentDir)")
    print("")

    // 初始化内容加载器和搜索服务
    let contentURL = URL(fileURLWithPath: contentDir)
    let loader = ContentLoader(contentDirectory: contentURL)
    let searchService = SearchService(items: loader.allItems)

    print("已加载 \(loader.allItems.count) 条内容")
    print("")

    // 读取搜索用例文件
    let casesFile = URL(fileURLWithPath: contentDir)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("scripts/search_cases.txt")

    guard let casesContent = try? String(contentsOf: casesFile, encoding: .utf8) else {
        print("❌ 无法读取搜索用例文件: \(casesFile.path)")
        return 1
    }

    // 解析用例
    var testCases: [(query: String, expectedIds: [String], note: String)] = []
    for line in casesContent.components(separatedBy: .newlines) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

        let parts = trimmed.components(separatedBy: "|")
        if parts.count >= 2 {
            let query = parts[0].trimmingCharacters(in: .whitespaces)
            let expectedIds = parts[1].trimmingCharacters(in: .whitespaces)
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            let note = parts.count > 2 ? parts[2].trimmingCharacters(in: .whitespaces) : ""
            testCases.append((query, expectedIds, note))
        }
    }

    print("共 \(testCases.count) 个测试用例")
    print("")

    // 运行测试
    var passed = 0
    var failed = 0

    for testCase in testCases {
        let results = searchService.searchFlat(query: testCase.query)
        let resultIds = results.map { $0.id }

        // 检查所有预期 id 是否都在结果中
        var allFound = true
        for expectedId in testCase.expectedIds {
            if !resultIds.contains(expectedId) {
                allFound = false
                break
            }
        }

        if allFound {
            passed += 1
            print("✅ \(testCase.query) → \(results.count) 条结果 (\(testCase.note))")
        } else {
            failed += 1
            print("❌ \(testCase.query) → 缺少预期结果 (\(testCase.note))")
            print("   预期: \(testCase.expectedIds)")
            print("   实际: \(resultIds)")
        }
    }

    // 输出总结
    print("")
    print("=== 测试总结 ===")
    print("通过: \(passed) / \(testCases.count)")
    print("失败: \(failed) / \(testCases.count)")

    if failed > 0 {
        print("")
        print("❌ 有 \(failed) 个测试用例失败！")
        return 1
    } else {
        print("")
        print("✅ 所有测试用例通过！")
        return 0
    }
}

// 运行测试
let exitCode = runTests()
exit(exitCode)
