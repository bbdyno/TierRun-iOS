import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .all,
    swiftVersion: "6.0.0",
    generationOptions: .options(
        resolveDependenciesWithSystemScm: false,
        disablePackageVersionLocking: false
    )
)
