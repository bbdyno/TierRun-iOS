import ProjectDescription

let project = Project(
    name: "TierRun",
    organizationName: "com.tngtng",
    options: .options(
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
    ),
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    ),
    targets: [
        // Main App Target
        .target(
            name: "TierRun",
            destinations: .iOS,
            product: .app,
            bundleId: "com.tngtng.TierRun",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "NSHealthShareUsageDescription": "티어런은 러닝 데이터를 분석하여 티어를 계산합니다.",
                "NSHealthUpdateUsageDescription": "티어런은 운동 데이터를 기록합니다."
            ]),
            sources: ["TierRun/**/*.swift"],
            resources: [
                "TierRun/**/*.xcassets",
                "TierRun/**/*.storyboard",
                "TierRun/**/*.xib",
                "TierRun/Resources/**/*.strings",
                "TierRun/**/*.intentdefinition"
            ],
            entitlements: .file(path: "TierRun/TierRun.entitlements"),
            scripts: [
                .pre(
                    script: """
                    if which swiftgen >/dev/null; then
                        swiftgen config run --config swiftgen.yml
                    else
                        echo "warning: SwiftGen not installed, download from https://github.com/SwiftGen/SwiftGen"
                    fi
                    """,
                    name: "SwiftGen",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: []
        ),

        // Unit Test Target
        .target(
            name: "TierRunTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.tngtng.TierRunTests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["TierRunTests/**/*.swift"],
            dependencies: [
                .target(name: "TierRun")
            ]
        ),

        // UI Test Target
        .target(
            name: "TierRunUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.tngtng.TierRunUITests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["TierRunUITests/**/*.swift"],
            dependencies: [
                .target(name: "TierRun")
            ]
        )
    ]
)
