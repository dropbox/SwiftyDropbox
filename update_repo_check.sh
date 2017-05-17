#!/bin/sh

# Release checklist
#
# 1. Make sure test data is reset
# 2. Run generator
# 3. Check test project, run unit tests
# 4. Check pod spec lint
# 5. Increment version with script
# 6. Update Carthage example project
# 7. Push to CocoaPods
#

cat TestSwiftyDropbox/IntegrationTests/TestData.swift

# python generate_base_client.py

# pod spec lint
