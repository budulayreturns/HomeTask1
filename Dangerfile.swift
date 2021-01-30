import Danger

let danger = Danger()

let hasChangelog = danger.git.modifiedFiles.contains("changelog.md")
let isTrivial = (danger.github.pullRequest.body ?? "" + danger.github.pullRequest.title).contains("#trivial")

if (!hasChangelog && !isTrivial) {
    warn("Please add a changelog entry for your changes.")
}

let editedFiles = danger.git.modifiedFiles + danger.git.createdFiles
let swiftFilesWithCopyright = editedFiles.filter {
    $0.contains("Copyright") && ($0.fileType == .swift  || $0.fileType == .m)
}
for file in swiftFilesWithCopyright {
    fail(message: "Please remove this copyright header", file: file, line: 0)
}

var bigPRThreshold = 600;
if let additions = danger.github.pullRequest.additions,
   let deletions = danger.github.pullRequest.deletions,
   additions + deletions > bigPRThreshold {
    warn("> Pull Request size seems relatively large. If this Pull Request contains multiple changes, please split each into separate PR will helps faster, easier review.");
}

SwiftLint.lint()

let report = xcov.produce_report(
   scheme: "MVVM-C",
   workspace: "MVVM-C.xcworkspace"
)

xcov.output_report(report)

