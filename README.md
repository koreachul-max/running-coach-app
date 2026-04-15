 HEAD
# Running Coach App

SwiftUI iOS app for:

- managing sub-3 marathon training plans
- saving run logs locally
- tracking routes with GPS
- selecting photos and videos after a run
- generating a social share card

## Project structure

- `project.yml`: XcodeGen project definition
- `codemagic.yaml`: Codemagic CI workflow
- `RunningCoachApp.swift`: app entry point
- `ContentView.swift`: main tab container
- `RunningCoachViewModel.swift`: app state and local persistence
- `TrainingPlanView.swift`: manual sessions and generated goal plan
- `RunLogView.swift`: run log input and history
- `DashboardView.swift`: goal summary and share card action
- `RouteMapView.swift`: GPS tracking and saved routes
- `MediaGalleryView.swift`: photo and video selection and sharing

## Windows + Codemagic flow

You do not need to manually create the `.xcodeproj` on Windows.

1. Push this repository to GitHub.
2. Connect the repository in Codemagic.
3. Codemagic reads `codemagic.yaml`.
4. During the build, Codemagic installs `XcodeGen`.
5. `XcodeGen` uses `project.yml` to generate `RunningCoachApp.xcodeproj`.
6. Codemagic builds the generated iOS project.

## First Git push

Run these commands after setting your Git identity:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

git add .
git commit -m "Add Running Coach app"
git remote add origin <YOUR_GITHUB_REPOSITORY_URL>
git push -u origin main
```

## Codemagic checklist

- Repository contains `codemagic.yaml`
- Repository contains `project.yml`
- After pushing, click `Check for configuration file`
- Start the `ios_build` workflow

## Apple requirements for real iPhone install

To install on an actual iPhone, you will still need:

- an Apple Developer account or Apple ID based signing flow
- signing certificates / provisioning profiles for release distribution
- TestFlight or another signing-based install path

The current workflow is set up first to validate and build the app project cleanly in Codemagic.

# running-coach-app
>>>>>>> 6c0df287a3eee6790354725b4bdf0bf35bf7212e
