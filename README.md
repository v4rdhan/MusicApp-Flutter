# music_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## GitLab Android releases

The GitLab pipeline builds a release APK for commits on the default branch,
increments both the patch and build numbers from the latest matching GitHub
tag, and publishes the APK as a GitHub release asset. The baseline version is
set in `pubspec.yaml`; the current baseline is `1.0.3+4`.

Configure a masked GitLab CI/CD variable named `GITHUB_TOKEN` with a GitHub
token that has **Contents: read and write** access to
`v4rdhan/MusicApp-Flutter`. The pipeline creates version tags in the form
`v1.0.4+5` from the current baseline and attaches the APK to the corresponding
GitHub release.
