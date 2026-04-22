#!/bin/bash
# Run from the flutter project root: bash scripts/codegen.sh
set -e

echo "Running Freezed + json_serializable + Riverpod + Isar codegen..."
flutter pub run build_runner build --delete-conflicting-outputs
echo "Codegen complete."
